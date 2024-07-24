clc; close all; clear;

% Read the CSV data
data = readtable('access_intervals.csv');

% Define the orbital period and connectivity duration
orbital_period = seconds(5724); % =1.59h (StarLink satellites orbit period)
connectivity_duration = seconds(420); % 7 min

% Extract only relevant nodes (IoTs and Satellites)
iot_nodes = unique([data.Target(contains(data.Target, 'IoT'))]);

% Initialize a new graph object for IoT and Satellite connections
iot_edges = [];
edge_labels = [];

% Loop through the data to identify connections between nodes
for i = 1:height(data)
    source = data.Source{i};
    target = data.Target{i};
    start_time = data.StartTime(i);
    
    % Convert start_time to seconds from the start of the day
    start_time_in_seconds = seconds(start_time);

    % Create edges based on all connections
    iot_edges = [iot_edges; {source, target}];
    edge_labels = [edge_labels; {num2str(start_time_in_seconds)}]; % Convert to string
end

% Create graph for IoT and Satellite connections

% Initialize updated edges and labels
updated_edg_labels = [];
updated_iot_edges = [];
gs_iots = ["MainIoT","Node 1", "Node 2", "GS"];
sats = ["Satellite 1", "Satellite 2", "Satellite 3"];

% Loop through each satellite and each IoT to find the first connectivity start time
for i = 1:length(sats)
    sat = sats(i);
    for j = 1:length(gs_iots)
        iot = gs_iots(j);
        % Find all connections for this satellite and IoT
        relevant_data = data(strcmp(data.Source, sat) & strcmp(data.Target, iot), :);
        if ~isempty(relevant_data)
            % Find the earliest start time link
            [~, idx] = min(relevant_data.StartTime);
            first_start_time = relevant_data.StartTime(idx);
            
            % Convert start times to seconds
            first_start_time_seconds = seconds(first_start_time);
            
            % Format the start times as seconds
            start_times_str = sprintf('%d', first_start_time_seconds);                                  
            
            % Update the edges and labels
            updated_iot_edges = [updated_iot_edges; {char(sat), char(iot)}];
            updated_edg_labels = [updated_edg_labels; str2num(start_times_str)];
        end
    end
end

% Remove satellites

% Extract only relevant nodes (IoTs and Satellites)
iot_nodes = unique([data.Target(contains(data.Target, 'IoT'))]);

gs_iots = ["N1","N2","N3","N4","N5","N6", "N7","N8","N9","N10","N11","N12","N13","N14", "N15","N16","N17","N18", "N19","N20"];
sats = ["S1","S2","S3","S4","S5","S6", "S7","S8","S9","S10","S11","S12","S13","S14", "S15","S16"];

% Loop through each satellite and each IoT to find the first connectivity start time
delays = {};
for i = 1:length(gs_iots)

    if i>1 && i<length(gs_iots)
        j = i;
        while  j~=2
            j = j-1;
            iot1 = gs_iots(i);
            iot2 = gs_iots(j);
            for k = 1:length(sats)
                sat = sats(k);
                % Find all connections for this satellite and both IoTs
                relevant_data_iot1 = data(strcmp(data.Source, sat) & strcmp(data.Target, iot1), :);
                relevant_data_iot2 = data(strcmp(data.Source, sat) & strcmp(data.Target, iot2), :);
                if ~isempty(relevant_data_iot1) && ~isempty(relevant_data_iot2)
                    % Find the earliest start time links
                    [~, idx1] = min(relevant_data_iot1.StartTime);
                    [~, idx2] = min(relevant_data_iot2.StartTime);
                    first_start_time_iot1 = relevant_data_iot1.StartTime(idx1);
                                       first_start_time_iot2 = relevant_data_iot2.StartTime(idx2);
        
                    % Calculate the delay
                    delay = calculate_delay(first_start_time_iot1, first_start_time_iot2, connectivity_duration, orbital_period);
        
                    % Store the delay with the associated satellite
                    delays{end+1} = {iot1, iot2, delay, sat};
                end
            end
        end
    end

    for j = i:length(gs_iots)
        if i~=j
            iot1 = gs_iots(i);
            iot2 = gs_iots(j);
            for k = 1:length(sats)
                sat = sats(k);
                % Find all connections for this satellite and both IoTs
                relevant_data_iot1 = data(strcmp(data.Source, sat) & strcmp(data.Target, iot1), :);
                relevant_data_iot2 = data(strcmp(data.Source, sat) & strcmp(data.Target, iot2), :);
                if ~isempty(relevant_data_iot1) && ~isempty(relevant_data_iot2)
                    % Find the earliest start time links
                    [~, idx1] = min(relevant_data_iot1.StartTime);
                    [~, idx2] = min(relevant_data_iot2.StartTime);
                    first_start_time_iot1 = relevant_data_iot1.StartTime(idx1);
                    first_start_time_iot2 = relevant_data_iot2.StartTime(idx2);
    
                    % Calculate the delay
                    delay = calculate_delay(first_start_time_iot1, first_start_time_iot2, connectivity_duration, orbital_period);
    
                    % Store the delay with the associated satellite
                    delays{end+1} = {iot1, iot2, delay, sat};
                end
            end
        end
    end
