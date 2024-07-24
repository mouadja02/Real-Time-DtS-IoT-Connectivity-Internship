% MATLAB Script to Generate IoT-Satellite Hierarchical Graph
function plot_iot_graph()
    % Define the node levels and connections
    levels = {
        {'IoT_main'}, ...        % Level 0
        {'Sat1', 'Sat2'}, ...    % Level 1
        {'IoT1', 'IoT2'}, ...    % Level 2
        {'Sat3', 'Sat4'}, ...    % Level 3
        % Add more levels as necessary
    };

    % Define the connections between levels
    connections = {
        [1, 1], [1, 2], ...    % IoT_main -> Satellites (Level 0 to 1)
        [2, 1], [2, 2], ...    % Sat1 -> IoTs (Level 1 to 2)
        [3, 1], [3, 2] ...     % IoT1 -> Satellites (Level 2 to 3)
        % Add more connections as necessary
    };

    % Create graph and plot
    figure;
    hold on;
    node_labels = [];
    node_positions = [];
    node_count = 0;

    % Assign nodes their positions
    for level = 1:length(levels)
        nodes = levels{level};
        y = -level;
        for i = 1:length(nodes)
            node_count = node_count + 1;
            x = i * 2;
            node_positions(node_count, :) = [x, y];
            node_labels{node_count} = nodes{i};
            text(x, y, nodes{i}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 12);
            plot(x, y, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
        end
    end

    % Draw connections
    for i = 1:length(connections)
        src_idx = connections{i}(1);
        dst_idx = connections{i}(2);
        src_pos = node_positions(src_idx, :);
        dst_pos = node_positions(dst_idx, :);
        line([src_pos(1), dst_pos(1)], [src_pos(2), dst_pos(2)], 'Color', 'black', 'LineWidth', 1.5);
    end

    % Set plot limits and labels
    xlim([0, max(node_positions(:, 1)) + 2]);
    ylim([-length(levels) - 1, 0]);
    xlabel('Time');
    ylabel('Levels');
    title('IoT-Satellite Hierarchical Graph');
    hold off;
end
