clc;
clear;
close all;

rows = 20;
cols = 16;
matrix = [
    inf, inf, inf, inf, inf, inf, 0, inf, inf, inf, inf, inf, inf, inf, inf, 0;
    inf, inf, inf, inf, inf, inf, 0, 2820, inf, inf, inf, inf, inf, inf, 2220, 0;
    inf, inf, inf, inf, 0, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf;
    inf, inf, inf, inf, 0, 3000, inf, 3060, inf, inf, inf, inf, 2280, 0, inf, inf;
    inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, 240;
    inf, inf, inf, inf, 300, inf, 180, inf, inf, inf, inf, inf, 2100, inf, 2400, inf;
    inf, inf, inf, inf, inf, inf, 180, inf, inf, inf, inf, inf, inf, inf, inf, inf;
    inf, inf, inf, inf, 0, inf, inf, inf, inf, inf, inf, inf, 2160, inf, inf, inf;
    inf, inf, inf, inf, inf, 2160, inf, inf, inf, inf, inf, inf, inf, 180, 3180, inf;
    inf, inf, inf, inf, inf, inf, 0, 2520, inf, inf, inf, inf, inf, inf, 2700, 0;
    1440, inf, 1080, inf, inf, inf, inf, 3480, 960, inf, 1260, inf, 1440, inf, inf, inf;
    1560, inf, 1260, inf, inf, inf, 540, 3420, 720, 3480, inf, inf, 1440, inf, 1800, inf;
    1380, inf, 960, inf, inf, inf, inf, inf, inf, inf, inf, inf, 1680, inf, inf, inf;
    1560, inf, 1200, inf, inf, inf, 540, 3480, 780, 3540, 1200, inf, 1440, inf, 1800, inf;
    1260, inf, 900, inf, inf, inf, inf, 3540, 1200, inf, 1320, inf, 1560, inf, inf, inf;
    inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf;
    1380, inf, 960, inf, inf, 3540, inf, 3420, inf, inf, 1500, inf, 1560, inf, inf, inf;
    1320, inf, 960, inf, inf, 3540, inf, 3420, inf, inf, 1440, inf, 1560, inf, inf, inf;
    1260, inf, 840, inf, inf, 3420, inf, 3480, inf, inf, 1560, inf, 1680, inf, inf, inf;
    1500, inf, 900, inf, 300, 3180, inf, inf, inf, inf, inf, inf, 1920, inf, inf, inf
];

start = [1, 7];
goal = [20, 5];
[path, delay] = dijkstra(matrix, start, goal, 'v');

disp('matrix:');
disp(matrix);
disp('Path:');
disp(path);
disp('Distance:');
disp(delay);



function [path, delay] = dijkstra(matrix, start, goal, dir)
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

            if current == 20
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