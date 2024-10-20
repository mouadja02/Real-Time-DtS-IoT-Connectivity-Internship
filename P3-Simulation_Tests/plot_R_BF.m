clear all; close all; clc;

% List of CSV files
csv_files = {
    'R1_BF_results.csv', ...
    'R1_R2_R3_BF_results.csv', ...
    'R1_R2_R3_R5_BF_results.csv'
};

% Map reductions to descriptions
reduction_map = containers.Map();
reduction_map('R1') = 'Ignore delays higher or equal to dNR';
reduction_map('R2') = 'Ignore visibility windows after latest visibility to Ground station';
reduction_map('R3') = 'Ignore visibility windows before first visibility to source node';
reduction_map('R4') = 'The backward simplification';
reduction_map('R5') = 'Ignore rows and columns with only one delay different than infinity';

% Cases of number of nodes
num_nodes_cases = [12, 18, 24];

for i = 1:length(csv_files)
    % Load CSV file
    data = readtable(csv_files{i});
    
    % Debugging: Display the size of the data
    disp(['Processing file: ', csv_files{i}]);
    disp('Data size:');
    disp(size(data));
    
    % Extract the number of satellites, BF_CPU_time, and R_BF_CPU_time
    num_sats = data{1:10, 2};  % Assuming the first column is the number of satellites
    
    % Split the data into BF_CPU_time and R_BF_CPU_time
    BF_CPU_time = data{:, 3};
    R_BF_CPU_time = data{:, 4};
    
    % Create a figure with 3 subplots
    figure;
    for j = 1:length(num_nodes_cases)
        subplot(3, 1, j);
        plot(num_sats, BF_CPU_time((j-1)*10+1:(j-1)*10+10, :), '-o', 'DisplayName', 'BF CPU Time');
        hold on;
        plot(num_sats, R_BF_CPU_time((j-1)*10+1:(j-1)*10+10, :), '-x', 'DisplayName', 'R BF CPU Time');
        hold off;
        
        % Add labels and title
        xlabel('Number of Satellites');
        ylabel('CPU Time (s)');
        title_str = sprintf('Nodes: %d - Reductions: %s', num_nodes_cases(j), csv_files{i});
        title(title_str, 'Interpreter', 'none');
        legend('show');
    end
    
end

%%
clear all; close all; clc;

% List of CSV files
csv_files = {
    'R1_BF_results_2.csv', ...
    'R1_R2_BF_results_2.csv', ...
    'R1_R2_R3_BF_results_2.csv'
};

% Map reductions to descriptions
reduction_map = containers.Map();
reduction_map('R1') = 'Ignore delays higher or equal to dNR';
reduction_map('R2') = 'Ignore visibility windows after latest visibility to Ground station';
reduction_map('R3') = 'Ignore visibility windows before first visibility to source node';
reduction_map('R4') = 'The backward simplification';
reduction_map('R5') = 'Ignore rows and columns with only one delay different than infinity';

% Cases of number of nodes
num_nodes_cases = [12, 18, 24];

for i = 1:length(csv_files)
    % Load CSV file
    data = readtable(csv_files{i});
    
    % Debugging: Display the size of the data
    disp(['Processing file: ', csv_files{i}]);
    disp('Data size:');
    disp(size(data));
    
    % Extract the number of satellites, BF_CPU_time, and R_BF_CPU_time
    num_sats = data{1:10, 2};  % Assuming the first column is the number of satellites
    
    % Split the data into BF_CPU_time and R_BF_CPU_time
    BF1_CPU_time = data{:, 3};
    R_CPU_time = data{:, 4};
    BF2_CPU_time = data{:, 5};

    R_BF_CPU_time = data{:, 6};
    
    % Create a figure with 3 subplots
    figure;
    for j = 1:length(num_nodes_cases)
        subplot(3, 1, j);
        plot(num_sats, BF1_CPU_time((j-1)*10+1:(j-1)*10+10, :), '-o', 'DisplayName', 'BF1 CPU Time');
        hold on;
        plot(num_sats, R_CPU_time((j-1)*10+1:(j-1)*10+10, :), '-x', 'DisplayName', 'R CPU Time');
        plot(num_sats, BF2_CPU_time((j-1)*10+1:(j-1)*10+10, :), '-x', 'DisplayName', 'BF2 CPU Time');
        plot(num_sats, R_BF_CPU_time((j-1)*10+1:(j-1)*10+10, :), '-x', 'DisplayName', 'R BF CPU Time');
        hold off;
        
        % Add labels and title
        xlabel('Number of Satellites');
        ylabel('CPU Time (s)');
        title_str = sprintf('Nodes: %d - Reductions: %s', num_nodes_cases(j), csv_files{i});
        title(title_str, 'Interpreter', 'none');
        legend('show');
    end
    
end

%%

clear all; close all; clc;

% List of CSV files
csv_files = {
    'R1_BF_results_2.csv', ...
    'R1_R2_BF_results_2.csv', ...
    'R1_R2_R3_BF_results_2.csv'
};

% Map reductions to descriptions
reduction_map = containers.Map();
reduction_map('R1') = 'Ignore delays higher or equal to dNR';
reduction_map('R2') = 'Ignore visibility windows after latest visibility to Ground station';
reduction_map('R3') = 'Ignore visibility windows before first visibility to source node';
reduction_map('R4') = 'The backward simplification';
reduction_map('R5') = 'Ignore rows and columns with only one delay different than infinity';

% Cases of number of nodes
num_nodes_cases = [12, 18, 24];

% Define colors for each case
colors = {'r', 'g', 'b'};

for i = 1:length(csv_files)
    % Load CSV file
    data = readtable(csv_files{i});
    
    % Extract the number of satellites, BF_CPU_time, and R_BF_CPU_time
    num_sats = data{1:10, 2};  % Assuming the first column is the number of satellites
    
    % Split the data into BF1_CPU_time, R_CPU_time, BF2_CPU_time, and R_BF_CPU_time
    BF1_CPU_time = data{:, 3};
    R_CPU_time = data{:, 4};
    BF2_CPU_time = data{:, 5};
    R_BF_CPU_time = data{:, 6};
    figure;
    for j = 1:length(num_nodes_cases)
        % Plot BF1 and R_BF for each node case with specified markers and colors
        plot(num_sats, BF1_CPU_time((j-1)*10+1:(j-1)*10+10, :), '-s', 'Color', colors{j}, 'DisplayName', sprintf('CPU Time without reductions - Nodes: %d', num_nodes_cases(j)));
        hold on;
        plot(num_sats, R_BF_CPU_time((j-1)*10+1:(j-1)*10+10, :), '-^', 'Color', colors{j}, 'DisplayName', sprintf('CPU Time after reductions - Nodes: %d', num_nodes_cases(j)));
    end

    % Add labels and title
    xlabel('Number of Satellites');
    ylabel('CPU Time (s)');
    title_str = sprintf('CPU Time vs Number of Satellites\nwith applied reductions: %s', num_nodes_cases(j), csv_files{i});
    title(title_str);
    legend('show');
end
