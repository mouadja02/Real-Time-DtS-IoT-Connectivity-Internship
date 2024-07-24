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
tic
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

W = matrix;
%%
N_nodes = 19;
N_sats = 16;

duration = 420;
period = 1.59*3600;
% W = [
% 
%     -2    45    63    87    63    47
%     81    59    48    83    15    15
%     47    42    79    29     8    -5
%      3     4    55    -7    -5     9
%     40    27    16    56    34    29
%     39    10     1    70    13    83
%     33    -7    83    86    34    10
%     30    12    -7    46    65    -5
%     35    14    25    56    11    27
%     53    28    57     5    53    88
%     18    39    90    -2    68    -2
%     23    23    87    49    -9    -3
%      1    54    36    26    15    37
%     67    83    -3    11    88    57
%     37    54    79    -3    57     1
%     ];

%%
clear all;
clc;
% Number of nodes and satellites
T_orbit=100;
T_visibile=10;

N_sats = 6;
N_nodes = 15;

W = randi([0, 100], N_nodes + 1, N_sats) - 10 % "+1" for the ground station


    
% Step 3: Find the best path from nodes to GS considering DNR
for i = 1:1%N_nodes
    tic
    hops=inf;
    bestPath = {};
    bestDelay = inf;
    for j = 1:N_sats
        % check if one stage is the best
        stage_delay = hop_delay(W(i,j),W(end,j));
        if stage_delay < bestDelay
            if ~(stage_delay  == bestDelay && hops > 2)
                bestDelay = stage_delay;
                bestPath = {['N' num2str(i)], ['S' num2str(j)],['GS (2 Hops)']};
                hops=2;
            end
        end
        for k = 1:N_nodes
            if  k ~= i
                hop2_delay = hop_delay(W(i,j),W(k,j));
                for l_= 1:N_sats
                    if  l_ ~= j
                        hop3_delay = hop_delay(hop2_delay,W(k,l_));
                        % check if two stages are the best
                        stage_delay = hop_delay(hop3_delay,W(end,l_));
                        if stage_delay < bestDelay
                            if ~(stage_delay  == bestDelay && hops > 4)
                                bestDelay = stage_delay;
                                bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)],  ['GS (4 Hops)']};
                                hops=4;
                            end
                        end
                        for m = 1:N_nodes+1
                            if  k ~= m
                                hop4_delay = hop_delay(hop3_delay,W(m,l_));
                                for n= 1:N_sats
                                    if  l_ ~= n
                                        hop5_delay = hop_delay(hop4_delay,W(m,n));
                                        % check if three stages are the best
                                        stage_delay =   hop_delay(hop5_delay,W(end,n));
                                        if stage_delay < bestDelay
                                            if ~(stage_delay  == bestDelay && hops > 6)
                                                bestDelay = stage_delay;
                                                bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)], ['N' num2str(m)], ['S' num2str(n)],  ['GS (6 Hops)']};
                                                hops=6;
                                            end
                                        end
                                        for o = 1:N_nodes+1
                                            if  k ~= m
                                                hop6_delay = hop_delay(hop5_delay,W(m,l_));
                                                for p= 1:N_sats
                                                    if  l_ ~= n
                                                        hop7_delay = hop_delay(hop6_delay,W(m,n));
                                                        % check if four stages are the best
                                                        stage_delay =   hop_delay(hop7_delay,W(end,n));
                                                        if stage_delay < bestDelay
                                                            if ~(stage_delay  == bestDelay && hops > 8)
                                                                bestDelay = stage_delay;
                                                                bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)], ['N' num2str(m)], ['S' num2str(n)],    ['N' num2str(o)], ['S' num2str(p)], ['GS (8 Hops)']};
                                                                hops=8;
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    % Choose the path with the minimum total delay
    
    
    % Display the best path and delay
    disp(['N' num2str(i) ' to GS: ' ]);
    [~,sat_NR]=min(W(i,:));
    disp(['Delay of No Routing: ' num2str(hop_delay(W(i,sat_NR),W(end,sat_NR)))]);
    disp(['Best path : ' strjoin(bestPath, ' -> ') ]);
    disp(['Best path delay: ' num2str(bestDelay)   ]);
    toc
    disp([' ' ]);
    
    
