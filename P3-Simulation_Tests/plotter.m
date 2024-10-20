clear all; close all; clc;

% Load data from the text file
data = readtable('cpu_time_and_delays2.txt');

% Extract columns
satellites = data.NumberofSatellites;
nodes = data.NumberofNodes;
bruteforce_delay = data.BruteforceDelay;
floydwarshall_delay = data.FloydWarshallDelay;
bruteforce_time = data.BruteforceCPUTime;
floydwarshall_time = data.FloydWarshallCPUTime;

% 3D Plot for delays
figure;
trisurf(delaunay(satellites, nodes), satellites, nodes, floydwarshall_delay, 'FaceColor', 'interp', 'EdgeColor', 'none');
title('Brute-force delay');
xlabel('Number of satellites');
ylabel('Number of nodes');
zlabel('Delay (seconds)');
colorbar;
view(3);

figure;
trisurf(delaunay(satellites, nodes), satellites, nodes, floydwarshall_delay, 'FaceColor', 'interp', 'EdgeColor', 'none');
title('Floyd-Warshall delay');
xlabel('Number of satellites');
ylabel('Number of nodes');
zlabel('Delay (seconds)');
colorbar;
view(3);


% Plot Brute-force CPU times
figure;
trisurf(delaunay(satellites, nodes), satellites, nodes, bruteforce_time, 'FaceColor', 'interp', 'EdgeColor', 'none');
title('Brute-force CPU time');
xlabel('Number of satellites');
ylabel('Number of nodes');
zlabel('CPU time (seconds)');
grid on;
colorbar;
view(3);

% Plot Floyd-Warshall CPU times
figure;
trisurf(delaunay(satellites, nodes), satellites, nodes, floydwarshall_time, 'FaceColor', 'interp', 'EdgeColor', 'none');
title('Floyd-Warshall CPU time');
xlabel('Number of satellites');
ylabel('Number of nodes');
zlabel('CPU time (seconds)');
grid on;
colorbar;

view(3);
%%
% Number of satellites
numSatellites = [6, 8, 10, 12, 14, 16, 18, 20, 22, 24];

% Routing delays (Brute-force and Floyd-Warshall)
routingDelayBruteForce = [4200, 2120, 1620, 1565, 1230, 900, 865, 645, 645, 480];
routingDelayFloydWarshall = [5410, 2380, 1620, 1565, 1230, 900, 865, 645, 645, 480];

% CPU times (Brute-force and Floyd-Warshall)
cpuTimeBruteForce = [0.364, 2.181, 6.411, 17.99, 67.35, 167.42, 254.88, 1026.26, 759.9, 1456.81];
cpuTimeFloydWarshall = [0.06, 0.053, 0.034, 0.032, 0.053, 0.029, 0.055, 0.03, 0.033, 0.056];

% Create a figure with subplots
figure;

% Subplot 1: Routing delays
subplot 211;
hold on;
plot(numSatellites, routingDelayBruteForce, '-o', 'DisplayName', 'Brute-force');
plot(numSatellites, routingDelayFloydWarshall, '-x', 'DisplayName', 'Floyd-Warshall');
title('Routing delays vs Number of satellites (11 IoT devices and 1 ground station)');
ylabel('Routing delay (seconds)');
legend('show');
grid on;
hold off;

% Subplot 2: CPU times with separate y-axes
subplot 212;
yyaxis left;
plot(numSatellites, cpuTimeBruteForce, '-o', 'DisplayName', 'Brute-force');
ylabel('Brute-force CPU time (seconds)');
xlabel('Number of satellites');
title('CPU time vs Number of satellites (11 IoT devices and 1 ground station)');

yyaxis right;
plot(numSatellites, cpuTimeFloydWarshall, '-x', 'DisplayName', 'Floyd-Warshall');
ylabel('Floyd-Warshall CPU time (seconds)');
legend('Brute-force', 'Proposed FW-Routing');
grid on;

%%
% Read data from Brute-force and Dijkstra algorithms
data1 = readtable('routing_simulation_results.csv');

% Filter data for different numbers of nodes
nodes12_1 = data1(data1.Number_of_Nodes == 12, :);
nodes18_1 = data1(data1.Number_of_Nodes == 18, :);
nodes24_1 = data1(data1.Number_of_Nodes == 24, :);
x = nodes12_1.Number_of_Sats;

% Read data from Floyd-Warshall algorithm
data2 = readtable('FW_simulation_results.csv');

% Filter data for different numbers of nodes
nodes12_2 = data2(data2.Number_of_Nodes == 12, :);
nodes18_2 = data2(data2.Number_of_Nodes == 18, :);
nodes24_2 = data2(data2.Number_of_Nodes == 24, :);

