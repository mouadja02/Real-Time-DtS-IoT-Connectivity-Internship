function test_generator(numberOfSatellites,numberOfNodes)
    % Configuration of the simulation
    startTime = datetime(2024, 1, 1, 0, 0, 0);
    stopTime = startTime + hours(3);
    sampleTime = 5;
    sc = satelliteScenario(startTime, stopTime, sampleTime);
    
    % Parameters of the satellites
    altitude = 550e3; % altitude in meters
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
    
    
    
    fixed_latitudes = [48.8566, 6.5244, 35.6895, 52.5200, -1.2921, 40.7128, 41.9028, -33.9249, 28.6139, 55.7558, 34.0522, 13.7563, 51.5074, 9.081999, 31.2304, 40.4168, -26.2041, 23.1291, 59.3293, 14.5995, 55.3781, 45.4654, -34.6037, 37.7749];
    
    fixed_longitudes = [2.3522, 3.3792, 139.6917, 13.4050, 36.8219, 74.0060, 12.4964, 18.4241, 77.2090, 37.6173, -118.2437, 100.5018,-0.1278, 8.675277, 121.4737, -3.7038, 28.0473, 113.2644,18.0686, 120.9842, -3.4360, 9.1859, -58.3816, -122.4194];
    
    % Combine the coordinates
    latitudes = fixed_latitudes(1:numberOfNodes);
    longitudes = fixed_longitudes(1:numberOfNodes);
    names = arrayfun(@(x) sprintf("N%d", x), 1:numberOfNodes, 'UniformOutput', false);
    
    
    iot_array = [];
    for i = 1:length(latitudes)
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
    filename = 'access_intervals.csv';
    
    x = datestr(out.StartTime);
    % Concatenate the linking_data into a table
    linking_table = table(out.Source, out.Target, x(:,13:20), datestr(out.EndTime), out.Duration, ...
        'VariableNames', {'Source', 'Target', 'StartTime', 'EndTime', 'Duration'});
    
    % Write the table to a CSV file
    writetable(linking_table, filename);
    
    % Confirm to the user that the file has been written
    disp(['Access intervals written to ', filename]);
    
    % Load the CSV file
    filename = 'access_intervals.csv';
    data = readtable(filename);
    
    % Number of nodes and satellites
    numNodes = numberOfNodes;
    numSats = numberOfSatellites;
    done = false(numNodes, numSats);
    
    % Convert Source and Target columns using the convert_to_int function if they are cell arrays
    if iscell(data.Source)
        data.Source = cellfun(@(x) convert_to_int(x, numNodes), data.Source);
    else
        data.Source = arrayfun(@(x) convert_to_int(num2str(x), numNodes), data.Source);
    end
    
    if iscell(data.Target)
        data.Target = cellfun(@(x) convert_to_int(x, numNodes), data.Target);
    else
        data.Target = arrayfun(@(x) convert_to_int(num2str(x), numNodes), data.Target);
    end
    
    % Create the adjacency list format
    adjacencyList = [];
    for i = 1:height(data)
        node = data.Target(i);
        satellite = data.Source(i);
        startTime = data.StartTime(i);
    
        delay = sprintf('%s', datestr(startTime, 'HH:MM:SS'));
        
        % Update the matrix with the first start time of connection
        if done(node, satellite-numNodes) == false
            S = str2double(delay(1:2)) * 3600 + str2double(delay(4:5)) * 60 + str2double(delay(7:8));
            done(node, satellite-numNodes) = true;
        end
    
        adjacencyList = [adjacencyList; node, satellite, S];
    end
    
    % Create the output file
    outputFilename = 'input.txt';
    fid = fopen(outputFilename, 'w');
    
    % Write the number of vertices and edges
    fprintf(fid, '%d\n', numNodes + numSats);
    fprintf(fid, '%d\n', 2 * height(data));
    
    % Write the adjacency list
    for i = 1:size(adjacencyList, 1)
        fprintf(fid, '%d %d %d\n', adjacencyList(i, 1), adjacencyList(i, 2), adjacencyList(i, 3));
    end
    
    for i = 1:size(adjacencyList, 1)
        fprintf(fid, '%d %d %d\n', adjacencyList(i, 2), adjacencyList(i, 1), adjacencyList(i, 3));
    end
    
    % Close the file
    fclose(fid);
    
    disp(['Output written to ', outputFilename]);
    
    clc; close all; clear ;
    
    % Read the CSV data
    data = readtable('access_intervals.csv');
    
    % Define the orbital period and connectivity duration
    orbital_period = 5724; % =1.59h (StarLink satellites orbit period)
    connectivity_duration = 420; % 7 min
    
    N_nodes = numberOfNodes;
    N_sats = numberOfSatellites;
    
    str_delays = zeros(1,2*N_sats);
    min_delay = inf;
    
    tic
    
    for i = 1:N_sats
        total_delay = 0;
        relevant_data = data(strcmp(data.Source, "S" + num2str(i)) & strcmp(data.Target, "N1"), :);
        if ~isempty(relevant_data)
            delay1 = seconds(min(relevant_data.StartTime));
        else
            continue;
        end
        
        for j = 1:N_nodes
            relevant_data = data(strcmp(data.Source, "S" + num2str(i)) & strcmp(data.Target, "N" + num2str(j)), :);
            if ~isempty(relevant_data) && j~=1
                delay2 = seconds(min(relevant_data.StartTime));
                total_delay = calculate_delay(delay1, delay2, connectivity_duration, orbital_period);
                str_delays(1) = total_delay;
                if j == 6 && total_delay < min_delay
                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j)];
                    min_delay  = total_delay;
                end
            else
                continue;
            end
    
            if str_delays(1) > min_delay
                continue
            end
    
            for k = 1:N_sats 
                relevant_data = data(strcmp(data.Source, "S" + num2str(k)) & strcmp(data.Target, "N" + num2str(j)), :);
                if ~isempty(relevant_data) && k~=i
                    str_delays(2) = calculate_delay(str_delays(1), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                else
                    continue;
                end
    
                if str_delays(2) > min_delay
                continue
            end
    
                
                for l = 1:N_nodes
                    relevant_data = data(strcmp(data.Source, "S" + num2str(k)) & strcmp(data.Target, "N" + num2str(l)), :);
                    if ~isempty(relevant_data) && l~=j
                        total_delay = calculate_delay(str_delays(2), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                        str_delays(3) = total_delay;
                        if l == 6 && total_delay < min_delay
                            opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l)];
                            min_delay  = total_delay;
                        end
                    else
                        continue;
                    end
    
                    if str_delays(3) > min_delay
                        continue
                    end
    
    
                    for m = 1:N_sats
                        relevant_data = data(strcmp(data.Source, "S" + num2str(m)) & strcmp(data.Target, "N" + num2str(l)), :);
                        if ~isempty(relevant_data) && k~=i && m~=i && k~=m
                            str_delays(4) = calculate_delay(str_delays(3), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                        else
                            continue;
                        end
    
                        if str_delays(4) > min_delay
                            continue
                        end
                        
                        for n = 1:N_nodes
                            relevant_data = data(strcmp(data.Source, "S" + num2str(m)) & strcmp(data.Target, "N" + num2str(n)), :);
                            if ~isempty(relevant_data) && l~=j && l~=n && j~=n
                                total_delay = calculate_delay(str_delays(4), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                str_delays(5) = total_delay;
                                if n == 6 && total_delay < min_delay
                                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n)];
                                    min_delay  = total_delay;
                                end
                            else
                                continue;
                            end
    
                            if str_delays(5) > min_delay
                                continue
                            end
    
                            for o = 1:N_sats
                                relevant_data = data(strcmp(data.Source, "S" + num2str(o)) & strcmp(data.Target, "N" + num2str(n)), :);
                                if ~isempty(relevant_data) && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o
                                    str_delays(6) = calculate_delay(str_delays(5), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                else
                                    continue;
                                end
    
                                if str_delays(6) > min_delay
                                    continue
                                end
                                
                                for p = 1:N_nodes
                                    relevant_data = data(strcmp(data.Source, "S" + num2str(o)) & strcmp(data.Target, "N" + num2str(p)), :);
                                    if ~isempty(relevant_data) && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p
                                        total_delay = calculate_delay(str_delays(6), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                        str_delays(7) = total_delay;
                                        if p == 6 && total_delay < min_delay
                                            opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p)];
                                            min_delay  = total_delay;
                                        end
                                    else
                                        continue;
                                    end
    
                                    if str_delays(7) > min_delay
                                        continue
                                    end
    
                                    for q = 1:N_sats
                                        relevant_data = data(strcmp(data.Source, "S" + num2str(q)) & strcmp(data.Target, "N" + num2str(p)), :);
                                        if ~isempty(relevant_data) && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o
                                            str_delays(8) = calculate_delay(str_delays(7), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                        else
                                            continue;
                                        end
    
                                        if str_delays(8) > min_delay
                                            continue
                                        end
                                        
                                        for r = 1:N_nodes
                                            relevant_data = data(strcmp(data.Source, "S" + num2str(q)) & strcmp(data.Target, "N" + num2str(r)), :);
                                            if ~isempty(relevant_data) && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p
                                                total_delay = calculate_delay(str_delays(8), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                str_delays(9) = total_delay;
                                                if r == 6 && total_delay < min_delay
                                                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r)];
                                                    min_delay  = total_delay;
                                                end
                                            else
                                                continue;
                                            end
    
                                            if str_delays(9) > min_delay
                                                continue
                                            end
    
                                            for s = 1:N_sats
                                                relevant_data = data(strcmp(data.Source, "S" + num2str(s)) & strcmp(data.Target, "N" + num2str(r)), :);
                                                if ~isempty(relevant_data) && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s
                                                    str_delays(10) = calculate_delay(str_delays(9), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                else
                                                    continue;
                                                end
    
                                                if str_delays(10) > min_delay
                                                    continue
                                                end
                                                
                                                for t = 1:N_nodes
                                                    relevant_data = data(strcmp(data.Source, "S" + num2str(s)) & strcmp(data.Target, "N" + num2str(t)), :);
                                                    if ~isempty(relevant_data) && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t
                                                        total_delay = calculate_delay(str_delays(10), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                        str_delays(11) = total_delay;
                                                        if t == 6 && total_delay < min_delay
                                                            opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t)];
                                                            min_delay  = total_delay;
                                                        end
                                                    else
                                                        continue;
                                                    end
                                                    
                                                    if str_delays(11) > min_delay
                                                        continue
                                                    end
                                                
    
                                                    for u = 1:N_sats
                                                        relevant_data = data(strcmp(data.Source, "S" + num2str(u)) & strcmp(data.Target, "N" + num2str(t)), :);
                                                        if ~isempty(relevant_data) && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s && u~=i && u~=k && u~=m && u~=o && u~=q && u~=s
                                                            str_delays(12) = calculate_delay(str_delays(11), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                        else
                                                            continue;
                                                        end
                                                        
                                                        if str_delays(12) > min_delay
                                                            continue
                                                        end
                                                        for v = 1:N_nodes
                                                            relevant_data = data(strcmp(data.Source, "S" + num2str(u)) & strcmp(data.Target, "N" + num2str(v)), :);
                                                            if ~isempty(relevant_data) && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t && v~=j && v~=l && v~=n && v~=p && v~=r && v~=t 
                                                                total_delay = calculate_delay(str_delays(12), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                                str_delays(13) = total_delay;
                                                                if v == 6 && total_delay < min_delay
                                                                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t), "S" + num2str(u), "N" + num2str(v)];
                                                                    min_delay  = total_delay;
                                                                end
                                                            else
                                                                continue;
                                                            end
    
                                                            if str_delays(13) > min_delay
                                                                continue
                                                            end
    
                                                            for w = 1:N_sats
                                                                relevant_data = data(strcmp(data.Source, "S" + num2str(w)) & strcmp(data.Target, "N" + num2str(v)), :);
                                                                if ~isempty(relevant_data) && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s && u~=i && u~=k && u~=m && u~=o && u~=q && u~=s && w~=i && w~=k && w~=m && w~=o && w~=q && w~=s && w~=u
                                                                    str_delays(14) = calculate_delay(str_delays(13), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                                else
                                                                    continue;
                                                                end
    
                                                                if str_delays(14) > min_delay
                                                                    continue
                                                                end
                                                                
                                                                for x = 1:N_nodes
                                                                    relevant_data = data(strcmp(data.Source, "S" + num2str(w)) & strcmp(data.Target, "N" + num2str(x)), :);
                                                                    if ~isempty(relevant_data) && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t && v~=j && v~=l && v~=n && v~=p && v~=r && v~=t && x~=j && x~=l && x~=n && x~=p && x~=r && x~=t && x~=v
                                                                        total_delay = calculate_delay(str_delays(14), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                                        str_delays(15) = total_delay;
                                                                        if w == 6 && total_delay < min_delay
                                                                            opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t), "S" + num2str(u), "N" + num2str(v), "S" + num2str(w), "N" + num2str(x)];
                                                                            min_delay  = total_delay;
                                                                        end
                                                                    else
                                                                        continue;
                                                                    end
                                                                    if str_delays(15) > min_delay
                                                                        continue
                                                                    end
    
                                                                    for y = 1:N_sats
                                                                        relevant_data = data(strcmp(data.Source, "S" + num2str(y)) & strcmp(data.Target, "N" + num2str(x)), :);
                                                                        if ~isempty(relevant_data) && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s && u~=i && u~=k && u~=m && u~=o && u~=q && u~=s && w~=i && w~=k && w~=m && w~=o && w~=q && w~=s && w~=u && y~=i && y~=k && y~=m && y~=o && y~=q && y~=s && y~=u && y~=w
                                                                            str_delays(16) = calculate_delay(str_delays(15), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                                        else
                                                                            continue;
                                                                        end
    
                                                                        if str_delays(16) > min_delay
                                                                            continue
                                                                        end
                                                                        
                                                                        for z = 1:N_nodes
                                                                            relevant_data = data(strcmp(data.Source, "S" + num2str(y)) & strcmp(data.Target, "N" + num2str(z)), :);
                                                                            if ~isempty(relevant_data) && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t && v~=j && v~=l && v~=n && v~=p && v~=r && v~=t && x~=j && x~=l && x~=n && x~=p && x~=r && x~=t && x~=v && z~=j && z~=l && z~=n && z~=p && z~=r && z~=t && z~=v && z~=x
                                                                                total_delay = calculate_delay(str_delays(16), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                                                str_delays(17) = total_delay;
                                                                                if z == 6 && total_delay < min_delay
                                                                                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t), "S" + num2str(u), "N" + num2str(v), "S" + num2str(w), "N" + num2str(x), "S" + num2str(y), "N" + num2str(z)];
                                                                                    min_delay  = total_delay;
                                                                                end
                                                                            else
                                                                                continue;
                                                                            end
    
                                                                            if str_delays(17) > min_delay
                                                                                continue
                                                                            end
                                                                            
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
       
    toc
    display("Number of satellites : ",numberOfSatellites);
    display("Number of nodes :", numberOfNodes);

    display("\nBruteforce Results\nShortest path : ");
    display(opt_path);
    display(length(opt_path),' hops');
    display("Delay = ");
    display(min_delay);
    
    FloydWarshall(outputFilename,1,6);
    display("\n-------------------------------\n");
end