end

disp("---------------------------------------------------");
duration = 10;
period = 100;
str_matrix = W;
tic
[opt_path,min_delay,str_matrix] = backward_research(W,1,N_nodes+1,duration, period);
matrix = str_matrix;
[path, delay] = best_path(matrix,duration, period);
toc

disp(['Delay of Routing: ' num2str(delay)]);
disp('Best Routing Path:');
display_path(path);

FloydWarshall('output.txt');

function FloydWarshall(fileName)
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
        dist(x, y) = w;
        parent(x, y) = x;
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
                if dist(i, j) > dist(i, k) + dist(k, j)
                    dist(i, j) = dist(i, k) + dist(k, j);
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
    
    % Display final paths
    disp('All Pairs Shortest Paths:');
    disp(['From: ', num2str(1), ' To: ', num2str(20)]);
    disp(['Path: ', num2str(1), obtainPath(1, 20, parent,dist), num2str(20)]);
    disp(['Distance: ', num2str(dist(1, 20))]);
    disp(' ');
       
    
    fclose(fileID);
end

function pathStr = obtainPath(i, j, parent, dist)
    if dist(i, j) == inf
        pathStr = ' no path to ';
    else
        if parent(i, j) == i
            pathStr = ' ';
        else
            pathStr = [obtainPath(i, parent(i, j), parent), ' ', num2str(parent(i, j)), ' ', obtainPath(parent(i, j), j, parent)];
        end
    end
end


function [path, delay] = best_path(matrix,duration, period)
    [rows, cols] = size(matrix);
    delay = inf;
    path = [];
    first = true;
    for i=1:cols
        for j=1:cols
            if matrix(1,i)~=inf && matrix(rows,j)~=inf
                [tmp_path, tmp_delay] = dijkstra(matrix, [1,i], [rows,j], 'v',duration, period);
                if (tmp_delay <= delay ) %&& length(tmp_path)<length(path)) || first
                    delay = tmp_delay;
                    path = tmp_path;
                    first = false;
                end
            end
        end
    end
end

function [path, delay] = dijkstra(matrix, start, goal, dir,duration, period)
    [rows, cols] = size(matrix);
    delays = inf(rows, cols);
    delays(start(1), start(2)) = matrix(start(1), start(2));
    priority_queue = [matrix(start(1), start(2)) , start];
    came_from = cell(rows, cols);

    while ~isempty(priority_queue)
        tmp_priority_queue = [];
        for idx = 1:length(priority_queue(:, 1))
            current_delay = priority_queue(idx, 1);
            current = priority_queue(idx, 2:3);

            if current == 20
                break;
            end

            neighbors = get_neighbors(matrix, current, rows, cols, dir);
            for k = 1:size(neighbors, 1)
                neighbor = neighbors(k, :);
                delay = calculate_delay(current_delay,matrix(neighbor(1), neighbor(2)),duration, period);
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

function display_path(path)
    path_str = '';

    for i = 1:size(path, 1)
        node = path(i, :);
        if i == 1
            path_str = sprintf('N%d ---> S%d', node(1), node(2));
        else
            if i == size(path, 1)
                path_str = sprintf('%s ---> GS', path_str);
            else
                if mod(i, 2) == 0 % if even index
                    path_str = sprintf('%s ---> N%d', path_str, node(1));
                else % if odd index
                    path_str = sprintf('%s ---> S%d', path_str, node(2));
                end
            end
        end
    end

    disp(path_str);
end

