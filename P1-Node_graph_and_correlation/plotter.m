clc; close all;

min_distances = [1420.8,1665.5,502.5379,891.0503,685.5408,625.6659,387.5504,432.0688,1330.5,720.5052,1364.2,2404.5];
durations = [635,580,690,715,685,685,755,750,605,730,650,235];

min_distances2 = [1745.63,1356.98,229.02,1199.92,367.87,388.08,636.66,733,1176.06,902.98,1689.49,2310.12];
durations2 = [560,645,705,675,695,700,740,730,630,715,575,305];

min_distances3 = [2059.13,635.10,46.18,1497.94,374.77,229.51,877.08,1432.97,1071.56,1077.61,2447.98,2243.73];
durations3 = [600,540,660,660,660,600,720,720,540,660,600,180];

min_distances4 = [1422.04027697145,1666.64392682666,501.841063319799,892.263776694481,686.494257915854,625.113413922975,388.424261664014,433.063922060382,1330.18274075453,722.164978305682,1368.05762627564,2404.54711820672];
durations4 = [635,580,690,715,685,685,755,750,605,730,650,235];

min_distances5 = [2505.94630708857,397.702615354167,376.103342152684,1922.36285496912,387.368597286486,885.311894680562,1218.50838803633,2424.89209379006,311.945133272286,1325.26020278652,1707.99638683581];
durations5 = [150,745,710,505,745,670,675,230,715,660,540];

X = [min_distances2,min_distances,min_distances5];
Y = [durations2,durations,durations5];

% Plotting minimal distance vs duration for a specific IoT
figure;
hold on;
%subplot 211;
plot(min_distances,durations, 'o');
%plot(min_distances,f(min_distances),'o');
plot(min_distances2,durations2, 'o');
plot(min_distances5,durations5, 'o');
%plot(durations3,min_distances3, 'o');
%subplot 212;
%plot(durations4,min_distances4, 'o');

hold off;
xlabel('Minimal Distance (km)');
ylabel('Duration (s)');
title('Distance vs Duration for IoT Devices');

%%


durations = [710,560,620,700,610,490,490,610,700,620,560,710,630,500,470,590,690,640,500,700,650,520,460,570,690];
distance_min = [84.0628801417904,1567.89390793251,1314.55773291133,135.070805421525,1231.70247023043,1836.50175082694,1837.42329161390,1234.15849258963,138.843191281854,1310.12389931243,1572.41890580140,87.9194356302311,1082.95909215498,1777.41568481163,1879.89979982467,1369.92943108501,342.315578094983,1057.86613465981,1835.28897345440,307.575979278737,921.558928538711,1702.53893108163,1905.78244424748,1491.51531199985,538.505954813012];
a1 = 0.2762;
b1 = 2.5499e+03;

durations2 = [1140,1010,760,1120,1120,1020,970,1050,1140,1070,490,540,1080,1140,1040,970,1020,1130,1110,730,1030,1140,1070,980,1000,1110];
distance_min2 = [110.348146302118,1835.41750884627,2825.56537583408,963.388529158917,586.311312606182,1610.90793001859,1908.70071932261,1407.43210561385,224.744632430164,1425.92598908608,3338.01900438520,3263.10389195331,1357.50185947500,279.791765739971,1439.77169378915,1912.03862964455,1584.38873477150,535.861731052890,1029.41512636393,2899.70161412594,1764.98520316663,51.8226254826376,1234.20785424596,1875.02021705611,1725.25510671349,821.684118574292];
a2 = 0.3079;
b2 = 3.7129e+03;

