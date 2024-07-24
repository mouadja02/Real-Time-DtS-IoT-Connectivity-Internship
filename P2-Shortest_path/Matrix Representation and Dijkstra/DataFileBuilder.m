% Load the CSV file
filename = 'access_intervals4.csv';
data = readtable(filename);


% Convert Source and Target columns using the convert_to_int function
data.Source = cellfun(@convert_to_int, data.Source);
data.Target = cellfun(@convert_to_int, data.Target);

% Number of nodes and satellites
numNodes = 37;
numSats = 26;
done = false(numNodes,numSats);

% Create the adjacency list format
adjacencyList = [];
for i = 1:height(data)
    node = data.Target(i)
    satellite = data.Source(i)
    startTime = data.StartTime(i)

    delay = sprintf('%s', datestr(startTime, 'HH:MM:SS'));
    
    
    % Mettre à jour la matrice avec le premier temps de début de connexion
    if done(node+1, satellite-numNodes) == false
        S = str2double(delay(1:2))*3600 + str2double(delay(4:5))*60 + str2double(delay(7:8));
        done(node+1, satellite-numNodes) = true;
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
        id = str2double(extractAfter(identifier, 'S')) + 37;
    else
        error('Invalid identifier format');
    end
end