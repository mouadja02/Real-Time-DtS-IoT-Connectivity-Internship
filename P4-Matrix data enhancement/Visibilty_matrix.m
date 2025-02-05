clear all; close all; clc;

% Configuration of the simulation
startTime = datetime(2024, 1, 1, 0, 0, 0);
stopTime = startTime + hours(10);
sampleTime = 5;
sc = satelliteScenario(startTime, stopTime, sampleTime);

% Parameters of the satellites
altitude = 550e3; % altitude in meters
numberOfSatellites = 3;
orbitalPeriod = seconds(1.59*3600); 
Re = earthRadius('m'); % Earth radius in meters

trueAnomalyArray = [80; 40; 0];
raanArray = [310.8; 74.8; 36.8];
inclination = [53.8, 62, 14.6];
semiMajorAxis = altitude + Re; % Semi-major axis in meters
eccentricity = 0; % Circular orbit
argumentOfPeriapsis = 0; % Not particularly relevant in a circular orbit

sat_array = [];
for i = 1:numberOfSatellites
    sat_array = [sat_array; satellite(sc, semiMajorAxis, eccentricity, inclination(i), raanArray(i), argumentOfPeriapsis, trueAnomalyArray(i), ...
        'Name', sprintf("Satellite %d", i))];
end

% Placement des IoTs et de la station terrestre avec les nouvelles coordonnées
iot_lat = [48.8566; 41.9028; 30.0444];  % Latitudes
iot_lon = [2.3522; 12.4964; 31.2357];  % Longitudes
names = ["MainIoT", "Node 1", "Node 2"];
gs_lat = 24.7136;
gs_lon = 46.6753;
iot_array = [];
for i = 1:length(iot_lat)
    iot_array = [iot_array, groundStation(sc, 'Latitude', iot_lat(i), 'Longitude', iot_lon(i), 'Name', names(i))];
end

% Station terrestre en Arabie Saoudite
gs = groundStation(sc, 'Latitude', gs_lat, 'Longitude', gs_lon, 'Name', "GS");
iot_array_tmp = [iot_array, gs];
names = [names, "GS"];

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

[out, ind] = sortrows(linking_data, 4);

% Define file name
filename = 'access_intervals.csv';

% Concatenate the linking_data into a table
linking_table = table(out.Source, out.Target, datestr(out.StartTime), datestr(out.EndTime), out.Duration, ...
    'VariableNames', {'Source', 'Target', 'StartTime', 'EndTime', 'Duration'});

% Write the table to a CSV file
writetable(linking_table, filename);

% Confirm to the user that the file has been written
disp(['Access intervals written to ', filename]);

%%
% Stockage des données de trajectoire pour chaque satellite
allSatPositions = cell(numberOfSatellites, 1);
allSatLatLon = cell(numberOfSatellites, 1);

colors = ['r', 'g', 'b', 'c', 'm', 'y'];
figure;
ax = geoaxes;
geobasemap(ax, 'streets');
hold on;

% Boucle sur chaque satellite pour tracer les orbites et stocker les données
sampleTimes = startTime:seconds(sampleTime):stopTime;
for idx = 1:numberOfSatellites
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

    allSatPositions{idx} = satPositions;  % Stocker les positions XYZ
    allSatLatLon{idx} = satLatLon;  % Stocker les données pour utilisation ultérieure

    % Tracé de la trace au sol pour le satellite actuel
    geoplot(ax, satLatLon(:, 1), satLatLon(:, 2), 'DisplayName', sat_array(idx).Name, 'Color', colors(idx));
end