durations3 = [1520,1370,140,1070,1480,1500,1390,1360,1460,1520,1280,1230,1510,1470,1370,1370,1490,1500,1140,1350,1520,1450,1350,1400,1460];
distance_min3 = [141.278628409672,2095.07363265120,4297.33990274733,3250.64282329400,1130.82197963149,617.274893122887,1700.38367032705,1854.83499510153,1034.99740713991,541.630597672533,2575.65945059102,2757.77091772162,697.818995801174,928.115022516519,1822.00212713958,1751.52874189387,737.288935995986,967.157388002661,3065.88116724909,2273.25374502560,287.335722032289,1202.45769697465,1894.13591711320,1599.97710628663,405.229508465839];
a3 = 0.3536;
b3 = 4.3199e+03;
%%
clc;


% Données pour les trois altitudes de satellites
durations1 = [710,560,620,700,610,490,490,610,700,620,560,710,630,500,470,590,690,640,500,700,650,520,460,570,690];
distance_min1 = [84.0628801417904,1567.89390793251,1314.55773291133,135.070805421525,1231.70247023043,1836.50175082694,1837.42329161390,1234.15849258963,138.843191281854,1310.12389931243,1572.41890580140,87.9194356302311,1082.95909215498,1777.41568481163,1879.89979982467,1369.92943108501,342.315578094983,1057.86613465981,1835.28897345440,307.575979278737,921.558928538711,1702.53893108163,1905.78244424748,1491.51531199985,538.505954813012];
a1 = 0.2762;
b1 = 2549.9;

durations2 = [1140,1010,760,1120,1120,1020,970,1050,1140,1070,490,540,1080,1140,1040,970,1020,1130,1110,730,1030,1140,1070,980,1000,1110];
distance_min2 = [110.348146302118,1835.41750884627,2825.56537583408,963.388529158917,586.311312606182,1610.90793001859,1908.70071932261,1407.43210561385,224.744632430164,1425.92598908608,3338.01900438520,3263.10389195331,1357.50185947500,279.791765739971,1439.77169378915,1912.03862964455,1584.38873477150,535.861731052890,1029.41512636393,2899.70161412594,1764.98520316663,51.8226254826376,1234.20785424596,1875.02021705611,1725.25510671349,821.684118574292];
a2 = 0.3079;
b2 = 3712.9;

durations3 = [1520,1370,140,1070,1480,1500,1390,1360,1460,1520,1280,1230,1510,1470,1370,1370,1490,1500,1140,1350,1520,1450,1350,1400,1460];
distance_min3 = [141.278628409672,2095.07363265120,4297.33990274733,3250.64282329400,1130.82197963149,617.274893122887,1700.38367032705,1854.83499510153,1034.99740713991,541.630597672533,2575.65945059102,2757.77091772162,697.818995801174,928.115022516519,1822.00212713958,1751.52874189387,737.288935995986,967.157388002661,3065.88116724909,2273.25374502560,287.335722032289,1202.45769697465,1894.13591711320,1599.97710628663,405.229508465839];
a3 = 0.3536;
b3 = 4319.9;

% Création de la figure
figure;
hold on;

%plot(10000, 10000, 'bo', 10000, 10000, 'b-','Color', [0, 0, 0]);


% Plot pour le premier satellite
theta = linspace(0, pi/2, 100);
x1 = b1 * cos(theta);
y1 = a1 * sqrt(b1^2 - x1.^2);
[f1,g1] = visibility_estimation(550,coverage_radius(550),x1);
plot(distance_min1, durations1, 'ro', x1, y1, 'r--');
plot(f1, g1, 'Color', 'r'); 
text(1850, a1 * sqrt(b1^2 - 1500^2)-50, 'Altitude 550km', 'Color', 'r');

% Plot pour le deuxième satellite
x2 = b2 * cos(theta);
y2 = a2 * sqrt(b2^2 - x2.^2);
[f2,g2] = visibility_estimation(1000,coverage_radius(1000),x2);
plot(distance_min2, durations2,'o','Color', [0, 0.5, 0]);
plot(x2, y2, 'Color', [0, 0.5, 0], 'LineStyle', '--'); % Dark green color with dashed line
plot(f2, g2, 'Color', [0, 0.5, 0]); % Dark green color with dashed line
text(2550, a2 * sqrt(b2^2 - 2500^2)+20, 'Altitude 1000km', 'Color', [0, 0.5, 0]);