function [path,min_delay] = dNR(matrix,start_node,end_node,connectivity_duration, orbital_period)
    numSat=length(matrix(1,:));
    numNodes= length(matrix(:,1));
    min_delay = inf;
    path = {'No Route'};
    for i=1:numSat
        if matrix(start_node,i)~=inf && matrix(end_node,i)~=inf
            delay = calculate_delay(matrix(start_node,i),matrix(end_node,i),connectivity_duration, orbital_period);
            if delay < min_delay
                path = {'N1', ['S' num2str(i)],'GS (NR)'};
                min_delay = delay;
            end
        end
    end
    % Display the NR path and delay
    disp(['N1 to GS: ' ]);
    disp(['Delay of No Routing: ' num2str(min_delay)]);
    disp(['Best No Routing path : ' strjoin(path, ' -> ') ]);
    disp([' ' ]);
end

 function [best_path,min_delay,str_matrix] = backward_research(matrix,start_node,end_node,connectivity_duration, orbital_period)
    numSat=length(matrix(1,:));
    numNodes= length(matrix(:,1));
    [NR_path,NR_delay] = dNR(matrix,start_node,end_node,connectivity_duration,orbital_period);
    NR_validity = true;
    indexes = [];
    dir = 'v';
    min_delay = inf;
    best_path = {'No Route'};
    for i=1:numSat
        if matrix(end_node,i)<NR_delay
            NR_validity = false;
            indexes = [indexes,[end_node;i]];
        else
            matrix(end_node,i) = inf;
        end
    end

    if NR_validity
        min_delay = NR_delay;
        best_path = NR_path;
    else
        str_matrix = simplify_matrix(matrix,indexes,dir,connectivity_duration,orbital_period,1);
    end

end


% Recursive simplification function
function str_matrix = simplify_matrix(matrix,indexes,dir,connectivity_duration,orbital_period,iter)
    numSat=length(matrix(1,:));
    numNodes= length(matrix(:,1));
    list_index = [];
    if isempty(indexes) || iter==numSat*numNodes
        str_matrix = matrix;
    else
        out_matrix = matrix;
        if dir == 'h'
            for x=indexes
                start = x(1,:);
                i = x(2,:);
                val = out_matrix(start,i);
                index = [];
                for j=1:numSat
                    if out_matrix(i,j)~=inf && j~=start && i~=j
                        if val+connectivity_duration-1<out_matrix(i,j)
                            out_matrix(i,j)=inf;
                        else
                            if ~ismember([i;j],list_index)
                                list_index = [list_index,[i;j]];
                            end
                        end
                    end
                end
            end
        else
            for x=indexes             
                start = x(1,:);
                i = x(2,:);
                val = out_matrix(start,i);
                index = [];
                for j=1:numNodes
                    if out_matrix(j,i)~=inf && j~=start && j~=i
                        if val+connectivity_duration-1<out_matrix(j,i)
                            out_matrix(j,i)=inf;
                        else
                            if ~ismember([j;i],index)
                                list_index= [list_index,[j;i]];
                            end
                        end
                    end
                end
            end
        end
        clear indexes;
        indexes = list_index;
        if dir == 'v'
            str_matrix = simplify_matrix(out_matrix,indexes,'h',connectivity_duration,orbital_period,iter+1);
        else
            str_matrix = simplify_matrix(out_matrix,indexes,'v',connectivity_duration,orbital_period,iter+1);
        end
    end
    
end

% Fonction pour calculer le délai entre les noeuds
function delay = calculate_delay(x, y, connectivity_duration, orbital_period)
    hop1 =  x;
    if y < hop1 -10
        hop2 = 100 + y- x;  % Only consider the adjusted satellite to GS delay
    else
        hop2 =  y - max(0,x); % Consider both delays
    end
    delay = max(0,hop1) + max(0,hop2);
end

function total_delay = hop_delay(d_1,d_2)
    % Calculate d_NR
    hop1 =  d_1;
    if d_2 < hop1 -10
        hop2 = 100 + d_2- d_1;  % Only consider the adjusted satellite to GS delay
    else
        hop2 =  d_2 - max(0,d_1); % Consider both delays
    end
    total_delay = max(0,hop1) + max(0,hop2);
end

% floyd warshall algorithm for connectivity checking
% time-dependent networks

