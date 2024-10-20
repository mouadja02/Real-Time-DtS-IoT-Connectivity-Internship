clc; close all; clear all;

numberOfSensors = 25;
numberOfSatellites = 40;

% Configuration of the simulation
startTime = datetime(2024, 1, 1, 0, 0, 0);
stopTime = startTime + hours(2);
sampleTime = 5;
sc = satelliteScenario(startTime, stopTime, sampleTime);

% Parameters of the satellites
altitude = 650e3; % altitude in +meters
Re = earthRadius('m'); % Earth radius in meters

% Fixed values for true anomaly and RAAN
trueAnomalyArray = linspace(0, 360, numberOfSatellites);
raanArray = linspace(0, 360, numberOfSatellites);
inclinationArray = [0, 15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 179, 0, 15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 0, 15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 0, 15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165];
%inclinationArray = linspace(-179,179, numberOfSatellites);

sat_array = [];
for i = 1:numberOfSatellites
    sat_array = [sat_array; satellite(sc, altitude + Re, 0, inclinationArray(i), raanArray(i), 0, trueAnomalyArray(i),'Name', sprintf("Sat%d", i))];
end

% Origin point
origin_lat = 52.852076;
origin_lon = -120.520511;

% Earth's radius in kilometers
R = 6371;

% Conversion factor from kilometers to degrees
km_to_deg_lat = 1 / (R * pi/180);
km_to_deg_lon = 1 / (R * cosd(origin_lat) * pi/180);

% Sensor positions (x, y in kilometers)
sensor_positions = [
    15, 15;
    65, 15;
    115, 15;
    165, 15;
    215, 15;
    40, 45;
    90, 45;
    140, 45;
    190, 45;
    240, 45;
    15, 75;
    65, 75;
    115, 75;
    165, 75;
    215, 75;
    40, 105;
    90, 105;
    140, 105;
    190, 105;
    240, 105;
    15, 135;
    65, 135;
    115, 135;
    165, 135;
    215, 135
];

% Initialize arrays for latitudes and longitudes
latitudes = zeros(size(sensor_positions, 1), 1);
longitudes = zeros(size(sensor_positions, 1), 1);

% Calculate latitudes and longitudes for each sensor
for i = 1:size(sensor_positions, 1)
    x_km = sensor_positions(i, 1);
    y_km = sensor_positions(i, 2);
    
    latitudes(i) = origin_lat + y_km * km_to_deg_lat;
    longitudes(i) = origin_lon + x_km * km_to_deg_lon;
end

names = arrayfun(@(x) sprintf("Sensor%d", x), 1:numberOfSensors, 'UniformOutput', false);

iot_array = [];
for i = 1:numberOfSensors
    iot_array = [iot_array, groundStation(sc, 'Latitude', latitudes(i), 'Longitude', longitudes(i), 'Name', names{i})];
end

% Visualisation et simulation
viewer = satelliteScenarioViewer(sc);
play(sc);

% Enregistrement des données de liaison
linking_data = [];
for i = 1:length(sat_array)
    for j = 1:length(iot_array)
        ac = access(sat_array(i), iot_array(j));
        intervals = accessIntervals(ac);
        linking_data = [linking_data; intervals];
    end
end

[out, ind] = sortrows(linking_data, 4);

% Define file name
filename = 'sensors_sats_access_intervals.csv';

start_time = datestr(out.StartTime);
end_time = datestr(out.EndTime);

% Concatenate the linking_data into a table
linking_table = table(out.Source, out.Target,start_time(:, 13:20), end_time(:, 13:20), out.Duration, ...
    'VariableNames', {'Source', 'Target', 'StartTime', 'EndTime', 'Duration'});

% Write the table to a CSV file
writetable(linking_table, filename);

% Confirm to the user that the file has been written
disp(['Access intervals written to ', filename]);
