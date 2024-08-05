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
