clc; close all; clear all;

% Open the file for writing
fid = fopen('cpu_time_and_delays3.txt', 'w');
fprintf(fid, 'Number of Satellites, Number of Nodes, Brute-force Min Delay, Floyd-Warshall Delay, Brute-force CPU Time, Floyd-Warshall CPU Time\n');
end_node = 8;

% Load the CSV file
filename = 'access_intervals.csv';
data = readtable(filename);  

for numberOfSatellites=6:2:24
    % Number of nodes and satellites
    numNodes = 24;
    numberOfNodes = numNodes;
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
    
        if node > numNodes || satellite > numSats
            continue;
        end
    
        startTime = data.StartTime(i);
    
        delay = sprintf('%s', datestr(startTime, 'HH:MM:SS'));
    
        % Update the matrix with the first start time of connection
        if done(node, satellite - numNodes) == false
            S = str2double(delay(1:2)) * 3600 + str2double(delay(4:5)) * 60 + str2double(delay(7:8));
            done(node, satellite - numNodes) = true;
        end
    
        adjacencyList = [adjacencyList; node, satellite, S];
    end
    
    % Create the output file
    outputFilename = 'input.txt';
    fid_adjacency = fopen(outputFilename, 'w');
    
    % Write the number of vertices and edges
    fprintf(fid_adjacency, '%d\n', numNodes + numSats);
    fprintf(fid_adjacency, '%d\n', 2 * height(data));
    
    % Write the adjacency list
    for i = 1:size(adjacencyList, 1)
        fprintf(fid_adjacency, '%d %d %d\n', adjacencyList(i, 1), adjacencyList(i, 2), adjacencyList(i, 3));
    end
    
    for i = 1:size(adjacencyList, 1)
        fprintf(fid_adjacency, '%d %d %d\n', adjacencyList(i, 2), adjacencyList(i, 1), adjacencyList(i, 3));
    end
    
    % Close the file
    fclose(fid_adjacency);
    
    disp(['Output written to ', outputFilename]);

    N_nodes = numNodes;
    N_sats = numberOfSatellites;
    
    str_delays = zeros(1, 2 * N_sats);
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
    
        for j = 2:N_nodes
            relevant_data = data(strcmp(data.Source, "S" + num2str(i)) & strcmp(data.Target, "N" + num2str(j)), :);
            if ~isempty(relevant_data) && j ~= 1
                delay2 = seconds(min(relevant_data.StartTime));
                total_delay = calculate_delay(delay1, delay2, connectivity_duration, orbital_period);
                str_delays(1) = total_delay;
                if j == end_node && total_delay < min_delay
                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j)];
                    min_delay = total_delay;
                end
            else
                continue;
            end
    
            if str_delays(1) > min_delay
                continue
            end
    
            for k = 1:N_sats
                relevant_data = data(strcmp(data.Source, "S" + num2str(k)) & strcmp(data.Target, "N" + num2str(j)), :);
                if ~isempty(relevant_data) && k ~= i
                    str_delays(2) = calculate_delay(str_delays(1), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                else
                    continue;
                end
    
                if str_delays(2) > min_delay
                    continue
                end
    
                for l = 2:N_nodes
                    relevant_data = data(strcmp(data.Source, "S" + num2str(k)) & strcmp(data.Target, "N" + num2str(l)), :);
                    if ~isempty(relevant_data) && l ~= j
                        total_delay = calculate_delay(str_delays(2), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                        str_delays(3) = total_delay;
                        if l == end_node && total_delay < min_delay
                            opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l)];
                            min_delay = total_delay;
                        end
                    else
                        continue;
                    end
    
                    if str_delays(3) > min_delay
                        continue
                    end
    
                    for m = 1:N_sats
                        relevant_data = data(strcmp(data.Source, "S" + num2str(m)) & strcmp(data.Target, "N" + num2str(l)), :);
                        if ~isempty(relevant_data) && k ~= i && m ~= i && k ~= m
                            str_delays(4) = calculate_delay(str_delays(3), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                        else
                            continue;
                        end
    
                        if str_delays(4) > min_delay
                            continue
                        end
    
                        for n = 2:N_nodes
                            relevant_data = data(strcmp(data.Source, "S" + num2str(m)) & strcmp(data.Target, "N" + num2str(n)), :);
                            if ~isempty(relevant_data) && l ~= j && l ~= n && j ~= n
                                total_delay = calculate_delay(str_delays(4), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                str_delays(5) = total_delay;
                                if n == end_node && total_delay < min_delay
                                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n)];
                                    min_delay = total_delay;
                                end
                            else
                                continue;
                            end
    
                            if str_delays(5) > min_delay
                                continue
                            end
    
                            for o = 1:N_sats
                                relevant_data = data(strcmp(data.Source, "S" + num2str(o)) & strcmp(data.Target, "N" + num2str(n)), :);
                                if ~isempty(relevant_data) && k ~= i && m ~= i && k ~= m && k ~= o && o ~= i && m ~= o
                                    str_delays(6) = calculate_delay(str_delays(5), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                else
                                    continue;
                                end
    
                                if str_delays(6) > min_delay
                                    continue
                                end
    
                                for p = 2:N_nodes
                                    relevant_data = data(strcmp(data.Source, "S" + num2str(o)) & strcmp(data.Target, "N" + num2str(p)), :);
                                    if ~isempty(relevant_data) && l ~= j && l ~= n && j ~= n && l ~= p && p ~= n && j ~= p
                                        total_delay = calculate_delay(str_delays(6), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                        str_delays(7) = total_delay;
                                        if p == end_node && total_delay < min_delay
                                            opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p)];
                                            min_delay = total_delay;
                                        end
                                    else
                                        continue;
                                    end
    
                                    if str_delays(7) > min_delay
                                        continue
                                    end
    
                                    for q = 1:N_sats
                                        relevant_data = data(strcmp(data.Source, "S" + num2str(q)) & strcmp(data.Target, "N" + num2str(p)), :);
                                        if ~isempty(relevant_data) && k ~= i && m ~= i && k ~= m && k ~= o && o ~= i && m ~= o && q ~= i && m ~= q && k ~= q && q ~= o
                                            str_delays(8) = calculate_delay(str_delays(7), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                        else
                                            continue;
                                        end
    
                                        if str_delays(8) > min_delay
                                            continue
                                        end
    
                                        for r = 2:N_nodes
                                            relevant_data = data(strcmp(data.Source, "S" + num2str(q)) & strcmp(data.Target, "N" + num2str(r)), :);
                                            if ~isempty(relevant_data) && l ~= j && l ~= n && j ~= n && l ~= p && p ~= n && j ~= p && j ~= r && l ~= r && r ~= n && r ~= p
                                                total_delay = calculate_delay(str_delays(8), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                str_delays(9) = total_delay;
                                                if r == end_node && total_delay < min_delay
                                                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r)];
                                                    min_delay = total_delay;
                                                end
                                            else
                                                continue;
                                            end
    
                                            if str_delays(9) > min_delay
                                                continue
                                            end
    
                                            for s = 1:N_sats
                                                relevant_data = data(strcmp(data.Source, "S" + num2str(s)) & strcmp(data.Target, "N" + num2str(r)), :);
                                                if ~isempty(relevant_data) && k ~= i && m ~= i && k ~= m && k ~= o && o ~= i && m ~= o && q ~= i && m ~= q && k ~= q && q ~= o && s ~= o && s ~= i && m ~= s && k ~= s && q ~= s
                                                    str_delays(10) = calculate_delay(str_delays(9), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                else
                                                    continue;
                                                end
    
                                                if str_delays(10) > min_delay
                                                    continue
                                                end
    
                                                for t = 2:N_nodes
                                                    relevant_data = data(strcmp(data.Source, "S" + num2str(s)) & strcmp(data.Target, "N" + num2str(t)), :);
                                                    if ~isempty(relevant_data) && l ~= j && l ~= n && j ~= n && l ~= p && p ~= n && j ~= p && j ~= r && l ~= r && r ~= n && r ~= p && t ~= p && j ~= t && l ~= t && t ~= n && r ~= t
                                                        total_delay = calculate_delay(str_delays(10), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                        str_delays(11) = total_delay;
                                                        if t == end_node && total_delay < min_delay
                                                            opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t)];
                                                            min_delay = total_delay;
                                                        end
                                                    else
                                                        continue;
                                                    end
    
                                                    if str_delays(11) > min_delay
                                                        continue
                                                    end
    
                                                    for u = 1:N_sats
                                                        relevant_data = data(strcmp(data.Source, "S" + num2str(u)) & strcmp(data.Target, "N" + num2str(t)), :);
                                                        if ~isempty(relevant_data) && k ~= i && m ~= i && k ~= m && k ~= o && o ~= i && m ~= o && q ~= i && m ~= q && k ~= q && q ~= o && s ~= o && s ~= i && m ~= s && k ~= s && q ~= s && u ~= i && u ~= k && u ~= m && u ~= o && u ~= q && u ~= s
                                                            str_delays(12) = calculate_delay(str_delays(11), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                        else
                                                            continue;
                                                        end
    
                                                        if str_delays(12) > min_delay
                                                            continue
                                                        end
                                                        for v = 2:N_nodes
                                                            relevant_data = data(strcmp(data.Source, "S" + num2str(u)) & strcmp(data.Target, "N" + num2str(v)), :);
                                                            if ~isempty(relevant_data) && l ~= j && l ~= n && j ~= n && l ~= p && p ~= n && j ~= p && j ~= r && l ~= r && r ~= n && r ~= p && t ~= p && j ~= t && l ~= t && t ~= n && r ~= t && v ~= j && v ~= l && v ~= n && v ~= p && v ~= r && v ~= t
                                                                total_delay = calculate_delay(str_delays(12), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                                str_delays(13) = total_delay;
                                                                if v == end_node && total_delay < min_delay
                                                                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t), "S" + num2str(u), "N" + num2str(v)];
                                                                    min_delay = total_delay;
                                                                end
                                                            else
                                                                continue;
                                                            end
    
                                                            if str_delays(13) > min_delay
                                                                continue
                                                            end
    
                                                            for w = 1:N_sats
                                                                relevant_data = data(strcmp(data.Source, "S" + num2str(w)) & strcmp(data.Target, "N" + num2str(v)), :);
                                                                if ~isempty(relevant_data) && k ~= i && m ~= i && k ~= m && k ~= o && o ~= i && m ~= o && q ~= i && m ~= q && k ~= q && q ~= o && s ~= o && s ~= i && m ~= s && k ~= s && q ~= s && u ~= i && u ~= k && u ~= m && u ~= o && u ~= q && u ~= s && w ~= i && w ~= k && w ~= m && w ~= o && w ~= q && w ~= s && w ~= u
                                                                    str_delays(14) = calculate_delay(str_delays(13), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                                else
                                                                    continue;
                                                                end
    
                                                                if str_delays(14) > min_delay
                                                                    continue
                                                                end
    
                                                                for x = 2:N_nodes
                                                                    relevant_data = data(strcmp(data.Source, "S" + num2str(w)) & strcmp(data.Target, "N" + num2str(x)), :);
                                                                    if ~isempty(relevant_data) && l ~= j && l ~= n && j ~= n && l ~= p && p ~= n && j ~= p && j ~= r && l ~= r && r ~= n && r ~= p && t ~= p && j ~= t && l ~= t && t ~= n && r ~= t && v ~= j && v ~= l && v ~= n && v ~= p && v ~= r && v ~= t && x ~= j && x ~= l && x ~= n && x ~= p && x ~= r && x ~= t && x ~= v
                                                                        total_delay = calculate_delay(str_delays(14), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                                        str_delays(15) = total_delay;
                                                                        if w == end_node && total_delay < min_delay
                                                                            opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t), "S" + num2str(u), "N" + num2str(v), "S" + num2str(w), "N" + num2str(x)];
                                                                            min_delay = total_delay;
                                                                        end
                                                                    else
                                                                        continue;
                                                                    end
                                                                    if str_delays(15) > min_delay
                                                                        continue
                                                                    end
    
                                                                    for y = 1:N_sats
                                                                        relevant_data = data(strcmp(data.Source, "S" + num2str(y)) & strcmp(data.Target, "N" + num2str(x)), :);
                                                                        if ~isempty(relevant_data) && k ~= i && m ~= i && k ~= m && k ~= o && o ~= i && m ~= o && q ~= i && m ~= q && k ~= q && q ~= o && s ~= o && s ~= i && m ~= s && k ~= s && q ~= s && u ~= i && u ~= k && u ~= m && u ~= o && u ~= q && u ~= s && w ~= i && w ~= k && w ~= m && w ~= o && w ~= q && w ~= s && w ~= u && y ~= i && y ~= k && y ~= m && y ~= o && y ~= q && y ~= s && y ~= u && y ~= w
                                                                            str_delays(16) = calculate_delay(str_delays(15), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                                        else
                                                                            continue;
                                                                        end
    
                                                                        if str_delays(16) > min_delay
                                                                            continue
                                                                        end
    
                                                                        for z = 2:N_nodes
                                                                            relevant_data = data(strcmp(data.Source, "S" + num2str(y)) & strcmp(data.Target, "N" + num2str(z)), :);
                                                                            if ~isempty(relevant_data) && l ~= j && l ~= n && j ~= n && l ~= p && p ~= n && j ~= p && j ~= r && l ~= r && r ~= n && r ~= p && t ~= p && j ~= t && l ~= t && t ~= n && r ~= t && v ~= j && v ~= l && v ~= n && v ~= p && v ~= r && v ~= t && x ~= j && x ~= l && x ~= n && x ~= p && x ~= r && x ~= t && x ~= v && z ~= j && z ~= l && z ~= n && z ~= p && z ~= r && z ~= t && z ~= v && z ~= x
                                                                                total_delay = calculate_delay(str_delays(16), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                                                                str_delays(17) = total_delay;
                                                                                if z == end_node && total_delay < min_delay
                                                                                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t), "S" + num2str(u), "N" + num2str(v), "S" + num2str(w), "N" + num2str(x), "S" + num2str(y), "N" + num2str(z)];
                                                                                    min_delay = total_delay;
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
    
    brute_force_time = toc;
    
    disp(numberOfSatellites);
    disp(numberOfNodes);
    disp("Bruteforce Results");
    disp("Shortest path :");
    if min_delay ~= inf
        display(opt_path);
        hops = length(opt_path) - 1;
        display(hops);
        display(min_delay);
    end
    tic
    delay = FloydWarshall(outputFilename, 1, end_node, numberOfNodes);
    floyd_warshall_time = toc;
    disp("-------------------------------");
    
    % Write results to file
    fprintf(fid, '%d, %d, %f, %f, %f, %f\n', numberOfSatellites, numberOfNodes, min_delay, delay, brute_force_time, floyd_warshall_time);        

    clearvars -except data filename fid end_node
end


% Close the file
fclose(fid);