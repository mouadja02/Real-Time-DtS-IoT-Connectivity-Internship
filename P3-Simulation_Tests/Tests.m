clc; close all; clear all;

end_node = 8;
numberOfNodes = 24;
numberOfSatellites = 24;

% Configuration of the simulation
startTime = datetime(2024, 1, 1, 0, 0, 0);
stopTime = startTime + hours(2);
sampleTime = 5;
sc = satelliteScenario(startTime, stopTime, sampleTime);

% Parameters of the satellites
altitude = 550e3; % altitude in +meters
orbitalPeriod = seconds(1.59 * 3600);
Re = earthRadius('m'); % Earth radius in meters

% Fixed values for true anomaly and RAAN
trueAnomalyArray = linspace(0, 360, numberOfSatellites);
raanArray = linspace(0, 360, numberOfSatellites);
%inclinationArray = [0, 15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 179, 0, 15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 0, 15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 180, 195, 210, 225, 240, 255];
inclinationArray = linspace(-179,179, numberOfSatellites);

sat_array = [];
for i = 1:numberOfSatellites
    if i==5 || i==6
        sat_array = [sat_array; satellite(sc, altitude + Re, 0, inclinationArray(i), raanArray(i), 0, trueAnomalyArray(i),'Name', sprintf("S%d", i+12))];
    else 
        if i==17 || i==18
            sat_array = [sat_array; satellite(sc, altitude + Re, 0, inclinationArray(i), raanArray(i), 0, trueAnomalyArray(i),'Name', sprintf("S%d", i-12))];
        else 
            sat_array = [sat_array; satellite(sc, altitude + Re, 0, inclinationArray(i), raanArray(i), 0, trueAnomalyArray(i),'Name', sprintf("S%d", i))];

        end
    end
end
% Define fixed coordinates for IoTs in Africa and Asia
latitudes = [35.6895, 1.2921, -26.2041, 9.0765, -15.3875, -33.9249, 13.7563, 31.2304, 39.9042, 28.6139, 23.8103, 34.0208, ...
    36.8219, 10.8231, -1.2864, -6.5244, 33.9391, 14.5995, 12.5657, 13.7563, 24.7136, 19.0760, 25.2760, 15.5007];
longitudes = [139.6917, 36.8219, 28.0473, 7.3986, 35.3088, 18.4241, 100.5018, 121.4737, 116.4074, 77.2090, 90.4125, 6.8317, ...
    38.0000, 106.6297, 36.8172, 39.2806, 67.7100, 120.9842, 104.9910, 100.5018, 46.6753, 72.8777, 55.2963, 32.5631];

names = arrayfun(@(x) sprintf("N%d", x), 1:numberOfNodes, 'UniformOutput', false);

iot_array = [];
for i = 1:numberOfNodes
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
filename = 'access_intervals5.csv';

ff = datestr(out.StartTime);
% Concatenate the linking_data into a table
linking_table = table(out.Source, out.Target,ff(:, 13:20), datestr(out.EndTime), out.Duration, ...
    'VariableNames', {'Source', 'Target', 'StartTime', 'EndTime', 'Duration'});

% Write the table to a CSV file
writetable(linking_table, filename);

% Confirm to the user that the file has been written
disp(['Access intervals written to ', filename]);

%%
clc; clear all;

end_node = 12;


% Number of Monte Carlo simulations
num_iterations = 100;

filename = 'access_intervals5.csv'; % Access the current filename

