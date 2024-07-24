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

