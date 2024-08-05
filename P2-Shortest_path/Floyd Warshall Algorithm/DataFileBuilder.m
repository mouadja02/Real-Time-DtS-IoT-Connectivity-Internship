% Load the CSV file
filename = 'access_intervals.csv';
data = readtable(filename);


% Convert Source and Target columns using the convert_to_int function
data.Source = cellfun(@convert_to_int, data.Source);
data.Target = cellfun(@convert_to_int, data.Target);

% Number of nodes and satellites
numNodes = 20;
numSats = 16;
done = false(numNodes,numSats);

% Create the adjacency list format
adjacencyList = [];
for i = 1:height(data)
    node = data.Target(i)
    satellite = data.Source(i)
    startTime = data.StartTime(i)

    delay = sprintf('%s', datestr(startTime, 'HH:MM:SS'));
    
    
    % Mettre à jour la matrice avec le premier temps de début de connexion
    if done(node, satellite-numNodes) == false
        S = str2double(delay(1:2))*3600 + str2double(delay(4:5))*60 + str2double(delay(7:8));
        done(node, satellite-numNodes) = true;
    end

    adjacencyList = [adjacencyList; node, satellite, S];
end

% Create the output file
outputFilename = 'input.txt';
fid = fopen(outputFilename, 'w');

% Write the number of vertices and edges
fprintf(fid, '%d\n', numNodes+numSats);
fprintf(fid, '%d\n', 2*height(data));

% Write the adjacency list
for i = 1:size(adjacencyList, 1)
    fprintf(fid, '%d %d %d\n', adjacencyList(i, 1), adjacencyList(i, 2), adjacencyList(i, 3));
end

for i = 1:size(adjacencyList, 1)
    fprintf(fid, '%d %d %d\n', adjacencyList(i, 2), adjacencyList(i, 1), adjacencyList(i, 3));
end

% Close the file
fclose(fid);

disp(['Output written to ', outputFilename]);

% Function to convert node/satellite identifier to integer
function id = convert_to_int(identifier)
    if startsWith(identifier, 'N')
        id = str2double(extractAfter(identifier, 'N'));
    elseif startsWith(identifier, 'S')
        id = str2double(extractAfter(identifier, 'S')) + 20;
    else
        error('Invalid identifier format');
    end
end

%%
function delay = FloydWarshall(matrix, start_, end_, Tcon, Torb, numIoTs, numSats)
    % Assume matrix is provided as input where rows are IoTs and columns are satellites
    
    
    % Initialize distance and parent matrices
    dist = inf(numIoTs, numSats);
    parent = zeros(numIoTs, numSats);
    
    % Read the matrix and initialize dist and parent matrices
    for i = 1:numIoTs
        for j = 1:numSats
            if matrix(i, j) < inf
                dist(i, j) = matrix(i, j);
                parent(i, j) = i;
            end
        end
    end
    
    % Path from vertex to itself is set to 0
    for i = 1:numIoTs
        dist(i, i) = 0;
    end
    
    % Initialize the path matrix
    for i = 1:numIoTs
        for j = 1:numSats
            if dist(i, j) == inf
                parent(i, j) = 0;
            else
                parent(i, j) = i;
            end
        end
    end
    
    % Actual Floyd-Warshall algorithm
    for k = 1:numSats
        for i = 1:numIoTs
            for j = 1:numSats
                if dist(i, j) > calculate_delay(dist(i, k), dist(k, j), Tcon, Torb);
                    dist(i, j) = calculate_delay(dist(i, k), dist(k, j), Tcon, Torb);
                    parent(i, j) = parent(k, j);
                end
            end
        end
    end

    % Check for negative cycles (if applicable)
    for i = 1:numIoTs
        if dist(i, i) ~= 0
            disp(['Negative cycle at: ', num2str(i)]);
            return;
        end
    end
    
    delay = dist(start_, end_);
    % Display final paths
    disp('Floyd-Warshall Results');
    disp(['From: ', num2str(start_), ' To: ', num2str(end_)]);
    disp(['Path: N', num2str(start_), obtainPath(start_, end_, parent, dist), ' N', num2str(end_)]);
    disp(['Delay: ', num2str(delay)]);
    disp(' ');
end