% Loop through the number of nodes and satellites
for numNodes = 12:6:24
    for numSats = 6:2:24
        % Initialize accumulators for Monte Carlo
        total_time_bruteforce = 0;
        total_time_floydwarshall = 0;


        % Load the CSV file
        data = readtable(filename);
    
        done = false(numNodes, numSats);
    
        % Convertir les colonnes Source et Target en entiers si elles sont des tableaux de cellules
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
    
        count= 0;
        % Créer le format de liste d'adjacence
        adjacencyList = [];
        for i = 1:height(data)
            node = data.Target(i);
            satellite = data.Source(i);
    
            if node > numNodes || satellite > numSats+numNodes
                continue;
            end
    
            startTime = data.StartTime(i);
    
            delay = sprintf('%s', datestr(startTime, 'HH:MM:SS'));
    
            % Mettre à jour la matrice avec le premier temps de début de connexion
            if done(node, satellite - numNodes) == false
                S = str2double(delay(1:2)) * 3600 + str2double(delay(4:5)) * 60 + str2double(delay(7:8));
                done(node, satellite - numNodes) = true;
            end
    
            adjacencyList = [adjacencyList; node, satellite, S];
            count = count+1;
        end
    
        % Créer le fichier de sortie
        outputFilename = 'input.txt';
        fid_adjacency = fopen(outputFilename, 'w');
    
        % Écrire le nombre de sommets et d'arêtes
        fprintf(fid_adjacency, '%d\n', numNodes + numSats);
        fprintf(fid_adjacency, '%d\n', 2 * count);
    
        % Écrire la liste d'adjacence
        for i = 1:size(adjacencyList, 1)
            fprintf(fid_adjacency, '%d %d %d\n', adjacencyList(i, 1), adjacencyList(i, 2), adjacencyList(i, 3));
        end
    
        for i = 1:size(adjacencyList, 1)
            fprintf(fid_adjacency, '%d %d %d\n', adjacencyList(i, 2), adjacencyList(i, 1), adjacencyList(i, 3));
        end
    
        % Fermer le fichier
        fclose(fid_adjacency);
        
        % Monte Carlo loop
        for mc_iter = 1:num_iterations
            % Bruteforce Timing
            tic;
            for i = 1:numSats
                total_delay = 0;
                relevant_data = data(strcmp(data.Source, "S" + num2str(i)) & strcmp(data.Target, "N1"), :);
                if ~isempty(relevant_data)
                    delay1 = seconds(min(relevant_data.StartTime));
                else
                    continue;
                end
                
                for j = 2:N_nodes
                    relevant_data = data(strcmp(data.Source, "S" + num2str(i)) & strcmp(data.Target, "N" + num2str(j)), :);
                    if ~isempty(relevant_data) && j~=1
                        delay2 = seconds(min(relevant_data.StartTime));
                        total_delay = calculate_delay(delay1, delay2, connectivity_duration, orbital_period);
                        str_delays(1) = total_delay;
                        if j == end_node && total_delay < min_delay
                            opt_path = ["N1", "S" + num2str(i), "N" + num2str(j)];
                            min_delay  = total_delay;
                        end
                    else
                        continue;
                    end
            
                    if str_delays(1) > min_delay
                        continue
                    end
            
                    for k = 1:numSats 
                        relevant_data = data(strcmp(data.Source, "S" + num2str(k)) & strcmp(data.Target, "N" + num2str(j)), :);
                        if ~isempty(relevant_data) && k~=i
                            str_delays(2) = calculate_delay(str_delays(1), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                        else
                            continue;
                        end
            
                        if str_delays(2) > min_delay
                        continue
                    end
            
                        
                        for l = 2:N_nodes
                            relevant_data = data(strcmp(data.Source, "S" + num2str(k)) & strcmp(data.Target, "N" + num2str(l)), :);
                            if ~isempty(relevant_data) && l~=j
                                total_delay = calculate_delay(str_delays(2), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                str_delays(3) = total_delay;
                                if l == end_node && total_delay < min_delay
                                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l)];
                                    min_delay  = total_delay;
                                end
                            else
                                continue;
                            end
            
                            if str_delays(3) > min_delay
                                continue
                            end
            
            
                            for m = 1:numSats
                                relevant_data = data(strcmp(data.Source, "S" + num2str(m)) & strcmp(data.Target, "N" + num2str(l)), :);
                                if ~isempty(relevant_data) && k~=i && m~=i && k~=m
                                    str_delays(4) = calculate_delay(str_delays(3), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                else
                                    continue;
                                end
            
                                if str_delays(4) > min_delay
                                    continue
                                end
                                
                                for n = 2:N_nodes
                                    relevant_data = data(strcmp(data.Source, "S" + num2str(m)) & strcmp(data.Target, "N" + num2str(n)), :);
                                    if ~isempty(relevant_data) && l~=j && l~=n && j~=n
                                        total_delay = calculate_delay(str_delays(4), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                        str_delays(5) = total_delay;
                                        if n == end_node && total_delay < min_delay
                                            opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n)];
                                            min_delay  = total_delay;
                                        end
                                    else
                                        continue;
                                    end
            
                                    if str_delays(5) > min_delay
                                        continue
                                    end
            
                                    for o = 1:numSats
                                        relevant_data = data(strcmp(data.Source, "S" + num2str(o)) & strcmp(data.Target, "N" + num2str(n)), :);
                                        if ~isempty(relevant_data) && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o
                                            str_delays(6) = calculate_delay(str_delays(5), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                        else
                                            continue;
                                        end
            
                                        if str_delays(6) > min_delay
                                            continue
                                        end
                                        
                                        for p = 2:N_nodes
                                            relevant_data = data(strcmp(data.Source, "S" + num2str(o)) & strcmp(data.Target, "N" + num2str(p)), :);
                                            if ~isempty(relevant_data) && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p
                                                total_delay = calculate_delay(str_delays(6), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                str_delays(7) = total_delay;
                                                if p == end_node && total_delay < min_delay
                                                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p)];
                                                    min_delay  = total_delay;
                                                end
                                            else
                                                continue;
                                            end
            
                                            if str_delays(7) > min_delay
                                                continue
                                            end
            
                                            for q = 1:numSats
                                                relevant_data = data(strcmp(data.Source, "S" + num2str(q)) & strcmp(data.Target, "N" + num2str(p)), :);
                                                if ~isempty(relevant_data) && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o
                                                    str_delays(8) = calculate_delay(str_delays(7), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                else
                                                    continue;
                                                end
            
                                                if str_delays(8) > min_delay
                                                    continue
                                                end
                                                
                                                for r = 2:N_nodes
                                                    relevant_data = data(strcmp(data.Source, "S" + num2str(q)) & strcmp(data.Target, "N" + num2str(r)), :);
                                                    if ~isempty(relevant_data) && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p
                                                        total_delay = calculate_delay(str_delays(8), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                        str_delays(9) = total_delay;
                                                        if r == end_node && total_delay < min_delay
                                                            opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r)];
                                                            min_delay  = total_delay;
                                                        end
                                                    else
                                                        continue;
                                                    end
            
                                                    if str_delays(9) > min_delay
                                                        continue
                                                    end
            
                                                    for s = 1:numSats
                                                        relevant_data = data(strcmp(data.Source, "S" + num2str(s)) & strcmp(data.Target, "N" + num2str(r)), :);
                                                        if ~isempty(relevant_data) && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s
                                                            str_delays(10) = calculate_delay(str_delays(9), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                        else
                                                            continue;
                                                        end
            
                                                        if str_delays(10) > min_delay
                                                            continue
                                                        end
                                                        
                                                        for t = 2:N_nodes
                                                            relevant_data = data(strcmp(data.Source, "S" + num2str(s)) & strcmp(data.Target, "N" + num2str(t)), :);
                                                            if ~isempty(relevant_data) && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t
                                                                total_delay = calculate_delay(str_delays(10), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                                str_delays(11) = total_delay;
                                                                if t == end_node && total_delay < min_delay
                                                                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t)];
                                                                    min_delay  = total_delay;
                                                                end
                                                            else
                                                                continue;
                                                            end
                                                            
                                                            if str_delays(11) > min_delay
                                                                continue
                                                            end
                                                        
            
                                                            for u = 1:numSats
                                                                relevant_data = data(strcmp(data.Source, "S" + num2str(u)) & strcmp(data.Target, "N" + num2str(t)), :);
                                                                if ~isempty(relevant_data) && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s && u~=i && u~=k && u~=m && u~=o && u~=q && u~=s
                                                                    str_delays(12) = calculate_delay(str_delays(11), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                                else
                                                                    continue;
                                                                end
                                                                
                                                                if str_delays(12) > min_delay
                                                                    continue
                                                                end
                                                                for v = 2:N_nodes
                                                                    relevant_data = data(strcmp(data.Source, "S" + num2str(u)) & strcmp(data.Target, "N" + num2str(v)), :);
                                                                    if ~isempty(relevant_data) && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t && v~=j && v~=l && v~=n && v~=p && v~=r && v~=t 
                                                                        total_delay = calculate_delay(str_delays(12), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                                        str_delays(13) = total_delay;
                                                                        if v == end_node && total_delay < min_delay
                                                                            opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t), "S" + num2str(u), "N" + num2str(v)];
                                                                            min_delay  = total_delay;
                                                                        end
                                                                    else
                                                                        continue;
                                                                    end
            
                                                                    if str_delays(13) > min_delay
                                                                        continue
                                                                    end
            
                                                                    for w = 1:numSats
                                                                        relevant_data = data(strcmp(data.Source, "S" + num2str(w)) & strcmp(data.Target, "N" + num2str(v)), :);
                                                                        if ~isempty(relevant_data) && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s && u~=i && u~=k && u~=m && u~=o && u~=q && u~=s && w~=i && w~=k && w~=m && w~=o && w~=q && w~=s && w~=u
                                                                            str_delays(14) = calculate_delay(str_delays(13), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                                        else
                                                                            continue;
                                                                        end
            
                                                                        if str_delays(14) > min_delay
                                                                            continue
                                                                        end
                                                                        
                                                                        for x = 2:N_nodes
                                                                            relevant_data = data(strcmp(data.Source, "S" + num2str(w)) & strcmp(data.Target, "N" + num2str(x)), :);
                                                                            if ~isempty(relevant_data) && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t && v~=j && v~=l && v~=n && v~=p && v~=r && v~=t && x~=j && x~=l && x~=n && x~=p && x~=r && x~=t && x~=v
                                                                                total_delay = calculate_delay(str_delays(14), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                                                str_delays(15) = total_delay;
                                                                                if w == end_node && total_delay < min_delay
                                                                                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t), "S" + num2str(u), "N" + num2str(v), "S" + num2str(w), "N" + num2str(x)];
                                                                                    min_delay  = total_delay;
                                                                                end
                                                                            else
                                                                                continue;
                                                                            end
                                                                            if str_delays(15) > min_delay
                                                                                continue
                                                                            end
            
                                                                            for y = 1:numSats
                                                                                relevant_data = data(strcmp(data.Source, "S" + num2str(y)) & strcmp(data.Target, "N" + num2str(x)), :);
                                                                                if ~isempty(relevant_data) && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s && u~=i && u~=k && u~=m && u~=o && u~=q && u~=s && w~=i && w~=k && w~=m && w~=o && w~=q && w~=s && w~=u && y~=i && y~=k && y~=m && y~=o && y~=q && y~=s && y~=u && y~=w
                                                                                    str_delays(16) = calculate_delay(str_delays(15), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                                                else
                                                                                    continue;
                                                                                end
            
                                                                                if str_delays(16) > min_delay
                                                                                    continue
                                                                                end
                                                                                
                                                                                for z = 2:N_nodes
                                                                                    relevant_data = data(strcmp(data.Source, "S" + num2str(y)) & strcmp(data.Target, "N" + num2str(z)), :);
                                                                                    if ~isempty(relevant_data) && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t && v~=j && v~=l && v~=n && v~=p && v~=r && v~=t && x~=j && x~=l && x~=n && x~=p && x~=r && x~=t && x~=v && z~=j && z~=l && z~=n && z~=p && z~=r && z~=t && z~=v && z~=x
                                                                                        total_delay = calculate_delay(str_delays(16), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                                                        str_delays(17) = total_delay;
                                                                                        if z == end_node && total_delay < min_delay
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
            time_bruteforce = toc;
            total_time_bruteforce = total_time_bruteforce + time_bruteforce;
            
            % Floyd-Warshall Timing
            tic;
            delay = FloydWarshall(outputFilename, 1, end_node, numNodes);
            time_floydwarshall = toc;
            total_time_floydwarshall = total_time_floydwarshall + time_floydwarshall;
        end
        
        % Calculate the average processing time over the Monte Carlo iterations
        avg_time_bruteforce = total_time_bruteforce / num_iterations;
        avg_time_floydwarshall = total_time_floydwarshall / num_iterations;
        
        % Display results
        disp(numSats);
        disp(numNodes);
        disp("Monte Carlo Results");
        disp("Average CPU time for Brute-force :");
        disp(avg_time_bruteforce);
        disp("Average CPU time for Floyd-Warshall :");
        disp(avg_time_floydwarshall);
        disp("-------------------------------");
    end
end

