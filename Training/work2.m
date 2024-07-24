clear all; clc; close all;

% Starlink-like configuration parameters
altitude = 550e3; % Altitude in meters
numberOfPlanes = 4; % Adjusted number of orbital planes for 20 satellites
satellitesPerPlane = 3; % Satellites per plane for 20 satellites
orbitalPeriod = 1.59 * 3600; % Orbital period in seconds
numberOfSatellites = 20;

% Create satellite scenario
startTime = datetime(2024, 1, 1, 0, 0, 0);
stopTime = startTime + hours(1); % Duration of one day for the simulation
sampleTime = 60; % Sampling time in seconds
sc = satelliteScenario(startTime, stopTime, sampleTime);

% Calculate RAAN and true anomaly for each satellite
raanArray = repmat((0:numberOfPlanes-1) * (360 / numberOfPlanes), satellitesPerPlane, 1);
raanArray = raanArray(:); % Right Ascension of the Ascending Node for each satellite
trueAnomalyArray = repmat((0:satellitesPerPlane-1)' * (360 / satellitesPerPlane), 1, numberOfPlanes);
trueAnomalyArray = trueAnomalyArray(:); % True Anomaly for each satellite
inclination = linspace(20, 90, numberOfPlanes);

% Calculate the semi-major axis for each satellite
semiMajorAxis = altitude + earthRadius('m'); % Semi-major axis


sat_array = [];

for i=1:numberOfPlanes*satellitesPerPlane
    sat_array = [sat_array;satellite(sc, semiMajorAxis, 0, inclination(ceil(i/satellitesPerPlane)), ...
    raanArray(i), 0, trueAnomalyArray(i),"Name","Satellite "+i, 'OrbitPropagator', 'sgp4')];
end


% Add IoT devices at random location
% Tableau des latitudes pour l'Afrique (au nord de l'équateur) et l'Europe
lat = [30.0444; 36.7538; 36.8065; 33.9716; 15.5007; 32.8872; ... % Afrique
             48.8566; 52.5200; 41.9028; 40.4168; 37.9838; 59.3293];   % Europe

% Tableau des longitudes pour l'Afrique (au nord de l'équateur) et l'Europe
lon = [31.2357; 3.0588; 10.1815; -6.8498; 32.5599; 13.1913; ... % Afrique
              2.3522; 13.4050; 12.4964; -3.7038; 23.7275; 18.0686];   % Europe


% Add ground stations at random locations
numGroundStations = 1;
gs_array = [];
for i = 1:numGroundStations
    gs_array = [gs_array ,groundStation(sc, 'Latitude', lat(i), 'Longitude', lon(i),'Name', "GS" + i)];
end


iot_array=[];
for i=2:length(lat)-1
    iot_array = [iot_array,groundStation(sc, 'Latitude', lat(i), 'Longitude', lon(i),'Name', "N" + num2str(i))];
end
iot_array = [iot_array,groundStation(sc, 'Latitude', lat(length(lat)), 'Longitude', lon(length(lat)), 'Name', "Main_IoT")];


% Visualization
satelliteScenarioViewer(sc);

% Play the simulation
play(sc);


% Assuming 'intvls' is a timetable or table with the access intervals data

linking_data = [];
for x=1:length(sat_array)
    for y=1:length(gs_array)
        ac = access(sat_array(x),gs_array(y));
        intvls = accessIntervals(ac);
        linking_data = [linking_data;intvls];
    end
end

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

%%

% Pre-allocate arrays for distances and durations
distance_array = [];
duration_array = [];

% Pre-allocate arrays for distances and durations
distance_array = [];
duration_array = [];

