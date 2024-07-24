function FloydWarshall(fileName,start_,end_, numNodes)
    % Read input file
    fileID = fopen(fileName, 'r');
    
    if fileID == -1
        disp('File not found.');
        return;
    end
    
    % Read number of vertices
    V = fscanf(fileID, '%d', 1);
    
    % Initialize distance and parent matrices
    dist = inf(V, V);
    parent = zeros(V, V);
    
    % Read number of edges
    E = fscanf(fileID, '%d', 1);
    
    % Read edges from input file and store in matrices
    for i = 1:E
        x = fscanf(fileID, '%d', 1);
        y = fscanf(fileID, '%d', 1);
        w = fscanf(fileID, '%d', 1);
        if w < dist(x, y)
            dist(x, y) = w;
            parent(x, y) = x;
        end
    end
    
    % Path from vertex to itself is set to 0
    for i = 1:V
        dist(i, i) = 0;
    end
    
    % Initialize the path matrix
    for i = 1:V
        for j = 1:V
            if dist(i, j) == inf
                parent(i, j) = 0;
            else
                parent(i, j) = i;
            end
        end
    end
    
    % Actual Floyd-Warshall algorithm
    for k = 1:V
        for i = 1:V
            for j = 1:V
                if dist(i, j) > calculate_delay(dist(i, k),dist(k, j),420,1.59*3600)
                    dist(i, j) = calculate_delay(dist(i, k),dist(k, j),420,1.59*3600);
                    dist(j,i) = dist(i, j);
                    parent(i, j) = parent(k, j);
                    parent(j,i) = parent(i, j);
                end
            end
        end
    end

    
    % Check for negative cycles
    for i = 1:V
        if dist(i, i) ~= 0
            disp(['Negative cycle at: ', num2str(i)]);
            fclose(fileID);
            return;
        end
    end
    

    % Display final paths
    disp('Floyd-Warshall Results');
    disp(['From: ', num2str(start_), ' To: ', num2str(end_)]);
    disp(['Path: N', num2str(start_), obtainPath(start_, end_, parent, dist, numNodes), ' N',num2str(end_)]);
    disp(['Delay: ', num2str(dist(start_, end_))]);
    disp(' ');
       
    
    fclose(fileID);
end