% Plot pour le troisième satellite
x3 = b3 * cos(theta);
y3 = a3 * sqrt(b3^2 - x3.^2);
[f3,g3] = visibility_estimation(1800,coverage_radius(1800),x3);
plot(distance_min3, durations3, 'bo', x3, y3, 'b--');
plot(f3, g3, 'Color', 'b'); 
text(3300, a3 * sqrt(b3^2 - 3300^2)+150, 'Altitude 1800km', 'Color', 'b');

% Ajout de légendes et d'axes
legend('Simulation results', 'Curve fitting of simulation results','Theoretical curve','FontSize',10,'TextColor','black');
xlabel('Minimum Distance d_{min} (km)');
ylabel('Visibility Duration T_{con} (s)');
title('Correlation between minimum distance to orbit projection and connectivity duration');
grid on;

hold off;
%%
% Data
x = [6,8,10,12,14,16,18,20,22,24];

% Case 1 : 12 Nodes
CPU_12_BF = [0.358,0.329,1.475,3.137,9.624,25.52,27.01,36.75,51.37,140.72];
CPU_12_FW = [0.029,0.03,0.032,0.05,0.058,0.059,0.068,0.066,0.069,0.071];
delay_12_BF = [4235,4235,4145,3780,3235,3135,3135,2025,985,985];
delay_12_FW = [4235,4235,4145,3780,3235,3135,3135,2025,985,985];

% Case 2 : 18 Nodes
CPU_18_BF = [0.232,0.321,3.027,15.336,114.29,549.49,581.64,797.99,2497.56,4133.4];
CPU_18_FW = [0.042,0.051,0.054,0.053,0.064,0.062,0.071,0.076,0.084,0.09];
delay_18_BF = [4235,4235,4145,3755,3235,2045,1970,1805,590,460];
delay_18_FW = [4235,4235,4145,3755,3235,2045,1970,1805,590,460];

% Case 3 : 24 Nodes
CPU_24_BF = [23.93,36.48,237.22,308.02,379.66,1392.34,1850.32,2431.02,3862.29,5590.05];
CPU_24_FW = [0.044,0.058,0.064,0.071,0.080,0.095,0.103,0.105,0.119,0.122];
delay_24_BF = [3440,3440,3105,2245,2140,1555,1045,435,405,405];
delay_24_FW = [3440,3440,3105,2245,2140,1555,1045,435,405,405];

% Plotting CPU times
figure;
semilogy(x, CPU_24_BF, '-p', 'DisplayName', '22 relay nodes BF');
hold on;
semilogy(x, CPU_18_BF, '-^', 'DisplayName', '16 relay nodes BF');
semilogy(x, CPU_12_BF, '-o', 'DisplayName', '10 relay nodes BF');
semilogy(x, CPU_24_FW, '--p', 'DisplayName', '22 relay nodes FW');
semilogy(x, CPU_18_FW, '--^', 'DisplayName', '16 relay nodes FW');
semilogy(x, CPU_12_FW, '--o', 'DisplayName', '10 relay nodes FW');
xlabel('Number of Satellites');
ylabel('CPU Time (seconds)');
legend('show');
title('CPU Time vs. Number of Satellites');
grid on;
%%
% Plotting Routing Delays
figure;
plot(x, delay_12_BF, '-o', 'DisplayName', 'Brute force');
hold on;
% plot(x, delay_18_BF, '-^', 'DisplayName', '18 Nodes');
% plot(x, delay_24_BF, '-p', 'DisplayName', '24 Nodes');
% xlabel('Number of Satellites');
% ylabel('Routing Delay (seconds)');
% legend('show');
% title('Brute force Routing Delay vs. Number of Satellites');
% grid on;
% Plotting Routing Delays