for x = 1:length(sat_array)
    for y = 1:length(iot_array)
        ac = access(sat_array(x), iot_array(y));
        intvls = accessIntervals(ac);
        for k = 1:size(intvls, 1)
            start_time = intvls.StartTime(k);
            end_time = intvls.EndTime(k);
            duration = intvls.Duration(k);
            duration_array = [duration_array; duration];
            
            % Initialize an array to store distances for the current interval
            dists = [];
            current_time = start_time;
            while current_time <= end_time
                % Get satellite position at current time
                [pos, vel] = states(sat_array(x), current_time, 'CoordinateFrame', 'geographic');
                sat_lat = pos(1);
                sat_lon = pos(2);

                % IoT device position (assumed static)
                iot_lat = iot_array(y).Latitude;
                iot_lon = iot_array(y).Longitude;

                % Calculate geographical distance using Haversine formula
                R = earthRadius('meters'); % Earth's radius in meters
                delta_lat = deg2rad(sat_lat - iot_lat);
                delta_lon = deg2rad(sat_lon - iot_lon);
                a = sin(delta_lat / 2)^2 + cos(deg2rad(iot_lat)) * cos(deg2rad(sat_lat)) * sin(delta_lon / 2)^2;
                c = 2 * atan2(sqrt(a), sqrt(1 - a));
                distance = R * c;
                dists = [dists; distance];

                % Increment time by sampleTime seconds
                current_time = current_time + seconds(sampleTime);
            end
            
            min_dist = min(dists);  % Minimum distance during the interval
            distance_array = [distance_array; min_dist];
        end
    end
end

% Calculate correlation
correlation_matrix = corr([duration_array, distance_array]);

results_table = table(duration_array, distance_array, 'VariableNames', {'Duration', 'Distance'});
disp(correlation_matrix);

scatter(distance_array, duration_array);
xlabel('Minimum Distance (m)');
ylabel('Visibility Duration (s)');
title('Correlation between Distance and Duration');
grid on;

%%
% Pre-allocate arrays for distances and durations
distance_array = [];
duration_array = [];

% Constants
R = earthRadius('meters');  % Earth's radius in meters

% Simulation loop for each satellite and IoT device
for x = 1:length(sat_array)
    for y = 1:length(iot_array)
        % Access intervals
        ac = access(sat_array(x), iot_array(y));
        intvls = accessIntervals(ac);
        
        % Convert IoT coordinates to Cartesian coordinates (assumed ECEF)
        iot_lat_deg = iot_array(y).Latitude;
        iot_lon_deg = iot_array(y).Longitude;
        iot_lat = deg2rad(iot_lat_deg);
        iot_lon = deg2rad(iot_lon_deg);
        iot_x = R * cos(iot_lat) * cos(iot_lon);
        iot_y = R * cos(iot_lat) * sin(iot_lon);
        iot_z = R * sin(iot_lat);
        iot_pos = [iot_x; iot_y; iot_z];

        for k = 1:size(intvls, 1)
            % Only compute at the start time of each interval
            start_time = intvls.StartTime(k);
            duration = intvls.Duration(k);
            
            % Get satellite position at start time in Geographic coordinate frame
            [pos, vel] = states(sat_array(x), start_time, 'CoordinateFrame', 'geographic');
            
            % Convert satellite position from geographic to Cartesian (ECEF)
            sat_lat = deg2rad(pos(1));
            sat_lon = deg2rad(pos(2));
            sat_alt = pos(3); % Assume altitude is included in pos vector
            sat_x = (R + sat_alt) * cos(sat_lat) * cos(sat_lon);
            sat_y = (R + sat_alt) * cos(sat_lat) * sin(sat_lon);
            sat_z = (R + sat_alt) * sin(sat_lat);

            % Calculate Euclidean distance
            distance = sqrt((sat_x - iot_x)^2 + (sat_y - iot_y)^2 + (sat_z - iot_z)^2);
            
            % Store distance and duration
            distance_array = [distance_array; distance];
            duration_array = [duration_array; duration];
        end
    end
end

% Store results
results_table = table(distance_array, duration_array, 'VariableNames', {'MinDistance', 'VisibilityDuration'});
disp('Results stored in results_table.');

correlation_matrix = corr([duration_array, distance_array]);
disp(correlation_matrix);

scatter(distance_array, duration_array);
xlabel('Minimum Distance (m)');
ylabel('Visibility Duration (s)');
title('Correlation between Distance and Duration');
grid on;
