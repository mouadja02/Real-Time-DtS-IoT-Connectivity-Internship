
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
x_peaks = data.Source_id;
y_peaks = data.Target_id;
z_peaks = data.EndTime_Z;

% Create the 3D plot with lines and markers
figure;
hold on;

% Plot line segments between start and end times
for i = 1:size(data, 1)
    plot3([data.Source_id(i); data.Source_id(i)], ...
          [data.Target_id(i); data.Target_id(i)], ...
          [data.StartTime_Z(i); data.EndTime_Z(i)], 'b-', 'LineWidth', 3);
end

% Add markers at the end of each line segment (peaks)
scatter3_handle = scatter3(x_peaks, y_peaks, z_peaks, 50, 'r', 'filled');

% Customize the plot appearance
grid on;
title('3D Visualization of Access Intervals');
hold off;

% Set data tips
dcm_obj = datacursormode(gcf);
set(dcm_obj,'UpdateFcn',{@myupdatefcn, data})

% This custom function creates the text for the data tips
function output_txt = myupdatefcn(~,event_obj, data)
    % Display the position of the data cursor
    % event_obj    Currently not used (empty)
    % data         Structure containing event data structure
    pos = get(event_obj, 'Position');
    idx = find(data.StartTime_Z == pos(3) & data.Source_id == pos(1) & data.Target_id == pos(2));
    
    output_txt = {['Source: ', data.CustomSource{idx}], ...
                      ['Target: ', data.CustomTarget{idx}], ...
                      ['End Time: ', datestr(data.EndTime(idx))], ...
                      ['Duration: ', num2str(data.Duration(idx)), ' seconds']};
    
end

% Set the labels for the axes
xticks(unique(data.Source_id));
xticklabels(data.CustomSource(unique(data.Source_id)));
xlabel('Source');

yticks(unique(data.Target_id));
yticklabels(data.CustomTarget(unique(data.Target_id)));
ylabel('Target');

zlabel('Time (Unix)');

% Set the view
view(3);

% Activate data cursor mode
datacursormode on;