plot(x, delay_12_FW, '--o', 'DisplayName', 'Floyd-Warshall');
% plot(x, delay_18_FW, '--^', 'DisplayName', '18 Nodes');
% plot(x, delay_24_FW, '--p', 'DisplayName', '24 Nodes');
xlabel('Number of Satellites');
ylabel('Routing Delay (seconds)');
legend('show');
title('Calculated Routing Delay vs. Number of Satellites (11 IoT devices and 1 Ground Station)');
grid on;



%%

% Data
x = [6,8,10,12,14,16,18,20,22,24];

% Case 1 : 12 Nodes
CPU_12_BF = [0.358,0.329,1.475,3.137,9.624,25.52,27.01,36.75,51.37,140.72];
CPU_12_FW = [0.029,0.03,0.032,0.05,0.058,0.059,0.068,0.066,0.069,0.071];
delay_12_BF = [4235,4235,4145,3780,3235,3135,1990,1530,985,985];
delay_12_FW = [4235,4235,4145,3780,3235,3135,1990,1530,985,985];

% Case 2 : 18 Nodes
CPU_18_BF = [0.232,0.321,3.027,15.336,114.29,549.49,581.64,797.99,2497.56,4133.4];
CPU_18_FW = [0.042,0.051,0.054,0.053,0.064,0.062,0.071,0.076,0.084,0.09];
delay_18_BF = [4235,4235,4145,3755,3235,2045,1970,800,590,460];
delay_18_FW = [4235,4235,4145,3755,3235,2045,1970,800,590,460];

% Case 3 : 24 Nodes
CPU_24_BF = [23.93,36.48,237.22,308.02,379.66,1392.34,1850.32,2431.02,3862.29,5590.05];
CPU_24_FW = [0.044,0.058,0.064,0.071,0.080,0.095,0.103,0.105,0.119,0.122];
delay_24_BF = [3440,3440,3105,2245,2140,1555,1045,435,405,405];
delay_24_FW = [3440,3440,3105,2245,2140,1555,1045,435,405,405];

% Plotting CPU times
figure;
semilogy(x, CPU_12_BF, '-o', 'DisplayName', '12 Nodes BF');
hold on;
semilogy(x, CPU_12_FW, '--o', 'DisplayName', '12 Nodes FW');
semilogy(x, CPU_18_BF, '-^', 'DisplayName', '18 Nodes BF');
semilogy(x, CPU_18_FW, '--^', 'DisplayName', '18 Nodes FW');
semilogy(x, CPU_24_BF, '-p', 'DisplayName', '24 Nodes BF');
semilogy(x, CPU_24_FW, '--p', 'DisplayName', '24 Nodes FW');
xlabel('Number of Satellites');
ylabel('CPU Time (seconds)');
legend('show');
title('CPU Time vs. Number of Satellites');
grid on;
%%
% Plotting Routing Delays
figure;
plot(x, delay_12_BF, '-o', 'DisplayName', '12 Nodes');
hold on;
plot(x, delay_18_BF, '-^', 'DisplayName', '18 Nodes');
plot(x, delay_24_BF, '-p', 'DisplayName', '24 Nodes');
xlabel('Number of Satellites');
ylabel('Routing Delay (seconds)');
legend('show');
title('Brute force Routing Delay vs. Number of Satellites');
grid on;
% Plotting Routing Delays
figure;
hold on;
plot(x, delay_12_FW, '--o', 'DisplayName', '12 Nodes');
plot(x, delay_18_FW, '--^', 'DisplayName', '18 Nodes');
plot(x, delay_24_FW, '--p', 'DisplayName', '24 Nodes');
xlabel('Number of Satellites');
ylabel('Routing Delay (seconds)');
legend('show');
title('Floyd-Warshall Routing Delay vs. Number of Satellites');
grid on;

%%
function duree=f(d)
    R = 2500;
    altitude  = 6921000;
    duree = [];
    for i=1:length(d)
        duree = [duree,5.7301e+03*(sqrt(R*R-d(i)*d(i)))/(pi*6371000)];
    end
    
end
