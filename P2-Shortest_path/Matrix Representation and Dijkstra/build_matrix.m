clc; close all; clear;

% Charger les données depuis le fichier CSV
data = readtable('access_intervals.csv');

% Définir l'ordre des satellites et des nœuds
satellites = {'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'S10', 'S11', 'S12', 'S13', 'S14', 'S15', 'S16'};
nodes = {'N1', 'N2', 'N3', 'N4', 'N5', 'N6', 'N7', 'N8', 'N9', 'N10', 'N11', 'N12', 'N13', 'N14', 'N15', 'N16', 'N17', 'N18', 'N19', 'N20'};

% Initialiser la matrice avec des valeurs 'inf' par défaut
numNodes = length(nodes);
numSatellites = length(satellites);
matrix = inf(numNodes, numSatellites);

% Remplir la matrice avec les temps de début de connexion
for i = 1:height(data)
    node = data.Target{i};
    satellite = data.Source{i};
    startTime = data.StartTime(i);
    delay_str = sprintf('%s', datestr(startTime, 'HH:MM:SS'));
    
    % Trouver les indices correspondants
    nodeIdx = find(strcmp(nodes, node));
    satelliteIdx = find(strcmp(satellites, satellite));
    
    % Mettre à jour la matrice avec le premier temps de début de connexion
    if matrix(nodeIdx, satelliteIdx) == inf
        S = str2double(delay_str(1:2))*3600 + str2double(delay_str(4:5))*60 + str2double(delay_str(7:8));
        matrix(nodeIdx, satelliteIdx) = S;
    end
end

% Afficher la matrice
disp('Node-Satellite Start Time Matrix:');
disp(array2table(matrix, 'VariableNames', satellites, 'RowNames', nodes));

%%
FloydWarshall(matrix)
function FloydWarshall(matrix)
    
    % Number of IoT devices and satellites
    numIoTs = size(matrix, 1);
    numSats = size(matrix, 2);
    
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
                if dist(i, j) > calculate_delay(dist(i, k), dist(k, j), 420, 1.59 * 3600)
                    dist(i, j) = calculate_delay(dist(i, k), dist(k, j), 420, 1.59 * 3600);
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
    
    disp('All Pairs Shortest Paths:');
    for i = 1
        for j = 20
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
        pathStr = [obtainPath(i, parent(i, j), parent), ' N', num2str(parent(i, j)), ' ', obtainPath(parent(i, j), j, parent)];
    end
end

% Function to calculate delay between nodes
function delay = calculate_delay(x, y, connectivity_duration, orbital_period)
    if x > y
        if x < y + connectivity_duration
            delay = max(x,0);
        else
            delay = y + orbital_period;
        end
    else
        delay = max(y,0);
    end
end
% Function to convert node/satellite identifier to integer
function id = convert_to_int(identifier, numberOfNodes)
    if startsWith(identifier, 'N')
        id = str2double(extractAfter(identifier, 'N'));
    elseif startsWith(identifier, 'S')
        id = str2double(extractAfter(identifier, 'S')) + numberOfNodes;
    else
        error('Invalid identifier format');
    end
end