end

% Initialize updated edges and labels for the new graph without satellites
iot_edges = {};
edg_labels = {};

% Loop through the calculated delays to create the new edges and labels
for i = 1:length(delays)
    iot1 = delays{i}{1};
    iot2 = delays{i}{2};
    delay = delays{i}{3};
    sat = delays{i}{4};
    delay_str = sprintf('%ds (%s)', seconds(delay), sat);
    iot_edges = [iot_edges; {char(iot1), char(iot2)}];
    edg_labels = [edg_labels; {delay_str}];
end

% Create graph for updated IoT connections without satellites
G_updated = digraph(iot_edges(:, 1), iot_edges(:, 2));

% Pick up the best satellite

% Initialize tables to store minimum delays and their indices
min_delays = {};
min_delay_indices = {};
i = 1;
% Calculate the minimum delay and its index for each group of three elements
while  i < length(edg_labels)
    ele0 = iot_edges{i,1};
    ele1 = iot_edges{i,2};
    count = 1;
    while strcmp(iot_edges{i+count,1}, ele0) && strcmp(iot_edges{i+count,2}, ele1) && i+count<length(edg_labels)
        count = count + 1;
    end
   
    delays_group_values = zeros(1, count);
    if i+count==length(edg_labels)
        delays_group = edg_labels(i:i + count);
        intrvl = 1:count+1;
    else
        delays_group = edg_labels(i:i + count - 1);
        intrvl = 1:count;
    end

    for j = intrvl
        x = delays_group{j};
        x = x(1:length(x)-15);
        % Convert to duration for comparison
        delay = str2double(x);
        delays_group_values(j) = delay;
    end
    [min_delay, min_idx] = min_del(delays_group_values);
    min_delays = [min_delays; edg_labels{i + min_idx - 1}];
    min_delay_indices = [min_delay_indices; i + min_idx - 1];
    i = i + count;
end


% Initialize a new graph object for IoT and Satellite connections
updated_iot_edges = {};
updated_edge_labels = min_delays;

% Fill updated_iot_edges with the elements of iot_edges at the indices specified in min_delay_indices
for i = 1:length(min_delay_indices)
    idx = min_delay_indices{i};
    updated_iot_edges = [updated_iot_edges; iot_edges(idx, :)];
end

% Create graph for updated IoT connections without satellites
G_updated = digraph(updated_iot_edges(:, 1), updated_iot_edges(:, 2));

% Brute-force algorithm to find the shortest path from MainIoT to GS
start_node = 'N1';
end_node = 'N20';
paths = allpaths(G_updated, start_node, end_node);

% Calculate the delay for each path and find the shortest one
shortest_path = [];
shortest_delay = inf;

conn_duration = 420;
orbit_period = 5724;

for i = 1:length(paths)
    path = paths{i};
    total_delay = 0;
    for j = 1:length(path) - 1
        % Find the edge corresponding to this part of the path
        edge_idx = findedge(G_updated, path{j}, path{j+1});
        if edge_idx > 0
            delay_str = updated_edge_labels{edge_idx};
            delay_val = str2double(delay_str(1:length(delay_str)-15))
            total_delay = calculate_delay(total_delay,delay_val,conn_duration,orbit_period);

        end
    end
    total_delay
    if total_delay < shortest_delay
        shortest_delay = total_delay;
        shortest_path = i;
    end

    if total_delay == shortest_delay
        shortest_path = [shortest_path,i];
    end

end

% Display the shortest path and its delay
disp('Shortest Path:');
disp(shortest_path);
disp('Total Delay (seconds):');
disp(shortest_delay);

% Create figure to plot the graph with the shortest path highlighted
figure;
p = plot(G_updated, 'Layout', 'force', 'NodeLabel', G_updated.Nodes.Name, ...
         'EdgeLabel', updated_edge_labels, 'LineWidth', 1.5, 'MarkerSize', 8, 'EdgeFontSize', 14, ...
         'NodeFontSize', 14);

% Define positions for the nodes
x_pos = [0 1 0.5 0.5];
y_pos = [1 1 0.5 0];

% Set the positions for the nodes
p.XData = x_pos;
p.YData = y_pos;

% Highlight the shortest path
for x=shortest_path
    highlight(p, paths{x}, 'EdgeColor', 'r', 'LineWidth', 2);
end
% Highlight source and target nodes
highlight(p, start_node, 'NodeColor', 'r', 'MarkerSize', 12);
highlight(p, end_node, 'NodeColor', 'g', 'MarkerSize', 12);

grid on;

function [min, min_idx] = min_del(X)
    min = X(1);
    min_idx = 1;
    for i = 2:length(X)
        if X(i) < min
            min = X(i);
            min_idx = i;
        end
    end
end

% Function to calculate delay between nodes
function delay = calculate_delay(x, y, connectivity_duration, orbital_period)
    if x > y
        if x < y + connectivity_duration
            delay = x;
        else
            delay = y + orbital_period;
        end
    else
        delay = y;
    end
end