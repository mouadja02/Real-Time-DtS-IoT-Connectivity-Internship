clear all; close all; clc;

% Configuration de la simulation
startTime = datetime(2024, 1, 1, 0, 0, 0);
stopTime = startTime + hours(2);
sampleTime = 5;
sc = satelliteScenario(startTime, stopTime, sampleTime);

% Paramètres des satellites
altitude = 550e3;
numberOfSatellites = 3;
orbitalPeriod = 3600;
Re = earthRadius('m');

% Configuration des paramètres orbitaux pour optimiser la couverture
trueAnomalyArray = [0; 0; 0];
raanArray = [0; 74.8; 135.6];
inclination = [37.4, 38, 119];
semiMajorAxis = altitude + Re;

sat_array = [];
for i = 1:numberOfSatellites
    sat_array = [sat_array; satellite(sc, semiMajorAxis, 0, inclination(i), raanArray(i), 0, trueAnomalyArray(i), 'OrbitPropagator', 'sgp4', 'Name', sprintf("Satellite %d", i))];
end

% Placement des IoTs et de la station terrestre avec les nouvelles coordonnées
iot_lat = [48.8566; 41.9028; 30.0444];  % Latitudes
iot_lon = [2.3522; 12.4964; 31.2357];  % Longitudes
names = ["MainIoT", "Node 1", "Node 2","GS"];
gs_lat = 24.7136;
gs_lon = 46.6753;
iot_array = [];
for i = 1:length(iot_lat)
    iot_array = [iot_array, groundStation(sc, 'Latitude', iot_lat(i), 'Longitude', iot_lon(i), 'Name', names(i))];
end

% Station terrestre en Arabie Saoudite
gs = groundStation(sc, 'Latitude', gs_lat, 'Longitude', gs_lon,'Name', "GS");

iot_array_tmp = [iot_array,gs];

% Visualisation et simulation
viewer = satelliteScenarioViewer(sc);
play(sc);


% Enregistrement des données de liaison
linking_data = [];
for i = 1:length(sat_array)
    for j = 1:length(iot_array_tmp)
        ac = access(sat_array(i), iot_array_tmp(j));
        intervals = accessIntervals(ac);
        linking_data = [linking_data; intervals];
    end
end

[out,ind] = sortrows(linking_data,4);

% Define file name
filename = 'access_intervals.csv';

% Concatenate the linking_data into a table
linking_table = table(out.Source, out.Target, datestr(out.StartTime), ...
    datestr(out.EndTime), out.Duration, ...
    'VariableNames', {'Source', 'Target', 'StartTime', 'EndTime', 'Duration'});

% Write the table to a CSV file
writetable(linking_table, filename);

% Confirm to the user that the file has been written
disp(['Access intervals written to ', filename]);



%%
% Stockage des données de trajectoire pour chaque satellite
allSatLatLon = cell(numberOfSatellites, 1);

colors = ['r','g','b','c','m','y'];

figure;
ax = geoaxes;
geobasemap(ax, 'streets');
hold on;

% Boucle sur chaque satellite pour tracer les orbites et stocker les données
for idx = 1:numberOfSatellites
    sampleTimes = startTime:seconds(sampleTime):stopTime;
    satPositions = zeros(length(sampleTimes), 3);
    
    for i = 1:length(sampleTimes)
        [position, velocity] = states(sat_array(idx), sampleTimes(i), 'CoordinateFrame', 'ecef');
        satPositions(i, :) = position';
    end

    % Conversion des positions XYZ en latitude et longitude
    satLatLon = zeros(length(sampleTimes), 2);
    for i = 1:length(sampleTimes)
        [lat, lon, h] = ecef2lla(satPositions(i, 1), satPositions(i, 2), satPositions(i, 3));
        satLatLon(i, :) = [lat, lon];
    end

    allSatLatLon{idx} = satLatLon;  % Stocker les données pour utilisation ultérieure
    % Tracé de la trace au sol pour le satellite actuel
    geoplot(ax, satLatLon(:, 1), satLatLon(:, 2), 'DisplayName', sat_array(idx).Name, 'Color', colors(idx));
end

