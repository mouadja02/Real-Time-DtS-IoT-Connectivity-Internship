clear all; close all; clc;

% Configuration of the simulation
startTime = datetime(2024, 1, 1, 0, 0, 0);
stopTime = startTime + hours(3);
sampleTime = 5;
sc = satelliteScenario(startTime, stopTime, sampleTime);

% Parameters of the satellites
altitude = 550e3; % altitude in meters
numberOfSatellites = 20;
orbitalPeriod = seconds(1.59*3600); 
Re = earthRadius('m'); % Earth radius in meters

trueAnomalyArray = linspace(0, 360, numberOfSatellites); % distribute anomalies
raanArray = linspace(0, 360, numberOfSatellites); % distribute RAAN
inclination = 53; % Fixed inclination for all satellites
semiMajorAxis = altitude + Re; % Semi-major axis in meters
eccentricity = 0; % Circular orbit
argumentOfPeriapsis = 0; % Not particularly relevant in a circular orbit

sat_array = [];
for i = 1:numberOfSatellites
    sat_array = [sat_array; satellite(sc, semiMajorAxis, eccentricity, inclination, raanArray(i), argumentOfPeriapsis, trueAnomalyArray(i), ...
        'Name', sprintf("S%d", i))];
end

% Placement des IoTs et de la station terrestre
numberOfNodes = 27;
% Generate random latitudes and longitudes for Africa, Europe, and Asia
africa_lat = -34 + (37 - (-34)) .* rand(numberOfNodes/3, 1);
africa_lon = -17 + (51 - (-17)) .* rand(numberOfNodes/3, 1);
europe_lat = 36 + (71 - 36) .* rand(numberOfNodes/3, 1);
europe_lon = -10 + (60 - (-10)) .* rand(numberOfNodes/3, 1);
asia_lat = -10 + (77 - (-10)) .* rand(numberOfNodes/3, 1);
asia_lon = 25 + (150 - 25) .* rand(numberOfNodes/3, 1);

% Combine the coordinates
latitudes = [africa_lat; europe_lat; asia_lat];
longitudes = [africa_lon; europe_lon; asia_lon];
latitudes = latitudes(1:numberOfNodes);
longitudes = longitudes(1:numberOfNodes);
names = arrayfun(@(x) sprintf("N%d", x), 1:numberOfNodes, 'UniformOutput', false);

iot_array = [];
for i = 1:length(latitudes)
    iot_array = [iot_array, groundStation(sc, 'Latitude', latitudes(i), 'Longitude', longitudes(i), 'Name', names{i})];
end

iot_array_tmp = [iot_array];

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
