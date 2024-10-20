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
results = [];


for numNodes = 10:6:22
    for numSats = 6:2:24  
        % Run the Monte Carlo simulation for each case
        total_time_BF = 0;
        total_time_R_Dijkstra = 0;
        total_time_Dijkstra = 0;

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
    
            tic
            [path, delay] = best_path(matrix, 1, end_node, connectivity_duration, orbital_period);
            time_dijkstra = toc;
            total_time_Dijkstra = total_time_Dijkstra + time_dijkstra;

            tic;
            [~,sat_NR]=min(matrix(1,:));
            dNR = calculate_delay(matrix(1,sat_NR),matrix(end_node,sat_NR),connectivity_duration,orbital_period);
            
            % R1: Eliminer tout delai superieur ou egal a dNR
            for i=1:numSats
                for j=1:numSats
                    if matrix(i,j)>=dNR
                        matrix(i,j)=inf;
                    end
                end
            end
        
        
           if all(isinf(matrix(1, :))) || all(isinf(matrix(end, :)))
                accuracy = accuracy + 1;
           else
               [~,max_GS]=max(matrix(end_node,:));
               dGS_max = matrix(end_node,max_GS);
                [~,min_1]=min(matrix(1,:));
                d1_min = matrix(1,min_1);


                % R2+R3: Eliminer tout delai non accessibles par N1 et GS au pire des cas
                for i=1:numNodes
                    for j=1:numSats
                        if matrix(i,j)>dGS_max+connectivity_duration || matrix(i,j) +connectivity_duration<d1_min
                            matrix(i,j)=inf;
                        end
                    end
                end

                % % R4
                % indices_queue = find(matrix(end, :) ~= inf);
                % 
                % visited = zeros(numNodes,numSats);
                % 
                % queue1 = find(matrix(end, :) ~= inf);
                % 
                % for j=1:numSats
                %     visited(1,j)=1;
                %     visited(end,j)=1;
                % end
                % 
                % queue2 = []; % Initialiser queue2
                % 
                % % Étape 2: Parcours des éléments de queue1, Parcours vertical
                % for idx = queue1
                %     dGS = matrix(end, idx);
                %     for i = 2:numNodes
                %         visited(i, idx) = 1;
                %         if matrix(i, idx) > dGS + connectivity_duration
                %             matrix(i, idx) = inf;
                %         else
                %             queue2 = [queue2; [i, idx]]; % Ajouter les indices en tant que nouvelle ligne
                %         end
                %     end
                % end
                % 
                % matrix_unchanged = @(old_matrix, new_matrix) isequal(old_matrix, new_matrix);
                % 
                % % Boucle principale
                % while true
                %     % Sauvegarder la matrice actuelle pour comparer plus tard
                %     matrix_old = matrix;
                % 
                %     % Étape 2: Traitement des lignes en utilisant queue2 , Parcours horizental
                %     queue3 = []; % Initialiser queue3
                %     for k = 1:size(queue2, 1)
                %         start_line = queue2(k, 1);
                %         start_column = queue2(k, 2);
                %         d1 = matrix(start_line, start_column);
                %         if d1 ~= inf
                %             for j = 1:numSats
                %                 if j ~= start_column && visited(start_line, j) == 0
                %                     visited(start_line, j) = 1;
                %                     if matrix(start_line, j) > d1 + connectivity_duration
                %                         matrix(start_line, j) = inf;
                %                     else
                %                         queue3 = [queue3; [start_line, j]]; % Ajouter les indices en tant que nouvelle ligne
                %                     end
                %                 end
                %             end
                %         end
                %     end
                % 
                %     % Étape 3: Traitement des colonnes en utilisant queue3 % Parcours vertical
                %     queue2 = []; % Réinitialiser queue2
                %     for k = 1:size(queue3, 1)
                %         start_line = queue3(k, 1);
                %         start_column = queue3(k, 2);
                %         d2 = matrix(start_line, start_column);
                %         if d2 ~= inf
                %             for i = 2:numNodes
                %                 if i~=end_node && i ~= start_line && visited(i, start_column) == 0
                %                     visited(i, start_column) = 1;
                %                     if matrix(i, start_column) > d2 + connectivity_duration
                %                         matrix(i, start_column) = inf;
                %                     else
                %                         queue2 = [queue2; [i, start_column]]; % Ajouter les indices en tant que nouvelle ligne
                %                     end
                %                 end
                %             end
                %         end
                %     end
                % 
                %     % Condition d'arrêt: Vérifier si la matrice a changé
                %     if matrix_unchanged(matrix_old, matrix)
                %         break;
                %     end
                % end

                
                % R5
                % Check rows
                for i = 2:numNodes
                    % Check how many elements are not inf in the row
                    non_inf_elements = ~isinf(matrix(i, :));

                    % If only one element is not inf, set it to inf
                    if sum(non_inf_elements) == 1
                        matrix(i, non_inf_elements) = inf;
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

                % % R6
                % valid_starting_sats = find(matrix(1, :) ~= inf);
                % 
                % if length(valid_starting_sats) > 1
                %     % Parcourir les lignes de la matrice
                %     for i = 2:numNodes
                %         if i~=end_node && all(matrix(i, valid_starting_sats) == inf)
                %             matrix(i, :) = inf;
                %         end
                %     end
                % end
                % 
        
                [R_path, R_delay] = best_path(matrix, 1, end_node, connectivity_duration, orbital_period);

            if R_delay == inf
                delay = dNR;
            end
            
            if delay==R_delay  || (length(path)>length(R_path) && R_delay<=delay)
                accuracy = accuracy+1;
            end
           end
        time_R_dijkstra = toc;
        total_time_R_Dijkstra = total_time_R_Dijkstra + time_R_dijkstra;
        end
        
        % Calculate averages
        avg_time_R_Dijkstra = total_time_R_Dijkstra / num_iterations;
        avg_time_Dijkstra = total_time_Dijkstra / num_iterations;
    
        [~, cols1] = size(nodes_array);
        [~, cols2] = size(sats_array);

        % Store results
        newRow = table(cols1, cols2, avg_time_Dijkstra, avg_time_R_Dijkstra, accuracy,...
                       'VariableNames', {'Number_of_Nodes', 'Number_of_Sats', 'Dijkstra_CPU_time', 'R_Dijkstra_CPU_time', ...
                                         'Algorithm_Accuracy'});
        results = [results; newRow];
    end
