close all; clc;

% Starlink-like configuration parameters
altitude = 550e3; % Altitude in meters
numberOfPlanes = 8; % Adjusted number of orbital planes for 20 satellites
satellitesPerPlane = 2; % Satellites per plane for 20 satellites
orbitalPeriod = 1.59 * 3600; % Orbital period in seconds
numberOfSatellites = 16;

% Create satellite scenario
startTime = datetime(2024, 1, 1, 0, 0, 0);
stopTime = startTime + hours(1); % Duration of simulation
sampleTime = 60; % Sampling time in seconds
sc = satelliteScenario(startTime, stopTime, sampleTime);

% Earth radius
Re = earthRadius('m');

% Calculate RAAN and true anomaly for each satellite
raanArray = repmat((0:34) * (360 / numberOfPlanes), satellitesPerPlane, 1);
raanArray = raanArray(:);
trueAnomalyArray = repmat((0:34)' * (360 / satellitesPerPlane), 1, numberOfPlanes);
trueAnomalyArray = trueAnomalyArray(:);

% Adjust inclination to focus on Europe, Africa, and Asia
inclination = linspace(60, 120, numberOfPlanes); % Adjust inclination range

% Calculate the semi-major axis for each satellite
semiMajorAxis = altitude + Re;

% Deploy satellites
sat_array = [];
for i = 1:numberOfPlanes * satellitesPerPlane
    sat_array = [sat_array; satellite(sc, semiMajorAxis, 0, inclination(ceil(i / satellitesPerPlane)), ...
        raanArray(i), 0, trueAnomalyArray(i), "Name", "S" + i, 'OrbitPropagator', 'sgp4')];
end

% Number of IoT devices
num_devices = 10;

% Generate random latitude and longitude for Europe
%lat_Europe = 35 + (70 - 35) * rand(1, num_devices); % Latitude range for Europe
%lon_Europe = -10 + (40 - (-10)) * rand(1, num_devices); % Longitude range for Europe

% Generate random latitude and longitude for Africa
%lat_Africa = -35 + (35 - (-35)) * rand(1, num_devices); % Latitude range for Africa
%lon_Africa = -20 + (55 - (-20)) * rand(1, num_devices); % Longitude range for Africa


lon = [32.8254718362526, 34.7134784128485, -3.17921970016142, 0.179104883002378, 30.4773373753089, ...
             15.8119148295146, 26.7787309500582, -2.26663005193172, -6.71571841262626, 42.2232539273188, ...
             25.9785067429745, 39.8078055648435, 7.72671524784609, 38.5629407591703, 7.32243806501798, ...
             34.3271930880153, 12.7347432495954, 10.6713644510408, 0.886603417865020, -3.71727063186869];

lat = [-13.3759784503229, 15.8273102165382, 19.8010451085386, 13.5651330490828, -34.3138423415857, ...
              24.0249336607357, 29.5632398457393, 18.9667954471747, -32.0138100845466, -8.52697040648468, ...
              58.8062429930676, 53.4746390646579, 49.4057729692637, 56.0923376312739, 61.2682019573307, ...
              55.4236610991686, 54.3127380227589, 55.4249716565200, 52.9136971985466, 37.8907454449545];

iot_array = [];
for i = 1:length(lat)
    iot_array = [iot_array, groundStation(sc, 'Latitude', lat(i), 'Longitude', lon(i), 'Name', "N" + i)];
end


% Visualization
satelliteScenarioViewer(sc);

% Play the simulation
play(sc);


% Assuming 'intvls' is a timetable or table with the access intervals data

linking_data = [];


for x=1:length(sat_array)
    for y=1:length(iot_array)
        ac = access(sat_array(x),iot_array(y));
        intvls = accessIntervals(ac);
        linking_data = [linking_data;intvls];

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