for j = 1:3
    geoplot(ax, iot_lat(j), iot_lon(j), 'o', 'DisplayName', names(j), 'MarkerSize', 4, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', colors(j+3),'DisplayName',names(j));
end
geoplot(ax, gs_lat, gs_lon, 'o', 'DisplayName', "GS", 'MarkerSize', 4, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w','DisplayName',"GS");


iot_lat = [iot_lat;gs_lat];
iot_lon = [iot_lon;gs_lon];
minimal_distances = []; 
% Calcul des distances minimales pour chaque IoT à chaque satellite
for iot_index = 1:length(iot_lat)
    iot_specific_lat = iot_lat(iot_index);
    iot_specific_lon = iot_lon(iot_index);

    for sat_index = 1:numberOfSatellites
        satLatLon = allSatLatLon{sat_index};
        min_distance = inf;
        closest_point = [0, 0];

        for i = 1:size(satLatLon, 1)
            current_distance = distance(iot_specific_lat, iot_specific_lon, satLatLon(i, 1), satLatLon(i, 2), wgs84Ellipsoid);
            if current_distance < min_distance
                min_distance = current_distance;
                closest_point = satLatLon(i, :);
            end
        end
        minimal_distances = [minimal_distances,min_distance/1000];

        % Tracer une ligne entre l'IoT et le point le plus proche sur la trajectoire du satellite
        geoplot(ax, [iot_specific_lat, closest_point(1)], [iot_specific_lon, closest_point(2)], 'Color', colors(sat_index), 'LineWidth', 2,'HandleVisibility', 'off');
        geoplot(ax, closest_point(1), closest_point(2), 'Marker', '*', 'Color', colors(sat_index),'HandleVisibility', 'off');
    end
end
legend('show');
hold off;
title('Trajectoire Satellite avec Distance Minimale à l''IoT');

%%
durations_iot1 = [635,580,690];
durations_iot2 = [715,685,685];
durations_iot3 = [755,750,605];
durations_gs   = [730,650,235];
durations = [635,580,690,715,685,685,755,750,605,730,650,235];

% Plotting minimal distance vs duration for a specific IoT
plot(minimal_distances, durations, 'o');
xlabel('Minimal Distance (km)');
ylabel('Duration (s)');
title(sprintf('Distance vs Duration for IoT Devices'));
%%

for i=1:12
    display(num2str(durations(i))+',')
end

%%

% Constants
earthRadius = 6371; % Earth's radius in kilometers
orbitAltitude = 0; % Orbit altitude above Earth's surface in kilometers
orbitalRadius = earthRadius + orbitAltitude; % Total orbital radius

% Define the angle for plotting the orbit
theta = linspace(0, 2*pi, 360);

% Orbital coordinates
x_orbit = orbitalRadius * cos(theta);
y_orbit = orbitalRadius * sin(theta);

% Earth plotting
figure;
plot(0, 0, 'bo', 'MarkerFaceColor', 'b'); % Earth's position
hold on;
fill(earthRadius*cos(theta), earthRadius*sin(theta), 'c') % Earth

% Orbit plotting
plot(x_orbit, y_orbit, 'r'); % Orbit path
axis equal;
grid on;
title('Satellite Orbit around Earth');
xlabel('Distance (km)');
ylabel('Distance (km)');
legend('Earth', 'Satellite Orbit');

% Show the plot
hold off;


function [lat, lon, h] = ecef2lla(x, y, z)
    % Constantes pour l'ellipsoïde WGS84
    a = 6378137;  % rayon équatorial en mètres
    e = 0;  % excentricité

    % Calculs intermédiaires
    b = sqrt(a^2 * (1 - e^2));
    ep = sqrt((a^2 - b^2) / b^2);
    p = sqrt(x.^2 + y.^2);
    th = atan2(a * z, b * p);

    % Calcul de latitude, longitude et altitude
    lon = atan2(y, x);
    lat = atan2((z + ep^2 * b * sin(th).^3), (p - e^2 * a * cos(th).^3));
    N = a ./ sqrt(1 - e^2 * sin(lat).^2);
    h = p ./ cos(lat) - N;

    % Conversion de radians en degrés
    lat = rad2deg(lat);
    lon = rad2deg(lon);
end