end

write_to = 'R1_R2_R3_R5_Dijkstra_results.csv';
% Write the results table to a CSV file
writetable(results, write_to);
disp('Simulation complete. Results written to output file');


% Initialize results storage
results = [];
for numNodes = 10:6:22
    for numSats = 6:2:24  
        % Run the Monte Carlo simulation for each case
        total_time_BF = 0;
        total_time_R_Dijkstra = 0;
        total_time_Dijkstra = 0;

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

            tic
            [path, delay] = best_path(matrix, 1, end_node, connectivity_duration, orbital_period);
            time_dijkstra = toc;
            total_time_Dijkstra = total_time_Dijkstra + time_dijkstra;

            tic;
            [~,sat_NR]=min(matrix(1,:));
            dNR = calculate_delay(matrix(1,sat_NR),matrix(end_node,sat_NR),connectivity_duration,orbital_period);
            
            % R1: Eliminer tout delai superieur ou egal a dNR
            for i=1:numSats
                for j=1:numSats
                    if matrix(i,j)>=dNR
                        matrix(i,j)=inf;
                    end
                end
            end
        
        
           if all(isinf(matrix(1, :))) || all(isinf(matrix(end, :)))
                accuracy = accuracy + 1;
           else
               [~,max_GS]=max(matrix(end_node,:));
               dGS_max = matrix(end_node,max_GS);
                [~,min_1]=min(matrix(1,:));
                d1_min = matrix(1,min_1);


                % R2+R3: Eliminer tout delai non accessibles par N1 et GS au pire des cas
                for i=1:numNodes
                    for j=1:numSats
                        if matrix(i,j)>dGS_max+connectivity_duration || matrix(i,j) +connectivity_duration<d1_min
                            matrix(i,j)=inf;
                        end
                    end
                end

                % % R4
                % indices_queue = find(matrix(end, :) ~= inf);
                % 
                % visited = zeros(numNodes,numSats);
                % 
                % queue1 = find(matrix(end, :) ~= inf);
                % 
                % for j=1:numSats
                %     visited(1,j)=1;
                %     visited(end,j)=1;
                % end
                % 
                % queue2 = []; % Initialiser queue2
                % 
                % % Étape 2: Parcours des éléments de queue1, Parcours vertical
                % for idx = queue1
                %     dGS = matrix(end, idx);
                %     for i = 2:numNodes
                %         visited(i, idx) = 1;
                %         if matrix(i, idx) > dGS + connectivity_duration
                %             matrix(i, idx) = inf;
                %         else
                %             queue2 = [queue2; [i, idx]]; % Ajouter les indices en tant que nouvelle ligne
                %         end
                %     end
                % end
                % 
                % matrix_unchanged = @(old_matrix, new_matrix) isequal(old_matrix, new_matrix);
                % 
                % % Boucle principale
                % while true
                %     % Sauvegarder la matrice actuelle pour comparer plus tard
                %     matrix_old = matrix;
                % 
                %     % Étape 2: Traitement des lignes en utilisant queue2 , Parcours horizental
                %     queue3 = []; % Initialiser queue3
                %     for k = 1:size(queue2, 1)
                %         start_line = queue2(k, 1);
                %         start_column = queue2(k, 2);
                %         d1 = matrix(start_line, start_column);
                %         if d1 ~= inf
                %             for j = 1:numSats
                %                 if j ~= start_column && visited(start_line, j) == 0
                %                     visited(start_line, j) = 1;
                %                     if matrix(start_line, j) > d1 + connectivity_duration
                %                         matrix(start_line, j) = inf;
                %                     else
                %                         queue3 = [queue3; [start_line, j]]; % Ajouter les indices en tant que nouvelle ligne
                %                     end
                %                 end
                %             end
                %         end
                %     end
                % 
                %     % Étape 3: Traitement des colonnes en utilisant queue3 % Parcours vertical
                %     queue2 = []; % Réinitialiser queue2
                %     for k = 1:size(queue3, 1)
                %         start_line = queue3(k, 1);
                %         start_column = queue3(k, 2);
                %         d2 = matrix(start_line, start_column);
                %         if d2 ~= inf
                %             for i = 2:numNodes
                %                 if i~=end_node && i ~= start_line && visited(i, start_column) == 0
                %                     visited(i, start_column) = 1;
                %                     if matrix(i, start_column) > d2 + connectivity_duration
                %                         matrix(i, start_column) = inf;
                %                     else
                %                         queue2 = [queue2; [i, start_column]]; % Ajouter les indices en tant que nouvelle ligne
                %                     end
                %                 end
                %             end
                %         end
                %     end
                % 
                %     % Condition d'arrêt: Vérifier si la matrice a changé
                %     if matrix_unchanged(matrix_old, matrix)
                %         break;
                %     end
                % end

                
                % % R5
                % % Check rows
                % for i = 2:numNodes
                %     % Check how many elements are not inf in the row
                %     non_inf_elements = ~isinf(matrix(i, :));
                % 
                %     % If only one element is not inf, set it to inf
                %     if sum(non_inf_elements) == 1
                %         matrix(i, non_inf_elements) = inf;
                %     end
                % end
                % 
                % % Check columns
                % for j = 1:numSats
                %     % Check how many elements are not inf in the column
                %     non_inf_elements = ~isinf(matrix(:, j));
                % 
                %     % If only one element is not inf, set it to inf
                %     if sum(non_inf_elements) == 1
                %         matrix(non_inf_elements, j) = inf;
                %     end
                % end

                % % R6
                % valid_starting_sats = find(matrix(1, :) ~= inf);
                % 
                % if length(valid_starting_sats) > 1
                %     % Parcourir les lignes de la matrice
                %     for i = 2:numNodes
                %         if i~=end_node && all(matrix(i, valid_starting_sats) == inf)
                %             matrix(i, :) = inf;
                %         end
                %     end
                % end
                % 
        
                               [R_path, R_delay] = best_path(matrix, 1, end_node, connectivity_duration, orbital_period);

            if R_delay == inf
                delay = dNR;
            end
            
            if delay==R_delay  || (length(path)>length(R_path) && R_delay<=delay)
                accuracy = accuracy+1;
            end
           end
        time_R_dijkstra = toc;
        total_time_R_Dijkstra = total_time_R_Dijkstra + time_R_dijkstra;
        end
        
        % Calculate averages
        avg_time_R_Dijkstra = total_time_R_Dijkstra / num_iterations;
        avg_time_Dijkstra = total_time_Dijkstra / num_iterations;
    
        [~, cols1] = size(nodes_array);
        [~, cols2] = size(sats_array);

        % Store results
        newRow = table(cols1, cols2, avg_time_Dijkstra, avg_time_R_Dijkstra, accuracy,...
                       'VariableNames', {'Number_of_Nodes', 'Number_of_Sats', 'Dijkstra_CPU_time', 'R_Dijkstra_CPU_time', ...
                                         'Algorithm_Accuracy'});
        results = [results; newRow];
    end
