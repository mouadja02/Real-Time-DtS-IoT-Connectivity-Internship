clc; close all;

% Load the data from the CSV file
data = readtable('access_intervals.csv');

% Convert time columns to datetime format
data.StartTime = datetime(data.StartTime, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');
data.EndTime = datetime(data.EndTime, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');

% Convert relevant columns to strings
data.Source = string(data.Source);
data.Target = string(data.Target);

% List of relevant IoT nodes
iot_nodes = ["MainIoT"; "GS"; unique(data.Target(contains(data.Target, 'Node')))];

% Initialize a map to hold edge data
edge_map = containers.Map('KeyType', 'char', 'ValueType', 'any');


% Populate the edge map
for i = 1:height(data)
    source = data.Source{i};
    target = data.Target{i};
    duration = data.Duration(i);
    satellite = source; % Assuming source is a satellite node

    % Only consider targets that are relevant IoT nodes
    if ismember(target, iot_nodes)
        % Find subsequent connections through the same satellite
        subsequent_connections = data(data.Source == satellite & ismember(data.Target, iot_nodes), :);

        for j = 1:height(subsequent_connections)
            end_node = subsequent_connections.Target{j};
            if ~strcmp(target, end_node)
                % Create a unique key for each pair of IoT nodes
                key = sprintf('%s-%s', target, end_node);
                label = sprintf('%s, %d sec', satellite, duration);

                % Aggregate information if the edge already exists
                if isKey(edge_map, key)
                    existing_data = edge_map(key);
                    existing_label = existing_data{1};
                    existing_duration = existing_data{2};

                    % Append satellite info to existing label and sum up durations
                    new_label = strcat(existing_label, ' | ', label);
                    new_duration = existing_duration + duration;
                    edge_map(key) = {new_label, new_duration};
                else
                    edge_map(key) = {label, duration};
                end
            end
        end
    end
end

% Extract edges and labels from the map
iot_edges = {};
edge_labels = {};
keys = edge_map.keys;


for k = 1:length(keys)
  
    edge = strsplit(keys{k}, '-');
    iot_edges = [iot_edges; edge];
    edge_data = edge_map(keys{k});
    edge_labels = [edge_labels; sprintf('%s | %d sec', edge_data{1}, edge_data{2})];
end

% Create a directed graph
G = digraph(iot_edges(:, 1), iot_edges(:, 2));

% Create figure
figure;
p = plot(G, 'Layout', 'force', 'NodeLabel', G.Nodes.Name, ...
         'EdgeLabel', edge_labels, 'LineWidth', 1.5, 'MarkerSize', 8);

% Define source and target nodes
source_node = "MainIoT";
target_node = "GS";

% Verify that both source and target nodes exist in the graph
if ismember(source_node, G.Nodes.Name) && ismember(target_node, G.Nodes.Name)
    all_paths = allpaths(G, source_node, target_node);
else
    error('One of the nodes "%s" or "%s" does not exist in the graph.', source_node, target_node);
end
% Highlight the source and target nodes
highlight(p, source_node, 'NodeColor', 'r', 'MarkerSize', 15);
highlight(p, target_node, 'NodeColor', 'g', 'MarkerSize', 15);

grid on;