
clc; close all;
% Read the CSV data
data = readtable('access_intervals.csv');

% Convert StartTime to datetime
data.StartTime = datetime(data.StartTime, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');

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

    % Create edges based on all connections
    iot_edges = [iot_edges; {source, target}];
    edge_labels = [edge_labels; {datestr(start_time, 'HH:MM:SS')}]; % Only time part
end

% Create graph for IoT and Satellite connections
G = digraph(iot_edges(:, 1), iot_edges(:, 2));

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
            
            % Calculate the next two connectivity start times
            second_start_time = first_start_time + orbital_period + connectivity_duration;
            third_start_time = second_start_time + orbital_period + connectivity_duration;
            
            % Format the start times as HH:MM:SS
            start_times_str = sprintf('%s, %s, %s', ...
                                      datestr(first_start_time, 'HH:MM:SS'));
                                  
            % Update the edges and labels
            updated_iot_edges = [updated_iot_edges; {char(sat), char(iot)}];
            updated_edg_labels = [updated_edg_labels; {start_times_str}];
        end
    end
end

% Create graph for updated IoT and Satellite connections
G_updated = digraph(updated_iot_edges(:, 1), updated_iot_edges(:, 2));

% Create figure
figure;
p = plot(G_updated, 'Layout', 'force', 'NodeLabel', G_updated.Nodes.Name, ...
         'EdgeLabel', updated_edg_labels, 'LineWidth', 1.5, 'MarkerSize', 8);

% Highlight source and target nodes
highlight(p, "MainIoT", 'NodeColor', 'r', 'MarkerSize', 15);
highlight(p, "GS", 'NodeColor', 'g', 'MarkerSize', 15);
highlight(p, "Node 1", 'NodeColor', 'b', 'MarkerSize', 15);
highlight(p, "Node 2", 'NodeColor', 'y', 'MarkerSize', 15);
grid on;

% Adjust plot layout and node spacing
layout(p, 'force');


% Remove satellites
 
% Extract only relevant nodes (IoTs and Satellites)
iot_nodes = unique([data.Target(contains(data.Target, 'IoT'))]);

% Initialize a new graph object for IoT and Satellite connections
iot_edges = [];
edge_labels = [];

gs_iots = ["MainIoT","Node 1", "Node 2", "GS"];
sats = ["Satellite 1", "Satellite 2", "Satellite 3"];

% Loop through each satellite and each IoT to find the first connectivity start time
delays = {};
for i = 1:length(gs_iots)

    if i==3
        j = 2;
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
    delay_str = sprintf('%s (%s)', datestr(delay, 'HH:MM:SS'), sat);
    iot_edges = [iot_edges; {char(iot1), char(iot2)}];
    edg_labels = [edg_labels; {delay_str}];
end

% Create graph for updated IoT connections without satellites
G_updated = digraph(iot_edges(:, 1), iot_edges(:, 2));

% Create figure
figure;
subplot 211;
p = plot(G_updated, 'Layout', 'force', 'NodeLabel', G_updated.Nodes.Name, ...
         'EdgeLabel', edg_labels, 'LineWidth', 1.5, 'MarkerSize', 8);


% Highlight source and target nodes
highlight(p, "MainIoT", 'NodeColor', 'r', 'MarkerSize', 12);
highlight(p, "GS", 'NodeColor', 'g', 'MarkerSize', 12);
highlight(p, "Node 1", 'NodeColor', 'b', 'MarkerSize', 12);
highlight(p, "Node 2", 'NodeColor', 'y', 'MarkerSize', 12);
grid on;

% Pick up the best satellite

% Initialize tables to store minimum delays and their indices
min_delays = {};
min_delay_indices = {};

% Calculate the minimum delay and its index for each group of three elements
for i = 1:3:length(edg_labels)
    if i+2 <= length(edg_labels)
        delays_group_values = zeros(1,3);
        delays_group = edg_labels(i:i+2);
        for j = 1:3
            x = delays_group{j};
            % Convert to duration for comparison
            delay = str2double(x(1:2))*3600 + str2double(x(4:5))*60 + str2double(x(7:8));
            delays_group_values(j) = delay;
        end
        [min_delay, min_idx] = min_del(delays_group_values);
        min_delays = [min_delays; edg_labels{i + min_idx - 1}];
        min_delay_indices = [min_delay_indices; i + min_idx - 1];
    end
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

% Create figure
subplot 212;
p = plot(G_updated, 'Layout', 'force', 'NodeLabel', G_updated.Nodes.Name, ...
         'EdgeLabel', updated_edge_labels, 'LineWidth', 1.5, 'MarkerSize', 8);


% Highlight source and target nodes
highlight(p, "MainIoT", 'NodeColor', 'r', 'MarkerSize', 12);
highlight(p, "GS", 'NodeColor', 'g', 'MarkerSize', 12);
highlight(p, "Node 1", 'NodeColor', 'b', 'MarkerSize', 12);
highlight(p, "Node 2", 'NodeColor', 'y', 'MarkerSize', 12);
grid on;


% Define positions for the nodes
%x_pos = [0 1 0.5 0.5];
%y_pos = [1 1 0.5 0];

% Set the positions for the nodes
%p.XData = x_pos;
%p.YData = y_pos;


function [min,min_idx] = min_del(X)
    min = X(1);
    min_idx = 1;
    for i=2:length(X)
        if X(i) < min 
            min =  X(i);
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