end

write_to = 'R1_R2_R3_Dijkstra_results.csv';
% Write the results table to a CSV file
writetable(results, write_to);
disp('Simulation complete. Results written to output file');

% Initialize results storage
results = [];


for numNodes = 10:6:22
    for numSats = 6:2:24  
        % Run the Monte Carlo simulation for each case
        total_time_BF = 0;
        total_time_R_Dijkstra = 0;
        total_time_Dijkstra = 0;

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

            tic
            [path, delay] = best_path(matrix, 1, end_node, connectivity_duration, orbital_period);
            time_dijkstra = toc;
            total_time_Dijkstra = total_time_Dijkstra + time_dijkstra;

            tic;
            [~,sat_NR]=min(matrix(1,:));
            dNR = calculate_delay(matrix(1,sat_NR),matrix(end_node,sat_NR),connectivity_duration,orbital_period);
            
            % R1: Eliminer tout delai superieur ou egal a dNR
            for i=1:numSats
                for j=1:numSats
                    if matrix(i,j)>=dNR
                        matrix(i,j)=inf;
                    end
                end
            end
        
        
           if all(isinf(matrix(1, :))) || all(isinf(matrix(end, :)))
                accuracy = accuracy + 1;
           else
               [~,max_GS]=max(matrix(end_node,:));
               dGS_max = matrix(end_node,max_GS);
                [~,min_1]=min(matrix(1,:));
                d1_min = matrix(1,min_1);


                % % R2+R3: Eliminer tout delai non accessibles par N1 et GS au pire des cas
                % for i=1:numNodes
                %     for j=1:numSats
                %         if matrix(i,j)>dGS_max+connectivity_duration || matrix(i,j) +connectivity_duration<d1_min
                %             matrix(i,j)=inf;
                %         end
                %     end
                % end

                % % R4
                % indices_queue = find(matrix(end, :) ~= inf);
                % 
                % visited = zeros(numNodes,numSats);
                % 
                % queue1 = find(matrix(end, :) ~= inf);
                % 
                % for j=1:numSats
                %     visited(1,j)=1;
                %     visited(end,j)=1;
                % end
                % 
                % queue2 = []; % Initialiser queue2
                % 
                % % Étape 2: Parcours des éléments de queue1, Parcours vertical
                % for idx = queue1
                %     dGS = matrix(end, idx);
                %     for i = 2:numNodes
                %         visited(i, idx) = 1;
                %         if matrix(i, idx) > dGS + connectivity_duration
                %             matrix(i, idx) = inf;
                %         else
                %             queue2 = [queue2; [i, idx]]; % Ajouter les indices en tant que nouvelle ligne
                %         end
                %     end
                % end
                % 
                % matrix_unchanged = @(old_matrix, new_matrix) isequal(old_matrix, new_matrix);
                % 
                % % Boucle principale
                % while true
                %     % Sauvegarder la matrice actuelle pour comparer plus tard
                %     matrix_old = matrix;
                % 
                %     % Étape 2: Traitement des lignes en utilisant queue2 , Parcours horizental
                %     queue3 = []; % Initialiser queue3
                %     for k = 1:size(queue2, 1)
                %         start_line = queue2(k, 1);
                %         start_column = queue2(k, 2);
                %         d1 = matrix(start_line, start_column);
                %         if d1 ~= inf
                %             for j = 1:numSats
                %                 if j ~= start_column && visited(start_line, j) == 0
                %                     visited(start_line, j) = 1;
                %                     if matrix(start_line, j) > d1 + connectivity_duration
                %                         matrix(start_line, j) = inf;
                %                     else
                %                         queue3 = [queue3; [start_line, j]]; % Ajouter les indices en tant que nouvelle ligne
                %                     end
                %                 end
                %             end
                %         end
                %     end
                % 
                %     % Étape 3: Traitement des colonnes en utilisant queue3 % Parcours vertical
                %     queue2 = []; % Réinitialiser queue2
                %     for k = 1:size(queue3, 1)
                %         start_line = queue3(k, 1);
                %         start_column = queue3(k, 2);
                %         d2 = matrix(start_line, start_column);
                %         if d2 ~= inf
                %             for i = 2:numNodes
                %                 if i~=end_node && i ~= start_line && visited(i, start_column) == 0
                %                     visited(i, start_column) = 1;
                %                     if matrix(i, start_column) > d2 + connectivity_duration
                %                         matrix(i, start_column) = inf;
                %                     else
                %                         queue2 = [queue2; [i, start_column]]; % Ajouter les indices en tant que nouvelle ligne
                %                     end
                %                 end
                %             end
                %         end
                %     end
                % 
                %     % Condition d'arrêt: Vérifier si la matrice a changé
                %     if matrix_unchanged(matrix_old, matrix)
                %         break;
                %     end
                % end

                
                % R5
                % Check rows
                % for i = 2:numNodes
                %     % Check how many elements are not inf in the row
                %     non_inf_elements = ~isinf(matrix(i, :));
                % 
                %     % If only one element is not inf, set it to inf
                %     if sum(non_inf_elements) == 1
                %         matrix(i, non_inf_elements) = inf;
                %     end
                % end
                % 
                % % Check columns
                % for j = 1:numSats
                %     % Check how many elements are not inf in the column
                %     non_inf_elements = ~isinf(matrix(:, j));
                % 
                %     % If only one element is not inf, set it to inf
                %     if sum(non_inf_elements) == 1
                %         matrix(non_inf_elements, j) = inf;
                %     end
                % end

                % % R6
                % valid_starting_sats = find(matrix(1, :) ~= inf);
                % 
                % if length(valid_starting_sats) > 1
                %     % Parcourir les lignes de la matrice
                %     for i = 2:numNodes
                %         if i~=end_node && all(matrix(i, valid_starting_sats) == inf)
                %             matrix(i, :) = inf;
                %         end
                %     end
                % end
                % 
        
                [R_path, R_delay] = best_path(matrix, 1, end_node, connectivity_duration, orbital_period);

            if R_delay == inf
                delay = dNR;
            end
            
            if delay==R_delay  || (length(path)>length(R_path) && R_delay<=delay)
                accuracy = accuracy+1;
            end
           end
        time_R_dijkstra = toc;
        total_time_R_Dijkstra = total_time_R_Dijkstra + time_R_dijkstra;
        end
        
        % Calculate averages
        avg_time_R_Dijkstra = total_time_R_Dijkstra / num_iterations;
        avg_time_Dijkstra = total_time_Dijkstra / num_iterations;
    
        [~, cols1] = size(nodes_array);
        [~, cols2] = size(sats_array);

        % Store results
        newRow = table(cols1, cols2, avg_time_Dijkstra, avg_time_R_Dijkstra, accuracy,...
                       'VariableNames', {'Number_of_Nodes', 'Number_of_Sats', 'Dijkstra_CPU_time', 'R_Dijkstra_CPU_time', ...
                                         'Algorithm_Accuracy'});
        results = [results; newRow];
    end
