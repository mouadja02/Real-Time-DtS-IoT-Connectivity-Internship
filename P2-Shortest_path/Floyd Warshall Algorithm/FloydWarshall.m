clc;
clear all;

duration = 420;
period = 1.59 * 3600;
Floyd_Warshall('input.txt',[1],[4],duration,period);

function Floyd_Warshall(fileName,srcs,dists,duration,period)
    tic
    fileID = fopen(fileName, 'r');
    
    if fileID == -1
        disp('File not found.');
        return;
    end
    
    V = fscanf(fileID, '%d', 1);
    
    dist = inf(V, V);
    parent = zeros(V, V);


    % Read number of edges
    E = fscanf(fileID, '%d', 1);
    
    % Path from vertex to itself is set to 0
    for i = 1:V
        dist(i, i) = 0;
    end
    
    % Read edges from input file and store in matrices
    for i = 1:E
        x = fscanf(fileID, '%d', 1);
        y = fscanf(fileID, '%d', 1);
        w = fscanf(fileID, '%d', 1);
        dist(x, y) = w;
        parent(x, y) = x;
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
    
    % Floyd-Warshall algorithm
    for k = 1:V
        for i = 1:V
            for j = 1:V
                if dist(i, j) > calculate_delay(dist(i, k), dist(k, j), duration, period)
                    dist(i, j) = calculate_delay(dist(i, k), dist(k, j), duration, period);
                    parent(i, j) = parent(k, j);
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
    fclose(fileID);
    toc


    % Display final paths
    disp('All Pairs Shortest Paths:');
    for i = srcs
        for j = dists
            disp(['From N', num2str(i), ' To N', num2str(j)]);
            disp(['Path: N', num2str(i), obtainPath(i, j, parent),' N', num2str(j)]);
            disp(['Delay: ', num2str(dist(i, j))]);
            disp('---------------------------------------------');   
        end
    end
    
end

function pathStr = obtainPath(i, j, parent)
    if parent(i, j) == 0 || parent(i, j) == i
        pathStr = '-->';
    else
        if parent(i, j) > 10
            pathStr = [obtainPath(i, parent(i, j), parent), ' S', num2str(parent(i, j)-10), ' ', obtainPath(parent(i, j), j, parent)];
        else
            pathStr = [obtainPath(i, parent(i, j), parent), ' N', num2str(parent(i, j)), ' ', obtainPath(parent(i, j), j, parent)];
        end
    end
end

% Function to calculate delay between nodes
function delay = calculate_delay(x, y, connectivity_duration, orbital_period)
    if x > y
        if x < y + connectivity_duration
            delay = max(x, 0);
        else
            delay = y + orbital_period;
        end
    else
        delay = max(y, 0);
    end
end
