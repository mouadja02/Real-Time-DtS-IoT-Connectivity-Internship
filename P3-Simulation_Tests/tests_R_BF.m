clc; close all; clear all;

data = readtable('access_intervals.csv');

% Parameters
num_iterations = 100;
connectivity_duration = 420;

orbital_period = 3600 * 1.59;
end_node = 12;

total_number_nodes = 24;
total_number_sats = 24;

% Generate the full range of values from 12 to 24
full_range = 1:24;

% Exclude 1 and 12 from the full range
excluded_values = [1, 12];

% Initialize results storage
results_R1 = [];
results_R1_R2 = [];
results_R1_R2_R3 = [];
results_R2 = [];

for numNodes = 22
    for numSats = 6:2:24 
        % Run the Monte Carlo simulation for each case
        total_time_BF = 0;

        total_time_R_BF = 0;
        total_time_R1_4 = 0;
        total_time_R2_4 = 0;
        total_time_R3_4 = 0;

        total_time_R1_BF = 0;
        total_time_R1_1 = 0;


        total_time_R2_BF = 0;
        total_time_R1_2 = 0;
        total_time_R2_2 = 0;

        total_R2_BF_3 = 0;
        total_time_R2_3 = 0;
        

        accuracy = 0;
        for mc_iter = 1:num_iterations
            filtered_range = setdiff(full_range, excluded_values);
    
            random_nodes = filtered_range(randperm(length(filtered_range), numNodes));
            nodes_array = [1, random_nodes, 12];
            sats_array = 1 + randperm(24 - 1 + 1, numSats) - 1;
            
            % Définir l'ordre des satellites et des nœuds
            satellites = {'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'S10', 'S11', 'S12', 'S13', 'S14', 'S15', 'S16', 'S17', 'S18','S19','S20','S21','S22','S23','S24'};
            nodes = {'N1', 'N2', 'N3', 'N4', 'N5', 'N6', 'N7', 'N8', 'N9', 'N10', 'N11', 'N12', 'N13', 'N14', 'N15', 'N16', 'N17', 'N18', 'N19', 'N20','N21','N22','N23','N24'};
    
            % Initialiser la matrice avec des valeurs 'inf' par défaut
            matrix = inf(total_number_nodes, total_number_sats);
            
            % Remplir la matrice avec les temps de début de connexion
            for i = 1:height(data)
                node = data.Target{i};
                satellite = data.Source{i};
                startTime = data.StartTime(i);
                delay_str = sprintf('%s', datestr(startTime, 'HH:MM:SS'));
            
                % Trouver les indices correspondants
            
                nodeIdx = find(strcmp(nodes, node));
                satelliteIdx = find(strcmp(satellites, satellite));
            
               if ~ismember(nodeIdx,nodes_array)
                   continue;
               end
            
               if ~ismember(satelliteIdx,sats_array)
                   continue;
               end
            
                % Mettre à jour la matrice avec le premier temps de début de connexion
                if matrix(nodeIdx, satelliteIdx) == inf
                    S = str2double(delay_str(1:2)) * 3600 + str2double(delay_str(4:5)) * 60 + str2double(delay_str(7:8));
                    matrix(nodeIdx, satelliteIdx) = S;
                end
            end
            R2_time = 0;
            R3_time = 0;
            % Bruteforce Timing
            tic;
            [path1, delay1] = bruteforce_routing(matrix, nodes_array, sats_array, end_node, connectivity_duration, orbital_period,numNodes, numSats);
            time_bruteforce = toc;
            total_time_BF = total_time_BF + time_bruteforce;
   
            %% R1 only
            [~,sat_NR]=min(matrix(1,:));
            dNR = calculate_delay(matrix(1,sat_NR),matrix(end_node,sat_NR),connectivity_duration,orbital_period);
            
            tic;
            % R1: Eliminer tout delai superieur ou egal a dNR
            if dNR~=inf
                for i=1:numSats
                    for j=1:numSats
                        if matrix(i,j)>= dNR         
                            matrix(i,j)=inf;
                        end
                    end
                end
            end
            R1_time_1 = toc;
            total_time_R1_1 = total_time_R1_1 + R1_time_1;

        
          
            tic;
            [~, ~] = bruteforce_routing(matrix, nodes_array, sats_array, end_node, connectivity_duration, orbital_period,numNodes, numSats);
            
        time_R1_BF = toc;
        total_time_R1_BF = total_time_R1_BF + time_R1_BF;

%% R1 and R2
            [~,sat_NR]=min(matrix(1,:));
            dNR = calculate_delay(matrix(1,sat_NR),matrix(end_node,sat_NR),connectivity_duration,orbital_period);
            
            tic;
            % R1: Eliminer tout delai superieur ou egal a dNR
            if dNR~=inf
                for i=1:numSats
                    for j=1:numSats
                        if matrix(i,j)>= dNR         
                            matrix(i,j)=inf;
                        end
                    end
                end
            end
            R1_time = toc;
        
           tic;
           [~,max_GS]=max(matrix(end_node,:));
           dGS_max = matrix(end_node,max_GS);


            % R2: Eliminer tout delai non accessibles par GS au pire des cas
            for i=1:numNodes
                for j=1:numSats
                    if matrix(i,j)>dGS_max+connectivity_duration
                        matrix(i,j)=inf;
                    end
                end
            end
            R2_time = toc;

            total_time_R1_2 = total_time_R1_2 + R1_time;
            total_time_R2_2 = total_time_R2_2 + R2_time;
            tic;
            [~, ~] = bruteforce_routing(matrix, nodes_array, sats_array, end_node, connectivity_duration, orbital_period,numNodes, numSats);

            time_R_BF = toc;
            total_time_R2_BF = total_time_R2_BF + time_R_BF;
                
     

%% R1 R2 R3
            [~,sat_NR]=min(matrix(1,:));
            dNR = calculate_delay(matrix(1,sat_NR),matrix(end_node,sat_NR),connectivity_duration,orbital_period);
            
            tic;
            % R1: Eliminer tout delai superieur ou egal a dNR
            if dNR~=inf
                for i=1:numSats
                    for j=1:numSats
                        if matrix(i,j)>= dNR         
                            matrix(i,j)=inf;
                        end
                    end
                end
            end
            R1_time = toc;
        
       
           tic;
           [~,max_GS]=max(matrix(end_node,:));
           dGS_max = matrix(end_node,max_GS);


            % R2: Eliminer tout delai non accessibles par GS au pire des cas
            for i=1:numNodes
                for j=1:numSats
                    if matrix(i,j)>dGS_max+connectivity_duration
                        matrix(i,j)=inf;
                    end
                end
            end
            R2_time = toc;

            % R3
            tic;
            % Check rows
            for i = 2:numNodes
                if i~=end_node
                    % Check how many elements are not inf in the row
                    non_inf_elements = ~isinf(matrix(i, :));

                    % If only one element is not inf, set it to inf
                    if sum(non_inf_elements) == 1
                        matrix(i, non_inf_elements) = inf;
                    end
                end
            end

            % Check columns
            for j = 1:numSats
                % Check how many elements are not inf in the column
                non_inf_elements = ~isinf(matrix(:, j));

                % If only one element is not inf, set it to inf
                if sum(non_inf_elements) == 1
                    matrix(non_inf_elements, j) = inf;
                end
            end
 
            R3_time = toc;
            total_time_R1_4 = total_time_R1_4 + R1_time;
            total_time_R2_4 = total_time_R2_4 + R2_time;
            total_time_R3_4 = total_time_R3_4 + R3_time;
            tic;
            [path2, delay2] = bruteforce_routing(matrix, nodes_array, sats_array, end_node, connectivity_duration, orbital_period,numNodes, numSats);
        
            
        time_R_BF = toc;
        total_time_R_BF = total_time_R_BF + time_R_BF;

         %% R2 only
            tic;
           [~,max_GS]=max(matrix(end_node,:));
           dGS_max = matrix(end_node,max_GS);


            % R2: Eliminer tout delai non accessibles par GS au pire des cas
            for i=1:numNodes
                for j=1:numSats
                    if matrix(i,j)>dGS_max+connectivity_duration
                        matrix(i,j)=inf;
                    end
                end
            end
            R2_time = toc;

            total_time_R2_3 = total_time_R2_3 + R2_time;

        
          
            tic;
            [~, ~] = bruteforce_routing(matrix, nodes_array, sats_array, end_node, connectivity_duration, orbital_period,numNodes, numSats);
            
        time_R2_BF = toc;
        total_R2_BF_3 = total_R2_BF_3 + time_R2_BF;

        end
        
        % Calculate averages
        avg_time_BF = total_time_BF / num_iterations;

        avg_time_R_BF = total_time_R1_BF / num_iterations;
        avg_time_R = total_time_R1_1 / num_iterations;


    
        [~, cols1] = size(nodes_array);
        [~, cols2] = size(sats_array);

        % Store results
        newRow = table(cols1, cols2, avg_time_BF, avg_time_R,avg_time_R_BF, avg_time_R_BF+avg_time_R,...
                       'VariableNames', {'Number_of_Nodes', 'Number_of_Sats', 'BF1_CPU_time','R1_CPU_time', ...
                       'BF2_CPU_time', 'R_BF_total_time'});
        results_R1 = [results_R1; newRow];

        avg_time_R_BF = total_R2_BF_3 / num_iterations;
        avg_time_R = total_time_R2_3 / num_iterations;


    
        [~, cols1] = size(nodes_array);
        [~, cols2] = size(sats_array);

        % Store results
        newRow = table(cols1, cols2, avg_time_BF, avg_time_R,avg_time_R_BF, avg_time_R_BF+avg_time_R,...
                       'VariableNames', {'Number_of_Nodes', 'Number_of_Sats', 'BF1_CPU_time','R1_CPU_time', ...
                       'BF2_CPU_time', 'R_BF_total_time'});
        results_R2 = [results_R2; newRow];


        avg_time_R_BF = total_time_R2_BF / num_iterations;
        avg_time_R1 = total_time_R1_2 / num_iterations;
        avg_time_R2 = total_time_R2_2 / num_iterations;


    
        [~, cols1] = size(nodes_array);
        [~, cols2] = size(sats_array);

        % Store results
        newRow = table(cols1, cols2, avg_time_BF, avg_time_R1, avg_time_R2,avg_time_R_BF, avg_time_R_BF+avg_time_R1+avg_time_R2,...
                       'VariableNames', {'Number_of_Nodes', 'Number_of_Sats', 'BF1_CPU_time','R1_CPU_time', 'R2_CPU_time', ...
                       'BF2_CPU_time', 'R_BF_total_time'});
        results_R1_R2 = [results_R1_R2; newRow];


        avg_time_R_BF = total_time_R_BF / num_iterations;
        avg_time_R1 = total_time_R1_4 / num_iterations;
        avg_time_R2 = total_time_R2_4 / num_iterations;
        avg_time_R3 = total_time_R3_4 / num_iterations;

    
        % Store results
        newRow = table(cols1, cols2, avg_time_BF, avg_time_R1, avg_time_R2, avg_time_R3,avg_time_R_BF, avg_time_R_BF+avg_time_R1+avg_time_R2+avg_time_R3,...
                       'VariableNames', {'Number_of_Nodes', 'Number_of_Sats', 'BF1_CPU_time','R1_CPU_time', 'R2_CPU_time', 'R3_CPU_time', ...
                       'BF2_CPU_time', 'R_BF_total_time'});
        results_R1_R2_R3 = [results_R1_R2_R3; newRow];

    end
end

% Write the results table to a CSV file
writetable(results_R1_R2_R3, 'R1_R2_R3_BF_results.csv');
writetable(results_R1, 'R1__BF_results.csv');
writetable(results_R1_R2, 'R1_R2_BF_results.csv');
writetable(results_R2, 'R2_BF_results.csv');
disp('Simulation complete. Results written to output files');



% Function for Bruteforce routing
function [opt_path, min_delay] = bruteforce_routing(matrix, nodes_array, sats_array, end_node, connectivity_duration, orbital_period, numNodes, numSats)
    min_delay = inf;
    opt_path = [];
    num_hops = min(numNodes, 2*numSats);
    for i = sats_array
        if matrix(1,i)~=inf
            delay1 = matrix(1,i);
        else
            continue;
        end
        
        for j = nodes_array
            if matrix(j,i)~=inf && j~=1
                delay2  = calculate_delay(delay1, matrix(j,i), connectivity_duration, orbital_period);
               
                if j == end_node && delay2<min_delay
                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j)];
                    min_delay  = delay2;
                    continue;
                end
                
            else
                continue;
            end

            if num_hops < 4
                continue;
            end
    
            for k = sats_array 
                if matrix(j,k)~=inf && k~=i
                    delay3 = calculate_delay(delay2, matrix(j,k), connectivity_duration, orbital_period);
                else
                    continue;
                end
    
                for l = nodes_array
                    if matrix(l,k)~=inf && l~=j && l~=1
                        delay4 = calculate_delay(delay3, matrix(l,k), connectivity_duration, orbital_period);
                        if l == end_node && delay4<min_delay
                            opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l)];
                            min_delay  = delay4;
                            continue;
                        end
                        
                    else
                        continue;
                    end

                    if num_hops < 6
                        continue;
                    end
    
                    for m = sats_array
                        if matrix(l,m)~=inf && k~=i && m~=i && k~=m
                            delay5 = calculate_delay(delay4, matrix(l,m), connectivity_duration, orbital_period);
                        else
                            continue;
                        end
                        
                        for n = nodes_array
                            if matrix(n,m)~=inf && l~=j && l~=n && j~=n && n~=1
                                delay6 = calculate_delay(delay5, matrix(n,m), connectivity_duration, orbital_period);
                                if n == end_node  && delay6<min_delay
                                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n)];
                                    min_delay  = delay6;
                                    continue;
                                end  
                            else
                                continue;
                            end

                            if num_hops < 8
                                continue;
                            end

                            for o = sats_array
                                if matrix(n,o)~=inf && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o
                                    delay7 = calculate_delay(delay6, matrix(n,o), connectivity_duration, orbital_period);
                                    if delay7 > min_delay
                                        continue;
                                    end
                                else
                                    continue;
                                end


                                for p = nodes_array
                                    if matrix(p,o)~=inf && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p
                                        delay8 = calculate_delay(delay7, matrix(p,o), connectivity_duration, orbital_period);
                                        if delay8 > min_delay
                                            continue;
                                        else
                                            if p == end_node
                                                opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p)];
                                                min_delay  = delay8;
                                                continue;
                                            end
                                        end

                                    else
                                        continue;
                                    end

                                    if num_hops < 10
                                        continue;
                                    end

                                    for q = sats_array
                                        if matrix(p,q)~=inf && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o
                                            delay9 = calculate_delay(delay8, matrix(p,q), connectivity_duration, orbital_period);
                                            if delay9 > min_delay
                                                continue;
                                            end
                                        else
                                            continue;
                                        end



                                        for r = nodes_array
                                            if matrix(r,q)~=inf && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p
                                                total_delay = calculate_delay(delay9, matrix(r,q), connectivity_duration, orbital_period);
                                                delay10 = total_delay;
                                                if delay10 > min_delay
                                                    continue;
                                                end
                                                if r == end_node && total_delay < min_delay
                                                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r)];
                                                    min_delay  = total_delay;
                                                end
                                            else
                                                continue;
                                            end

                                            if num_hops < 12
                                                continue;
                                            end


                                            for s = sats_array
                                                if matrix(r,s)~=inf && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s
                                                    delay11 = calculate_delay(delay10, matrix(r,s), connectivity_duration, orbital_period);
                                                    if delay11 > min_delay
                                                        continue;
                                                    end
                                                else
                                                    continue;
                                                end

                                                for t = nodes_array
                                                    if matrix(t,s)~=inf && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t
                                                        total_delay = calculate_delay(delay11, matrix(t,s), connectivity_duration, orbital_period);
                                                        delay12 = total_delay;
                                                        if delay12 > min_delay
                                                            continue;
                                                        end
                                                        if t == end_node && total_delay < min_delay
                                                            opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t)];
                                                            min_delay  = total_delay;
                                                        end
                                                    else
                                                        continue;
                                                    end

                                                    if num_hops < 14
                                                        continue;
                                                    end

                                                    for u = sats_array
                                                        if matrix(t,u)~=inf && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s && u~=i && u~=k && u~=m && u~=o && u~=q && u~=s
                                                            delay13 = calculate_delay(delay12, matrix(t,u)~=inf, connectivity_duration, orbital_period);
                                                            if delay13 > min_delay
                                                                continue;
                                                            end
                                                        else
                                                            continue;
                                                        end

                                                        for v = nodes_array
                                                            if matrix(v,u)~=inf && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t && v~=j && v~=l && v~=n && v~=p && v~=r && v~=t 
                                                                total_delay = calculate_delay(delay13, matrix(v,u), connectivity_duration, orbital_period);
                                                                delay14 = total_delay;
                                                                if delay14 > min_delay
                                                                    continue;
                                                                end
                                                                if v == end_node && total_delay < min_delay
                                                                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t), "S" + num2str(u), "N" + num2str(v)];
                                                                    min_delay  = total_delay;
                                                                end
                                                            else
                                                                continue;
                                                            end

                                                            if num_hops < 16
                                                                continue;
                                                            end

                                                                for w = sats_array
                                                                         if matrix(v,w)~=inf && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s && u~=i && u~=k && u~=m && u~=o && u~=q && u~=s && w~=i && w~=k && w~=m && w~=o && w~=q && w~=s && w~=u
                                                                            delay15 = calculate_delay(delay14, matrix(v,w), connectivity_duration, orbital_period);
                                                                            if delay15 > min_delay
                                                                                continue;
                                                                            end
                                                                        else
                                                                            continue;
                                                                        end

                                                                        for x = nodes_array
                                                                            if matrix(x,w)~=inf && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t && v~=j && v~=l && v~=n && v~=p && v~=r && v~=t && x~=j && x~=l && x~=n && x~=p && x~=r && x~=t && x~=v
                                                                                total_delay = calculate_delay(delay15, matrix(x,w), connectivity_duration, orbital_period);
                                                                                delay16 = total_delay;
                                                                                if delay16 > min_delay
                                                                                    continue;
                                                                                end
                                                                                if w == end_node && total_delay < min_delay
                                                                                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t), "S" + num2str(u), "N" + num2str(v), "S" + num2str(w), "N" + num2str(x)];
                                                                                    min_delay  = total_delay;
                                                                                end
                                                                            else
                                                                                continue;
                                                                            end

                                                                            if num_hops < 18
                                                                                continue;
                                                                            end

                                                                            for y = sats_array
                                                                                if matrix(x,y)~=inf && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s && u~=i && u~=k && u~=m && u~=o && u~=q && u~=s && w~=i && w~=k && w~=m && w~=o && w~=q && w~=s && w~=u && y~=i && y~=k && y~=m && y~=o && y~=q && y~=s && y~=u && y~=w
                                                                                    delay17 = calculate_delay(delay16, matrix(x,y), connectivity_duration, orbital_period);
                                                                                    if delay17 > min_delay
                                                                                        continue;
                                                                                    end
                                                                                else
                                                                                    continue;
                                                                                end
                                                                                for z = nodes_array
                                                                                    if matrix(z,y)~=inf && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t && v~=j && v~=l && v~=n && v~=p && v~=r && v~=t && x~=j && x~=l && x~=n && x~=p && x~=r && x~=t && x~=v && z~=j && z~=l && z~=n && z~=p && z~=r && z~=t && z~=v && z~=x
                                                                                        total_delay = calculate_delay(delay17, matrix(z,y), connectivity_duration, orbital_period);
                                                                                        if z == end_node && total_delay < min_delay
                                                                                            opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t), "S" + num2str(u), "N" + num2str(v), "S" + num2str(w), "N" + num2str(x), "S" + num2str(y), "N" + num2str(z)];
                                                                                            min_delay  = total_delay;
                                                                                        end
                                                                                    else
                                                                                        continue;
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
end