% Plotting CPU times for Brute-force and Dijkstra
figure;
semilogy(x, nodes24_1.Avg_CPU_Time_Bruteforce, '-p', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '22 relay nodes (Brute force)');
hold on;
semilogy(x, nodes18_1.Avg_CPU_Time_Bruteforce, '-^', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '16 relay nodes (Brute force)');
semilogy(x, nodes12_1.Avg_CPU_Time_Bruteforce, '-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '10 relay nodes (Brute force)');
semilogy(x, nodes24_1.Avg_CPU_Time_Dijkstra, '--p', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '22 relay nodes (Dijkstra)');
semilogy(x, nodes18_1.Avg_CPU_Time_Dijkstra, '--^', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '16 relay nodes (Dijkstra)');
semilogy(x, nodes12_1.Avg_CPU_Time_Dijkstra, '--o', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '10 relay nodes (Dijkstra)');

% Plotting CPU times for Floyd-Warshall
semilogy(x, nodes24_2.Avg_CPU_Time_FW, '-.h', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '22  relay nodes (Floyd-Warshall)');
semilogy(x, nodes18_2.Avg_CPU_Time_FW, '-.d', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '16  relay nodes (Floyd-Warshall)');
semilogy(x, nodes12_2.Avg_CPU_Time_FW, '-.s', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '10  relay nodes (Floyd-Warshall)');

% Enhancing the plot
xlabel('Number of Satellites');
ylabel('CPU Time (seconds)');
title('CPU Time vs. Number of Satellites');
grid on;

% Adding legend
legend('Location', 'northwest', 'FontSize', 10);

% Optional: Smoothing curves using interpolation (if needed)
% xq = linspace(min(x), max(x), 100); % Fine grid for interpolation
% for i = 1:numel(x)
%     yq_bruteforce12 = interp1(x, nodes12_1.Avg_CPU_Time_Bruteforce, xq, 'pchip');
%     semilogy(xq, yq_bruteforce12, '-o', 'LineWidth', 1.5);
%     % Similarly, you can interpolate for the other curves
% end
%%
% Read data from Brute-force and Dijkstra algorithms
data1 = readtable('routing_simulation_results4.csv');

% Filter data for different numbers of nodes
nodes12_1 = data1(data1.Number_of_Nodes == 12, :);
nodes18_1 = data1(data1.Number_of_Nodes == 18, :);
nodes24_1 = data1(data1.Number_of_Nodes == 24, :);
x = nodes12_1.Number_of_Sats;


% Plotting CPU times for Brute-force and Dijkstra
figure;
plot(x, nodes24_1.Accuracy, '-p', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '22 relay nodes (Brute force)');
hold on;
plot(x, nodes18_1.Accuracy, '-^', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '16 relay nodes (Brute force)');
plot(x, nodes12_1.Accuracy, '-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '10 relay nodes (Brute force)');

% Enhancing the plot
xlabel('Number of Satellites');
ylabel('CPU Time (seconds)');
title('Accuracy vs. Number of Satellites');
grid on;

% Adding legend
legend('Location', 'northwest', 'FontSize', 10);

%%
data1 = readtable('routing_simulation_results.csv');

% Filter data for different numbers of nodes
nodes12_1 = data1(data1.Number_of_Nodes == 12, :);
nodes18_1 = data1(data1.Number_of_Nodes == 18, :);
nodes24_1 = data1(data1.Number_of_Nodes == 24, :);
x = nodes12_1.Number_of_Sats;



% Plotting Routing Delays
figure;
plot(x, nodes12_1.Bruteforce_Delay, '-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '10 relay nodes (Brute force)');
hold on;
plot(x,  nodes18_1.Bruteforce_Delay, '-^','LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '16 relay nodes (Brute force)');
plot(x, nodes24_1.Bruteforce_Delay, '-p', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '22 relay nodes (Brute force)');
plot(x, nodes12_1.Dijkstra_Delay, '--o', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '10 relay nodes (Dijkstra)');
plot(x, nodes18_1.Dijkstra_Delay, '--^', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '16 relay nodes (Dijkstra)');
plot(x, nodes24_1.Dijkstra_Delay, '--p', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '22 relay nodes (Dijkstra)');
xlabel('Number of Satellites');
ylabel('Routing Delay (seconds)');
legend('show');
title('Modified Dijkstra Algorithm accuracy evaluation');
grid on;

%%



% Plotting Routing Delays
figure;
plot(x, nodes12_1.Bruteforce_Delay, '-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '10 relay nodes (Brute force)');
hold on;
plot(x,  nodes18_1.Bruteforce_Delay, '-^','LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '16 relay nodes (Brute force)');
plot(x, nodes24_1.Bruteforce_Delay, '-p', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '22 relay nodes (Brute force)');
xlabel('Number of Satellites');
ylabel('Routing Delay (seconds)');
legend('show');
title('Brute force Routing Delay vs. Number of Satellites');
plot(x, nodes12_2.FW_Delay, '--o', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '10 relay nodes (Floyd-Warshall)');
plot(x, nodes18_2.FW_Delay, '--^', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '16 relay nodes (Floyd-Warshall)');
plot(x, nodes24_2.FW_Delay, '--p', 'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', '22 relay nodes (Floyd-Warshall)');
xlabel('Number of Satellites');
ylabel('Routing Delay (seconds)');
legend('show');
title('Floyd-Warshall Routing Delay vs. Number of Satellites');
grid on;
%%

data = readtable('FW_simulation_results.csv');

nodes12 = data(data.Number_of_Nodes == 12, :);
nodes18 = data(data.Number_of_Nodes == 18, :);
nodes24 = data(data.Number_of_Nodes == 24, :);
x = nodes12.Number_of_Sats;

%%

% Plotting CPU times
figure;
semilogy(x, nodes12.Avg_CPU_Time_FW, '-o', 'DisplayName', '12 Nodes Floyd-Warshall');
hold on;
semilogy(x, nodes18.Avg_CPU_Time_FW, '-^', 'DisplayName', '18 Nodes Floyd-Warshall');
semilogy(x, nodes24.Avg_CPU_Time_FW, '-p', 'DisplayName', '24 Nodes Floyd-Warshall');
xlabel('Number of Satellites');
ylabel('CPU Time (seconds)');
legend('show');
title('CPU Time vs. Number of Satellites');
grid on;
%%
% Plotting Routing Delays
figure;
plot(x, nodes12.FW_Delay, '-o', 'DisplayName', '12 Nodes');
hold on;
plot(x,  nodes18.FW_Delay, '-^', 'DisplayName', '18 Nodes');
plot(x, nodes24.FW_Delay, '-p', 'DisplayName', '24 Nodes');
xlabel('Number of Satellites');
ylabel('Routing Delay (seconds)');
legend('show');
title('Floyd-Warshall Routing Delay vs. Number of Satellites');
grid on;

%%
% Plotting Routing Delays
data = readtable('routing_simulation_results.csv');
data2 = readtable('FW_simulation_results.csv');

nodes12 = data(data.Number_of_Nodes == 12, :);
nodes18 = data(data.Number_of_Nodes == 18, :);
nodes24 = data(data.Number_of_Nodes == 24, :);
x = nodes12.Number_of_Sats;

nodes12_ = data2(data2.Number_of_Nodes == 12, :);
nodes18_ = data2(data2.Number_of_Nodes == 18, :);
nodes24_ = data2(data2.Number_of_Nodes == 24, :);


figure;
plot(x, nodes12.Bruteforce_Delay, '-o', 'DisplayName', '12 Nodes');
hold on;
plot(x,  nodes18.Bruteforce_Delay, '-^', 'DisplayName', '18 Nodes');
plot(x, nodes24.Bruteforce_Delay, '-p', 'DisplayName', '24 Nodes');
plot(x, nodes12.Dijkstra_Delay, '--o', 'DisplayName', '12 Nodes');
plot(x, nodes18.Dijkstra_Delay, '--^', 'DisplayName', '18 Nodes');
plot(x, nodes24.Dijkstra_Delay, '--p', 'DisplayName', '24 Nodes');
plot(x, nodes12_.FW_Delay, '-o', 'DisplayName', '12 Nodes');
plot(x,  nodes18_.FW_Delay, '-^', 'DisplayName', '18 Nodes');
plot(x, nodes24_.FW_Delay, '-p', 'DisplayName', '24 Nodes');
grid on;
xlabel('Number of Satellites');
ylabel('Routing Delay (seconds)');
legend('show');
title('Floyd-Warshall Routing Delay vs. Number of Satellites');
grid on;

%%
data = readtable('routing_simulation_results4.csv');
nodes12 = data(data.Number_of_Nodes == 12, :);
nodes18 = data(data.Number_of_Nodes == 18, :);
nodes24 = data(data.Number_of_Nodes == 24, :);
x = nodes18.Number_of_Sats;

figure;
%plot(x, nodes12.FW_Accuracy, '-o', 'DisplayName', '12 Nodes Floyd-Warshall');
plot(x, nodes18.FW_Accuracy, '-o', 'DisplayName', '16 relay nodes');
hold on;
plot(x, nodes24.FW_Accuracy, '-o', 'DisplayName', '22 relay nodes');
hold off;
xlabel('Number of Satellites');
ylabel('Accuracy (%)');
legend('show');
title('Floyd-Warshall Algorithm Accuracy Evaluation');
grid on;

%%
% Load the CSV file
file_path = 'R1_R2_R3_BF_results_2.csv';
data = readtable(file_path);

% Extract unique values for the number of nodes to create separate plots
unique_nodes = unique(data.Number_of_Nodes);

% Create subplots
num_subplots = length(unique_nodes);
figure;

% Loop through each unique number of nodes and plot
for i = 1:num_subplots
    node = unique_nodes(i);
    node_data = data(data.Number_of_Nodes == node, :);
    
    subplot(num_subplots, 1, i);
    plot(node_data.Number_of_Sats, node_data.BF1_CPU_time, '-o', 'DisplayName', 'Bruteforce CPU Time Without Reduction');
    hold on;
    plot(node_data.Number_of_Sats, node_data.R_BF_total_time, '-o', 'DisplayName', 'Total CPU Time After Reduction');
    
    title([num2str(node), ' Relay Nodes']);
    xlabel('Number of Satellites');
    ylabel('CPU Time (s)');
    legend;
    grid on;
end

% Adjust layout
tightfig;
