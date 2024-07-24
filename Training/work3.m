% Make sure to have the Statistics and Machine Learning Toolbox for categorical variables
% and the Aerospace Toolbox for Unix time conversion

% Load the CSV file
file_path = 'access_intervals.csv';  % Use the correct path to your CSV file
data = readtable(file_path);

% Convert 'Source' and 'Target' from categorical to numeric values for plotting
data.Source_id = grp2idx(categorical(data.Source));
data.Target_id = grp2idx(categorical(data.Target));

% Convert 'StartTime' and 'EndTime' to datetime objects and to Unix timestamps
data.StartTime = datetime(data.StartTime);
data.EndTime = datetime(data.EndTime);
data.StartTime_Z = posixtime(data.StartTime);
data.EndTime_Z = posixtime(data.EndTime);

% Define a function to map original names to custom labels
function label = map_to_custom_label(name)
    if contains(name, 'IoT Device')
        label = ['N' name(find(isspace(name),1,'last')+1:end)];  % Convert 'IoT Device X' to 'N1'
    elseif contains(name, 'Satellite')
        label = ['Sat' name(find(isspace(name),1,'last')+1:end)];  % Convert 'Satellite X' to 'Sat1'
    elseif contains(name, 'Ground Station')
        label = 'GS';  % Convert 'Ground Station' to 'GS'
    else
        label = name;
    end
end

% Apply the mapping function to generate custom labels for Source and Target
data.CustomSource = cellfun(@map_to_custom_label, data.Source, 'UniformOutput', false);
data.CustomTarget = cellfun(@map_to_custom_label, data.Target, 'UniformOutput', false);

% Initialize vectors for plotting
x_lines = [];
y_lines = [];
z_lines_start = [];
z_lines_end = [];
x_peaks = [];
y_peaks = [];
z_peaks = [];
hover_texts_peaks = {};

% Populate vectors with line segment start, end coordinates, and peak points
for idx = 1:height(data)
    x_lines = [x_lines; data.Source_id(idx); data.Source_id(idx); NaN];
    y_lines = [y_lines; data.Target_id(idx); data.Target_id(idx); NaN];
    z_lines_start = [z_lines_start; data.StartTime_Z(idx)];
    z_lines_end = [z_lines_end; data.EndTime_Z(idx)];

    % Add the end (peak) of each line as a marker point
    x_peaks = [x_peaks; data.Source_id(idx)];
    y_peaks = [y_peaks; data.Target_id(idx)];
    z_peaks = [z_peaks; data.EndTime_Z(idx)];
    hover_texts_peaks{end+1} = sprintf('Source: %s\nTarget: %s\nEnd Time: %s\nDuration: %d seconds', ...
        data.CustomSource{idx}, data.CustomTarget{idx}, datestr(data.EndTime(idx)), data.Duration(idx));
end

% Create the 3D plot with lines and markers
figure;
hold on;

% Add line segments
for i = 1:3:length(x_lines)
    plot3(x_lines(i:i+1), y_lines(i:i+1), [z_lines_start((i+2)/3); z_lines_end((i+2)/3)], 'b-', 'LineWidth', 3);
end

% Add markers at the end of each line segment (peaks)
scatter3(x_peaks, y_peaks, z_peaks, 50, 'r', 'filled');

% Add hover text
dx = 0.1; dy = 0.1; % displacement so the text does not overlay the data points
for i=1:length(hover_texts_peaks)
    text(x_peaks(i)+dx, y_peaks(i)+dy, z_peaks(i), hover_texts_peaks{i}, 'Interpreter', 'none');
end

% Set the labels for the axes
xticks(unique(data.Source_id));
xticklabels(data.CustomSource(unique(data.Source_id)));
xlabel('Source');

yticks(unique(data.Target_id));
yticklabels(data.CustomTarget(unique(data.Target_id)));
ylabel('Target');

zlabel('Time');

% Set the view
view(3);

% Customize the plot appearance
grid on;
title('3D Visualization of Access Intervals');
hold off;