end

write_to = 'R1_Dijkstra_results.csv';
% Write the results table to a CSV file
writetable(results, write_to);
disp('Simulation complete. Results written to output file');

function [path, delay] = best_path(matrix,start_node, end_node, duration, period)
    delay = inf;
    path = [];
    first = true;
    [~, cols] = size(matrix);
    for i=1:cols
        for j=1:cols
            if matrix(start_node,i)~=inf && matrix(end_node,j)~=inf
                [tmp_path, tmp_delay] = dijkstra(matrix, [start_node,i], [end_node,j], 'v',duration, period);
                if first || (tmp_delay <= delay )
                    delay = tmp_delay;
                    path = tmp_path;
                    first = false;
                end
            end
        end
    end
end

function [path, delay] = dijkstra(matrix, start, goal, dir,duration, period)
    [rows, cols] = size(matrix);
    delays = inf(rows, cols);
    delays(start(1), start(2)) = matrix(start(1), start(2));
    priority_queue = [matrix(start(1), start(2)), start];
    came_from = cell(rows, cols);

    while ~isempty(priority_queue)
        tmp_priority_queue = [];
        for idx = 1:length(priority_queue(:, 1))
            current_delay = priority_queue(idx, 1);
            current = priority_queue(idx, 2:3);

            neighbors = get_neighbors(matrix, current, rows, cols, dir);
            for k = 1:size(neighbors, 1)
                neighbor = neighbors(k, :);
                delay = calculate_delay(current_delay,matrix(neighbor(1), neighbor(2)),duration,period);
                if delay < delays(neighbor(1), neighbor(2))
                    delays(neighbor(1), neighbor(2)) = delay;
                    tmp_priority_queue = [tmp_priority_queue; delay, neighbor];
                    came_from{neighbor(1), neighbor(2)} = current;
                end
            end
        end
        priority_queue = tmp_priority_queue;

        if strcmp(dir, 'v')
            dir = 'h';
        else
            dir = 'v';
        end
    end
 
    path = reconstruct_path(came_from, start, goal);
    delay = delays(goal(1), goal(2));
