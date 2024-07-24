clc; close all;

% Read and Prepare Data
data = readtable('access_intervals3.csv');
data.StartTime = datetime(data.StartTime, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');

% Define Parameters
orbital_period = seconds(5724); % StarLink satellites orbit period (1.59h)
connectivity_duration = seconds(420); % 7 min
gs_iots = ["MainIoT", "Node 1", "Node 2", "GS"];
sats = ["Satellite 1", "Satellite 2", "Satellite 3"];

% Map nodes and satellites to numeric indices for plotting
node_map = containers.Map(gs_iots, 1:length(gs_iots));
sat_map = containers.Map(sats, 1:length(sats));

% Initialize arrays for 3D plot
x_sat = [];
y_iot = [];
z_time = [];
iot_edges = [];
edge_labels = [];

% Loop through the data to identify connections between nodes
for i = 1:height(data)
    source = data.Source{i};
    target = data.Target{i};
    start_time = data.StartTime(i);
    duration = seconds(data.Duration(i));
    end_time = start_time + duration;

    if isKey(node_map, target) && isKey(sat_map, source)
        x_sat = [x_sat; sat_map(source), sat_map(source)];
        y_iot = [y_iot; node_map(target), node_map(target)];
        z_time = [z_time; start_time, end_time];
        iot_edges = [iot_edges; {source, target}];
        edge_labels = [edge_labels; {datestr(start_time, 'HH:MM:SS')}];
    end
end

% Create Interactive UI
f = figure('Name', 'Interactive 3D Plot', 'NumberTitle', 'off', 'Position', [100, 100, 800, 600]);

% Create axes for 3D plot
ax = axes(f, 'Position', [0.1, 0.2, 0.8, 0.7]);
hold(ax, 'on');
grid(ax, 'on');
view(ax, 3);
xlabel(ax, 'Satellites');
ylabel(ax, 'IoT Nodes');
zlabel(ax, 'Time');
xticks(ax, 1:length(sats));
xticklabels(ax, sats);
yticks(ax, 1:length(gs_iots));
yticklabels(ax, gs_iots);
datetick(ax, 'z', 'HH:MM:SS', 'keepticks');
title(ax, '3D Connectivity Plot');

% Plot lines representing connectivity intervals
for i = 1:size(x_sat, 1)
    plot3(ax, x_sat(i, 1), y_iot(i, 1), z_time(i, 1), 'ko', 'MarkerFaceColor', 'k'); % Starting point
    plot3(ax, x_sat(i, :), y_iot(i, :), z_time(i, :), 'LineWidth', 2, 'LineStyle', '--'); % Dashed line for start
    plot3(ax, x_sat(i, 2), y_iot(i, 2), z_time(i, 2), 'ko'); % Ending point
    plot3(ax, x_sat(i, :), y_iot(i, :), z_time(i, :), 'LineWidth', 2, 'LineStyle', '-'); % Solid line for duration
end

% Create dropdown menus for selecting source and target nodes
uicontrol('Style', 'text', 'String', 'Source Node:', 'Position', [10, 60, 80, 20]);
source_menu = uicontrol('Style', 'popupmenu', 'String', gs_iots, 'Position', [100, 60, 100, 20]);

uicontrol('Style', 'text', 'String', 'Target Node:', 'Position', [220, 60, 80, 20]);
target_menu = uicontrol('Style', 'popupmenu', 'String', gs_iots, 'Position', [310, 60, 100, 20]);

% Create button to highlight the path
uicontrol('Style', 'pushbutton', 'String', 'Highlight Path', 'Position', [420, 60, 100, 20], ...
    'Callback', {@highlight_path, ax, data, gs_iots, sats, source_menu, target_menu, connectivity_duration, orbital_period, node_map, sat_map});

function highlight_path(~, ~, ax, data, gs_iots, sats, source_menu, target_menu, connectivity_duration, orbital_period, node_map, sat_map)
    % Clear previous highlights
    hold(ax, 'on');
    delete(findobj(ax, 'Type', 'Line', 'Color', 'r'));

    % Get selected source and target nodes
    source_node = gs_iots{get(source_menu, 'Value')};
    target_node = gs_iots{get(target_menu, 'Value')};

    % Perform the process to find the minimal duration path
    [updated_iot_edges, updated_edg_labels] = find_relevant_hop_connections(data, gs_iots, sats, source_node, target_node, connectivity_duration, orbital_period);

    % Ensure node names are properly formatted as character vectors
    updated_iot_edges = cellfun(@char, updated_iot_edges, 'UniformOutput', false)

    % Highlight the minimal duration path
    G_updated = digraph(updated_iot_edges(:, 1), updated_iot_edges(:, 2));
    for i = 1:size(updated_iot_edges, 1)
        edge_idx = findedge(G_updated, updated_iot_edges{i, 1}, updated_iot_edges{i, 2});
        if edge_idx > 0
            plot3(ax, [sat_map(updated_iot_edges{i, 1}), sat_map(updated_iot_edges{i, 1})], ...
                  [node_map(updated_iot_edges{i, 2}), node_map(updated_iot_edges{i, 2})], ...
                  [datenum(updated_edg_labels{i}, 'HH:MM:SS'), datenum(updated_edg_labels{i}, 'HH:MM:SS') + datenum(connectivity_duration)], ...
                  'r', 'LineWidth', 3); % Highlighted in red
        end
    end
end

function [updated_iot_edges, updated_edg_labels] = find_relevant_hop_connections(data, gs_iots, sats, source_node, target_node, connectivity_duration, orbital_period)
    % Initialize updated edges and labels
    updated_iot_edges = [];
    updated_edg_labels = [];

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

                % Format the start time as HH:MM:SS
                start_times_str = datestr(first_start_time, 'HH:MM:SS');

                % Update the edges and labels
                updated_iot_edges = [updated_iot_edges; {char(sat), char(iot)}];
                updated_edg_labels = [updated_edg_labels; {start_times_str}];
            end
        end
    end

    % Calculate delays and find relevant hop connections
    delays = {};
    for i = 1:length(gs_iots)
        if i > 1 && i < length(gs_iots)
            j = i;
            while j ~= 2
                j = j - 1;
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
                        delays{end + 1} = {iot1, iot2, delay, sat};
                    end
                end
            end
        end

        for j = i:length(gs_iots)
            if i ~= j
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
                        delays{end + 1} = {iot1, iot2, delay, sat};
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

    % Find the shortest path from source_node to target_node
    [shortest_path, ~] = shortestpath(G_updated, source_node, target_node);

    % Extract the edges and labels for the shortest path
    updated_iot_edges = {};
    updated_edg_labels = {};
    for i = 1:length(shortest_path) - 1
        node1 = shortest_path(i);
        node2 = shortest_path(i + 1);
        edge_idx = findedge(G_updated, node1, node2);
        if edge_idx > 0
            updated_iot_edges = [updated_iot_edges; {node1, node2}];
            updated_edg_labels = [updated_edg_labels; edg_labels{edge_idx}];
        end
    end
end

function [min_val, min_idx] = min_del(X)
    min_val = X(1);
    min_idx = 1;
    for i = 2:length(X)
        if X(i) < min_val
            min_val = X(i);
            min_idx = i;
        end
    end
end

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
