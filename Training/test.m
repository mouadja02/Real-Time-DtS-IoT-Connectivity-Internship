clc; close all;

min_distances = [1420.8,1665.5,502.5379,891.0503,685.5408,625.6659,387.5504,432.0688,1330.5,720.5052,1364.2,2404.5];
durations = [635,580,690,715,685,685,755,750,605,730,650,235];
min_distances2 = [1745.63,1356.98,229.02,1199.92,367.87,388.08,636.66,733,1176.06,902.98,1689.49,2310.12];
durations2 = [560,645,705,675,695,700,740,730,630,715,575,305];

% Plotting minimal distance vs duration for a specific IoT
figure;
hold on;
plot(durations,min_distances, 'o');
plot(durations2,min_distances2, 'o');
hold off;
xlabel('Minimal Distance (km)');
ylabel('Duration (s)');
title(sprintf('Distance vs Duration for IoT Devices'));