end

function neighbors = get_neighbors(matrix, position, rows, cols, dir)
    neighbors = [];
    if strcmp(dir, 'v')
        for i = 1:rows
            if matrix(i, position(2)) ~= inf
                neighbor = [i, position(2)];
                if is_valid(neighbor, rows, cols)
                    neighbors = [neighbors; neighbor];
                end
            end
        end
    else
        for i = 1:cols
            if matrix(position(1), i) ~= inf
                neighbor = [position(1), i];
                if is_valid(neighbor, rows, cols)
                    neighbors = [neighbors; neighbor];
                end
            end
        end
    end
end

function valid = is_valid(position, rows, cols)
    valid = position(1) >= 1 && position(1) <= rows && position(2) >= 1 && position(2) <= cols;
end

function path = reconstruct_path(came_from, start, goal)
    path = [];
    current = goal;
    while ~isequal(current, start)
        if isempty(came_from{current(1), current(2)})
            path = [];
            return;
        end
        path = [current; path];
        current = came_from{current(1), current(2)};
    end
    path = [start; path];
end



% Function for Bruteforce routing
function [opt_path, min_delay] = bruteforce_routing(matrix, nodes_array, sats_array, end_node, connectivity_duration, orbital_period)
    min_delay = inf;
    opt_path = [];
    for i = sats_array
        if matrix(1,i)~=inf
            delay1 = matrix(1,i);
        else
            continue;
        end
        
        for j = nodes_array
            if matrix(j,i)~=inf 
                delay2  = calculate_delay(delay1, matrix(j,i), connectivity_duration, orbital_period);
               
                if j == end_node
                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j)];
                    min_delay  = delay2;
                    continue;
                end
                
            else
                continue;
            end
    
            for k = sats_array 
                if matrix(j,k)~=inf && k~=i
                    delay3 = calculate_delay(delay2, matrix(j,k), connectivity_duration, orbital_period);
                else
                    continue;
                end
    
                
                for l = nodes_array
                    if matrix(l,k)~=inf && l~=j
                        delay4 = calculate_delay(delay3, matrix(l,k), connectivity_duration, orbital_period);
                        if l == end_node
                            opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l)];
                            min_delay  = delay4;
                            continue;
                        end
                        
                    else
                        continue;
                    end
    
    
                    for m = sats_array
                        if matrix(l,m)~=inf && k~=i && m~=i && k~=m
                            delay5 = calculate_delay(delay4, matrix(l,m), connectivity_duration, orbital_period);
                        else
                            continue;
                        end
                        
                        for n = nodes_array
                            if matrix(n,m)~=inf && l~=j && l~=n && j~=n
                                delay6 = calculate_delay(delay5, matrix(n,m), connectivity_duration, orbital_period);
                                if n == end_node 
                                    opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n)];
                                    min_delay  = delay6;
                                    continue;
                                end  
                            else
                                continue;
                            end

                            for o = sats_array
                                if matrix(n,o)~=inf && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o
                                    delay7 = calculate_delay(delay6, matrix(n,o), connectivity_duration, orbital_period);
                                else
                                    continue;
                                end


                                for p = nodes_array
                                    if matrix(p,o)~=inf && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p
                                        delay8 = calculate_delay(delay7, matrix(p,o), connectivity_duration, orbital_period);
                                          if p == end_node
                                          opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p)];
                                          min_delay  = delay8;
                                          continue;
                                        end
                            % 
                            %         else
                            %             continue;
                            %         end
                            % 
                            %         for q = sats_array
                            %             if matrix(p,q)~=inf && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o
                            %                 delay9 = calculate_delay(delay8, matrix(p,q), connectivity_duration, orbital_period);
                            %                 if delay9 > min_delay
                            %                     continue;
                            %                 end
                            %             else
                            %                 continue;
                            %             end
                            % 
                            % 
                            % 
                            %             for r = nodes_array
                            %                 if matrix(r,q)~=inf && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p
                            %                     total_delay = calculate_delay(delay9, matrix(r,q), connectivity_duration, orbital_period);
                            %                     delay10 = total_delay;
                            %                     if delay10 > min_delay
                            %                         continue;
                            %                     end
                            %                     if r == end_node && total_delay < min_delay
                            %                         opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r)];
                            %                         min_delay  = total_delay;
                            %                     end
                            %                 else
                            %                     continue;
                            %                 end
                            % 
                            % 
                            %                 for s = sats_array
                            %                     if matrix(r,s)~=inf && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s
                            %                         delay11 = calculate_delay(delay10, matrix(r,s), connectivity_duration, orbital_period);
                            %                         if delay11 > min_delay
                            %                             continue;
                            %                         end
                            %                     else
                            %                         continue;
                            %                     end
                            % 
                            %                     for t = nodes_array
                            %                         if matrix(t,s)~=inf && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t
                            %                             total_delay = calculate_delay(delay11, matrix(t,s), connectivity_duration, orbital_period);
                            %                             delay12 = total_delay;
                            %                             if delay12 > min_delay
                            %                                 continue;
                            %                             end
                            %                             if t == end_node && total_delay < min_delay
                            %                                 opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t)];
                            %                                 min_delay  = total_delay;
                            %                             end
                            %                         else
                            %                             continue;
                            %                         end
                            % 
                            %                         for u = sats_array
                            %                             if matrix(t,u)~=inf && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s && u~=i && u~=k && u~=m && u~=o && u~=q && u~=s
                            %                                 delay13 = calculate_delay(delay12, matrix(t,u)~=inf, connectivity_duration, orbital_period);
                            %                                 if delay13 > min_delay
                            %                                     continue;
                            %                                 end
                            %                             else
                            %                                 continue;
                            %                             end
                            % 
                            %                             for v = nodes_array
                            %                                 if matrix(v,u)~=inf && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t && v~=j && v~=l && v~=n && v~=p && v~=r && v~=t 
                            %                                     total_delay = calculate_delay(delay13, matrix(v,u), connectivity_duration, orbital_period);
                            %                                     delay14 = total_delay;
                            %                                     if delay14 > min_delay
                            %                                         continue;
                            %                                     end
                            %                                     if v == end_node && total_delay < min_delay
                            %                                         opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t), "S" + num2str(u), "N" + num2str(v)];
                            %                                         min_delay  = total_delay;
                            %                                     end
                            %                                 else
                            %                                     continue;
                            %                                 end
                            %                             end
                            %                         end
                            %                     end
                            %                 end
                            %             end
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