% Ajout des IoTs et de la station terrestre
for j = 1:3
    geoplot(ax, iot_lat(j), iot_lon(j), 'o', 'DisplayName', names(j), 'MarkerSize', 4, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', colors(j + 3));
end
geoplot(ax, gs_lat, gs_lon, 'o', 'DisplayName', "GS", 'MarkerSize', 4, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w');

iot_lat = [iot_lat; gs_lat];
iot_lon = [iot_lon; gs_lon];

% Calcul des distances minimales pour chaque IoT à chaque satellite
minimal_distances = [];
x_array = [];
for iot_index = 1:length(iot_lat)
    iot_specific_lat = iot_lat(iot_index);
    iot_specific_lon = iot_lon(iot_index);

    for sat_index = 1:numberOfSatellites
        satLatLon = allSatLatLon{sat_index};
        min_distance = inf;
        closest_point = [0, 0];

        for i = 1:size(satLatLon, 1)
            current_distance = haversine(iot_specific_lat, iot_specific_lon, satLatLon(i, 1), satLatLon(i, 2));
            if current_distance < min_distance
                min_distance = current_distance;
                closest_point = satLatLon(i, :);
            end

            if current_distance < 2500
                
            end 
        end
        minimal_distances = [minimal_distances, min_distance];

        % Tracer une ligne entre l'IoT et le point le plus proche sur la trajectoire du satellite
        geoplot(ax, [iot_specific_lat, closest_point(1)], [iot_specific_lon, closest_point(2)], 'Color', colors(sat_index), 'LineWidth', 2, 'HandleVisibility', 'off');
        geoplot(ax, closest_point(1), closest_point(2), 'Marker', '*', 'Color', colors(sat_index), 'HandleVisibility', 'off');
    end
end
legend('show');
hold off;
title('Trajectoire Satellite avec Distance Minimale à l''IoT');

%%
% Fonction prédictive pour un IoT spécifique
times = predictConnectionTimesXYZ(iot_lat(1), iot_lon(1), 0, allSatPositions{1}, sampleTimes);

%%
durations_iot1 = [635, 580, 690];
durations_iot2 = [715, 685, 685];
durations_iot3 = [755, 750, 605];
durations_gs = [730, 650, 235];
durations = [635, 580, 690, 715, 685, 685, 755, 750, 605, 730, 650, 235];

% Plotting minimal distance vs duration for a specific IoT
plot(minimal_distances, durations, 'o');
xlabel('Minimal Distance (km)');
ylabel('Duration (s)');
title('Distance vs Duration for IoT Devices');



%%
% Charger les données depuis le fichier CSV
data = readtable('access_intervals.csv');

% Définir l'ordre des satellites et des nœuds
satellites = {'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'S10', 'S11', 'S12', 'S13', 'S14', 'S15', 'S16'};
nodes = {'N1', 'N2', 'N3', 'N4', 'N5', 'N6', 'N7', 'N8', 'N9', 'N10', 'N11', 'N12', 'N13', 'N14', 'N15', 'N16', 'N17', 'N18', 'N19', 'N20'};

% Initialiser la matrice avec des valeurs 'inf' par défaut
numNodes = length(nodes);
numSatellites = length(satellites);
matrix = inf(numNodes, numSatellites);

% Remplir la matrice avec les temps de début de connexion
for i = 1:height(data)
    node = data.Target{i};
    satellite = data.Source{i};
    startTime = data.StartTime(i);
    delay_str = sprintf('%s', datestr(startTime, 'HH:MM:SS'));
    
    % Trouver les indices correspondants
    nodeIdx = find(strcmp(nodes, node));
    satelliteIdx = find(strcmp(satellites, satellite));
    
    % Mettre à jour la matrice avec le premier temps de début de connexion
    if matrix(nodeIdx, satelliteIdx) == inf
        S = str2double(delay_str(1:2))*3600 + str2double(delay_str(4:5))*60 + str2double(delay_str(7:8));
        matrix(nodeIdx, satelliteIdx) = S;
    end
end

% Afficher la matrice
disp('Node-Satellite Start Time Matrix:');
disp(array2table(matrix, 'VariableNames', satellites, 'RowNames', nodes));

%%
FloydWarshall(matrix)
function FloydWarshall(matrix)
    
    % Number of IoT devices and satellites
    numIoTs = size(matrix, 1);
    numSats = size(matrix, 2);
    
    % Initialize distance and parent matrices
    dist = inf(numIoTs, numSats);
    parent = zeros(numIoTs, numSats);
    
    % Read the matrix and initialize dist and parent matrices
    for i = 1:numIoTs
        for j = 1:numSats
            if matrix(i, j) < inf
                dist(i, j) = matrix(i, j);
                parent(i, j) = i;
            end
        end
    end
    
    % Path from vertex to itself is set to 0
    for i = 1:numIoTs
        dist(i, i) = 0;
    end
    
    % Initialize the path matrix
    for i = 1:numIoTs
        for j = 1:numSats
            if dist(i, j) == inf
                parent(i, j) = 0;
            else
                parent(i, j) = i;
            end
        end
    end
    
    % Actual Floyd-Warshall algorithm
    for k = 1:numSats
        for i = 1:numIoTs
            for j = 1:numSats
                if dist(i, j) > calculate_delay(dist(i, k), dist(k, j), 420, 1.59 * 3600)
                    dist(i, j) = calculate_delay(dist(i, k), dist(k, j), 420, 1.59 * 3600);
                    parent(i, j) = parent(k, j);
                end
            end
        end
    end

    % Check for negative cycles (if applicable)
    for i = 1:numIoTs
        if dist(i, i) ~= 0
            disp(['Negative cycle at: ', num2str(i)]);
            return;
        end
    end
    
    disp('All Pairs Shortest Paths:');
    for i = 1
        for j = 20
            disp(['From N', num2str(i), ' To N', num2str(j)]);
            disp(['Path: N', num2str(i), obtainPath(i, j, parent),' N', num2str(j)]);
            disp(['Delay: ', num2str(dist(i, j))]);
            disp('---------------------------------------------');   
        end
    end
    
end
function pathStr = obtainPath(i, j, parent)
    if parent(i, j) == 0 || parent(i, j) == i
        pathStr = '-->';
    else
        pathStr = [obtainPath(i, parent(i, j), parent), ' N', num2str(parent(i, j)), ' ', obtainPath(parent(i, j), j, parent)];
    end
end

% Function to calculate delay between nodes
function delay = calculate_delay(x, y, connectivity_duration, orbital_period)
    if x > y
        if x < y + connectivity_duration
            delay = max(x,0);
        else
            delay = y + orbital_period;
        end
    else
        delay = max(y,0);
    end
end
% Function to convert node/satellite identifier to integer
function id = convert_to_int(identifier, numberOfNodes)
    if startsWith(identifier, 'N')
        id = str2double(extractAfter(identifier, 'N'));
    elseif startsWith(identifier, 'S')
        id = str2double(extractAfter(identifier, 'S')) + numberOfNodes;
    else
        error('Invalid identifier format');
    end
end

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

function [connection_times] = predictConnectionTimesXYZ(node_lat, node_lon, node_alt, satPositions, sampleTimes)
    % Convert the node's (lat, lon, alt) to (x, y, z) in ECEF
    wgs84 = wgs84Ellipsoid('meter');
    [node_x, node_y, node_z] = geodetic2ecef(wgs84, node_lat, node_lon, node_alt);

    % Calculate the distance between the node and each satellite position
    num_samples = size(satPositions, 1);
    distances = zeros(num_samples, 1);
    for i = 1:num_samples
        distances(i) = sqrt((satPositions(i, 1) - node_x)^2 + (satPositions(i, 2) - node_y)^2 + (satPositions(i, 3) - node_z)^2) / 1000; % Convert to km
    end

    % Define a threshold distance (in km)
    distance_threshold_km = 2500;

    % Find the satellite positions that fall within the threshold distance
    within_range_indices = distances <= distance_threshold_km;

    % Extract the corresponding sample times
    connection_times = sampleTimes(within_range_indices);
end

function distance = haversine(lat1, lon1, lat2, lon2)
    R = 6371;

    lat1 = deg2rad(lat1);
    lon1 = deg2rad(lon1);
    lat2 = deg2rad(lat2);
    lon2 = deg2rad(lon2);

    % Différences de latitude et longitude
    dLat = lat2 - lat1;
    dLon = lon2 - lon1;

    % Application de la formule de Haversine
    a = sin(dLat/2)^2 + cos(lat1) * cos(lat2) * sin(dLon/2)^2;
    c = 2 * atan2(sqrt(a), sqrt(1-a));
    distance = R * c;
end