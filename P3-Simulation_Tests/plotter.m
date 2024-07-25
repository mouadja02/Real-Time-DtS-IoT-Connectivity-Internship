% Number of satellites
numSatellites = [6, 8, 10, 12, 14, 16, 18, 20, 22, 24];

% Routing delays (Brute-force and Floyd-Warshall)
routingDelayBruteForce = [8424, 3030, 2035, 1710, 2040, 5725, 3570, 3740, 645, 795];
routingDelayFloydWarshall = [5410, 1120, 1620, 565, 665, 900, 865, 1105, 645, 795];

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
ylabel('Routing Delay');
legend('show');
grid on;
hold off;

% Subplot 2: CPU times with separate y-axes
subplot 212;
yyaxis left;
plot(numSatellites, cpuTimeBruteForce, '-o', 'DisplayName', 'Brute-force');
ylabel('Brute-force CPU Time (seconds)');
xlabel('Number of Satellites');
title('CPU time vs Number of satellites (11 IoT devices and 1 ground station)');

yyaxis right;
plot(numSatellites, cpuTimeFloydWarshall, '-x', 'DisplayName', 'Floyd-Warshall');
ylabel('Floyd-Warshall CPU Time (seconds)');
legend('Brute-force', 'Floyd-Warshall');
grid on;

%%
% Load data from the text file
data = readtable('cpu_time_and_delays.txt');

% Extract columns
satellites = data.NumberofSatellites;
nodes = data.NumberofNodes;
bruteforce_delay = data.BruteforceDelay;
floydwarshall_delay = data.FloydWarshallDelay;
bruteforce_time = data.BruteforceCPUTime;
floydwarshall_time = data.FloydWarshallCPUTime;

% 3D Plot for delays
figure;
subplot(1, 2, 1);
trisurf(delaunay(satellites, nodes), satellites, nodes, bruteforce_delay, 'FaceColor', 'interp', 'EdgeColor', 'none');
title('Brute-force Delay');
xlabel('Number of Satellites');
ylabel('Number of Nodes');
zlabel('Delay (seconds)');
colorbar;
view(3);

subplot(1, 2, 2);
trisurf(delaunay(satellites, nodes), satellites, nodes, floydwarshall_delay, 'FaceColor', 'interp', 'EdgeColor', 'none');
title('Floyd-Warshall Delay');
xlabel('Number of Satellites');
ylabel('Number of Nodes');
zlabel('Delay (seconds)');
colorbar;
view(3);

% 3D Line Plot for CPU times
figure;

% Plot Brute-force CPU times
subplot(1, 2, 1);
plot3(satellites, nodes, bruteforce_time, '-o', 'LineWidth', 1.5);
title('Brute-force CPU Time');
xlabel('Number of Satellites');
ylabel('Number of Nodes');
zlabel('CPU Time (seconds)');
grid on;
view(3);

% Plot Floyd-Warshall CPU times
subplot(1, 2, 2);!ùµ
plot3(satellites, nodes, floydwarshall_time, '-x', 'LineWidth', 1.5);
title('Floyd-Warshall CPU Time');
xlabel('Number of Satellites');
ylabel('Number of Nodes');
zlabel('CPU Time (seconds)');
grid on;
view(3);

view(3);
