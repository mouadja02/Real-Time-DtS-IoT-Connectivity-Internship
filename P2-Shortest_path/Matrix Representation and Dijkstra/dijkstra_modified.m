clc;
clear;
close all;

numNodes = 12;
numSats = 18;
% matrix = [
%     inf, inf, inf, inf, inf, inf, 0, inf, inf, inf, inf, inf, inf, inf, inf, 0;
%     inf, inf, inf, inf, inf, inf, 0, 2820, inf, inf, inf, inf, inf, inf, 2220, 0;
%     inf, inf, inf, inf, 0, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf;
%     inf, inf, inf, inf, 0, 3000, inf, 3060, inf, inf, inf, inf, 2280, 0, inf, inf;
%     inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, 240;
%     inf, inf, inf, inf, 300, inf, 180, inf, inf, inf, inf, inf, 2100, inf, 2400, inf;
%     inf, inf, inf, inf, inf, inf, 180, inf, inf, inf, inf, inf, inf, inf, inf, inf;
%     inf, inf, inf, inf, 0, inf, inf, inf, inf, inf, inf, inf, 2160, inf, inf, inf;
%     inf, inf, inf, inf, inf, 2160, inf, inf, inf, inf, inf, inf, inf, 180, 3180, inf;
%     inf, inf, inf, inf, inf, inf, 0, 2520, inf, inf, inf, inf, inf, inf, 2700, 0;
%     1440, inf, 1080, inf, inf, inf, inf, 3480, 960, inf, 1260, inf, 1440, inf, inf, inf;
%     1560, inf, 1260, inf, inf, inf, 540, 3420, 720, 3480, inf, inf, 1440, inf, 1800, inf;
%     1380, inf, 960, inf, inf, inf, inf, inf, inf, inf, inf, inf, 1680, inf, inf, inf;
%     1560, inf, 1200, inf, inf, inf, 540, 3480, 780, 3540, 1200, inf, 1440, inf, 1800, inf;
%     1260, inf, 900, inf, inf, inf, inf, 3540, 1200, inf, 1320, inf, 1560, inf, inf, inf;
%     inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf;
%     1380, inf, 960, inf, inf, 3540, inf, 3420, inf, inf, 1500, inf, 1560, inf, inf, inf;
%     1320, inf, 960, inf, inf, 3540, inf, 3420, inf, inf, 1440, inf, 1560, inf, inf, inf;
%     1260, inf, 840, inf, inf, 3420, inf, 3480, inf, inf, 1560, inf, 1680, inf, inf, inf;
%     1500, inf, 900, inf, 300, 3180, inf, inf, inf, inf, inf, inf, 1920, inf, inf, inf
% ];

data = readtable('access_intervals6.csv');

% Définir l'ordre des satellites et des nœuds
satellites = {'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'S10', 'S11', 'S12', 'S13', 'S14', 'S15', 'S16', 'S17', 'S18'};
nodes = {'N1', 'N2', 'N3', 'N4', 'N5', 'N6', 'N7', 'N8', 'N9', 'N10', 'N11', 'N12', 'N13', 'N14', 'N15', 'N16', 'N17', 'N18', 'N19', 'N20'};

% Initialiser la matrice avec des valeurs 'inf' par défaut
matrix = inf(numNodes, numSats);

% Remplir la matrice avec les temps de début de connexion
 
for i = 1:height(data)
    node = data.Target{i};
    satellite = data.Source{i};
    startTime = data.StartTime(i);
    delay_str = sprintf('%s', datestr(startTime, 'HH:MM:SS'));

    % Trouver les indices correspondants

    nodeIdx = find(strcmp(nodes, node));
    satelliteIdx = find(strcmp(satellites, satellite));

   if nodeIdx>numNodes
       continue;
   end

   if satelliteIdx>numSats
       continue;
   end

    % Mettre à jour la matrice avec le premier temps de début de connexion
    if matrix(nodeIdx, satelliteIdx) == inf
        S = str2double(delay_str(1:2))*3600 + str2double(delay_str(4:5))*60 + str2double(delay_str(7:8));
        matrix(nodeIdx, satelliteIdx) = S;
    end
end

start = [1, 18];
goal = [11, 17];
tic
[path, delay] = dijkstra(matrix, start, goal, 'v', end_node);
toc
disp('matrix:');
disp(matrix);
disp('Path:');
disp(path);
disp('Distance:');
disp(delay);



function [path, delay] = dijkstra(matrix, start, goal, dir, end_node)
    [rows, cols] = size(matrix);
    delays = inf(rows, cols);
    delays(start(1), start(2)) = 0;
    priority_queue = [0, start];
    came_from = cell(rows, cols);

    while ~isempty(priority_queue)
        tmp_priority_queue = [];
        for idx = 1:length(priority_queue(:, 1))
            current_delay = priority_queue(idx, 1);
            current = priority_queue(idx, 2:3);

            if current == end_node
                break;
            end

            neighbors = get_neighbors(matrix, current, rows, cols, dir);
            for k = 1:size(neighbors, 1)
                neighbor = neighbors(k, :);
                delay = calculate_delay(current_delay,matrix(neighbor(1), neighbor(2)),420,1.59*3600);
                if delay < delays(neighbor(1), neighbor(2))
                    delays(neighbor(1), neighbor(2)) = delay;
                    tmp_priority_queue = [tmp_priority_queue; delay, neighbor];
                    came_from{neighbor(1), neighbor(2)} = current;
                end
            end
        end
        priority_queue = tmp_priority_queue;

        if strcmp(dir, 'v')
            dir = 'h';
        else
            dir = 'v';
        end
    end
 
    path = reconstruct_path(came_from, start, goal);
    delay = delays(goal(1), goal(2));
end

function neighbors = get_neighbors(matrix, position, rows, cols, dir)
    neighbors = [];
    if strcmp(dir, 'v')
        for i = 1:rows
            if matrix(i, position(2)) ~= inf
                neighbor = [i, position(2)];
                if is_valid(neighbor, rows, cols)
                    neighbors = [neighbors; neighbor];
                end
            end
        end
    else
        for i = 1:cols
            if matrix(position(1), i) ~= inf
                neighbor = [position(1), i];
                if is_valid(neighbor, rows, cols)
                    neighbors = [neighbors; neighbor];
                end
            end
        end
    end
end

function valid = is_valid(position, rows, cols)
    valid = position(1) >= 1 && position(1) <= rows && position(2) >= 1 && position(2) <= cols;
end

function path = reconstruct_path(came_from, start, goal)
    path = [];
    current = goal;
    while ~isequal(current, start)
        if isempty(came_from{current(1), current(2)})
            path = [];
            return;
        end
        path = [current; path];
        current = came_from{current(1), current(2)};
    end
    path = [start; path];
end


% Fonction pour calculer le délai entre les noeuds
function delay = calculate_delay(x, y, connectivity_duration, orbital_period)
    if x > y
        if x < y + connectivity_duration
            delay = max(x, 0);
        else
            delay = max(y + orbital_period, 0);
        end
    else
        delay = max(y, 0);
    end
end