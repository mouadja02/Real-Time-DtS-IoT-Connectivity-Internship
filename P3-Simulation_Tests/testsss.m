clc; clear all;

end_node = 5;
connectivity_duration = 420;
orbital_period = 1.59*3600;
num_iterations = 1;

filename = 'access_intervals6.csv'; % Access the current filename

results = table();

% Loop through the number of nodes and satellites
for numNodes = 12
    for numSats = 18
        % Charger les données depuis le fichier CSV
        data = readtable('access_intervals6.csv');
        
        % Définir l'ordre des satellites et des nœuds
        satellites = {'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'S10', 'S11', 'S12', 'S13', 'S14', 'S15', 'S16', 'S17', 'S18'};
        nodes = {'N1', 'N2', 'N3', 'N4', 'N5', 'N6', 'N7', 'N8', 'N9', 'N10', 'N11', 'N12', 'N13', 'N14', 'N15', 'N16', 'N17', 'N18', 'N19', 'N20'};

        % Initialiser la matrice avec des valeurs 'inf' par défaut
        matrix = inf(numNodes, numSats);

        % Remplir la matrice avec les temps de début de connexion
         
        for i = 1:height(data)
            node = data.Target{i};
            satellite = data.Source{i};
            startTime = data.StartTime(i);
            delay_str = sprintf('%s', datestr(startTime, 'HH:MM:SS'));

            % Trouver les indices correspondants

            nodeIdx = find(strcmp(nodes, node));
            satelliteIdx = find(strcmp(satellites, satellite));

           if nodeIdx>numNodes
               continue;
           end

           if satelliteIdx>numSats
               continue;
           end

            % Mettre à jour la matrice avec le premier temps de début de connexion
            if matrix(nodeIdx, satelliteIdx) == inf
                S = str2double(delay_str(1:2))*3600 + str2double(delay_str(4:5))*60 + str2double(delay_str(7:8));
                matrix(nodeIdx, satelliteIdx) = S;
            end
        end

        % Initialize accumulators for Monte Carlo
        total_time_bruteforce = 0;
        total_time_floydwarshall = 0;

        matrix = [inf inf inf 1150 650
            570 inf 3440 inf inf
            1890 1370 2410 1295 6970
            inf inf inf 795 565
            1695 1140 inf 1050 inf
            410 0 3765 0 inf
            ]
        numNodes = 6;
        numSats = 5;
        end_node = 2;

        for mc_iter = 1:num_iterations
            % Bruteforce Timing
            tic;
            min_delay = inf;
            
            % Loop through the first satellite
            for i = 1:numSats
          
                relevant_data = data(strcmp(data.Source, "S" + num2str(i)) & strcmp(data.Target, "N1"), :);
                if matrix(1,i)~=inf
                    delay1 = matrix(1,i);
                else
                    continue;
                end
                
                for j = 2:numNodes
                    if matrix(j,i)~=inf 
                        delay2  = calculate_delay(delay1, matrix(j,i), connectivity_duration, orbital_period);
                        if delay2 > min_delay
                            continue;
                        else 
                            if j == end_node
                                opt_path = ["N1", "S" + num2str(i), "N" + num2str(j)];
                                min_delay  = delay2;
                                continue;
                            end
                        end
                        
                    else
                        continue;
                    end
            
                    for k = 1:numSats 
                        if matrix(j,k)~=inf && k~=i
                            delay3 = calculate_delay(delay2, matrix(j,k), connectivity_duration, orbital_period);
                            if delay3 > min_delay
                                continue;
                            end
                        else
                            continue;
                        end
            
                        
                        for l = 2:numNodes
                            if matrix(l,k)~=inf && l~=j
                                delay4 = calculate_delay(delay3, matrix(l,k), connectivity_duration, orbital_period);
                                if delay4 > min_delay
                                    continue;
                                else
                                    if l == end_node
                                        opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l)];
                                        min_delay  = delay4;
                                        continue;
                                    end
                                end
                                
                            else
                                continue;
                            end
            
            
                            for m = 1:numSats
                                if matrix(l,m)~=inf && k~=i && m~=i && k~=m
                                    delay5 = calculate_delay(delay4, matrix(l,m), connectivity_duration, orbital_period);
                                    if delay5 > min_delay
                                        continue;
                                    end
                                else
                                    continue;
                                end
                                
                                for n = 2:numNodes
                                    if matrix(n,m)~=inf && l~=j && l~=n && j~=n
                                        delay6 = calculate_delay(delay5, matrix(n,m), connectivity_duration, orbital_period);
                                        if delay6 > min_delay
                                            continue;
                                        else 
                                            if n == end_node 
                                                opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n)];
                                                min_delay  = delay6;
                                                continue;
                                            end
                                        end
                                        
                                    else
                                        continue;
                                    end
            
                                    for o = 1:numSats
                                        if matrix(n,o)~=inf && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o
                                            delay7 = calculate_delay(delay6, matrix(n,o), connectivity_duration, orbital_period);
                                            if delay7 > min_delay
                                                continue;
                                            end
                                        else
                                            continue;
                                        end
            
                                        
                                        for p = 2:numNodes
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
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            opt_path
            min_delay  
            
            time_bruteforce = toc;
            total_time_bruteforce = total_time_bruteforce + time_bruteforce;
            % Floyd-Warshall Timing
            tic;
            %delay_fw = FloydWarshall(outputFilename, 1, end_node, numNodes);
            [delay_fw, path] = FloydWarshall(matrix, numNodes,numSats, 1, end_node, connectivity_duration, orbital_period)
            time_floydwarshall = toc;
            total_time_floydwarshall = total_time_floydwarshall + time_floydwarshall;
        end
        
        % Calculate the average processing time over the Monte Carlo iterations
        avg_time_bruteforce = total_time_bruteforce / num_iterations;
        avg_time_floydwarshall = total_time_floydwarshall / num_iterations;
        
        % Store the results in the table

        newRow = table(numNodes, numSats, min_delay, delay_fw, avg_time_bruteforce, avg_time_floydwarshall, ...
                       'VariableNames', {'Number_of_Nodes', 'Number_of_Sats', 'Bruteforce_Delay', 'FloydWarshall_Delay', ...
                                         'Avg_CPU_Time_Bruteforce', 'Avg_CPU_Time_FloydWarshall'});
        results = [results; newRow];
    end
end

% Write the results table to a CSV file
writetable(results, 'MonteCarloResults.csv');

disp('Results written to MonteCarloResults.csv');

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
                if delay2 > min_delay
                    continue;
                else 
                    if j == end_node
                        opt_path = ["N1", "S" + num2str(i), "N" + num2str(j)];
                        min_delay  = delay2;
                        continue;
                    end
                end
                
            else
                continue;
            end
    
            for k = sats_array 
                if matrix(j,k)~=inf && k~=i
                    delay3 = calculate_delay(delay2, matrix(j,k), connectivity_duration, orbital_period);
                    if delay3 > min_delay
                        continue;
                    end
                else
                    continue;
                end
    
                
                for l = nodes_array
                    if matrix(l,k)~=inf && l~=j
                        delay4 = calculate_delay(delay3, matrix(l,k), connectivity_duration, orbital_period);
                        if delay4 > min_delay
                            continue;
                        else
                            if l == end_node
                                opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l)];
                                min_delay  = delay4;
                                continue;
                            end
                        end
                        
                    else
                        continue;
                    end
    
    
                    for m = sats_array
                        if matrix(l,m)~=inf && k~=i && m~=i && k~=m
                            delay5 = calculate_delay(delay4, matrix(l,m), connectivity_duration, orbital_period);
                            if delay5 > min_delay
                                continue;
                            end
                        else
                            continue;
                        end
                        
                        for n = nodes_array
                            if matrix(n,m)~=inf && l~=j && l~=n && j~=n
                                delay6 = calculate_delay(delay5, matrix(n,m), connectivity_duration, orbital_period);
                                if delay6 > min_delay
                                    continue;
                                else 
                                    if n == end_node 
                                        opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n)];
                                        min_delay  = delay6;
                                        continue;
                                    end
                                end
                                
                            else
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

function [path, delay] = best_path(matrix,start_node, end_node, duration, period, nodes_array, sats_array)
    delay = inf;
    path = [];
    first = true;
    for i=sats_array
        for j=sats_array
            if matrix(start_node,i)~=inf && matrix(end_node,j)~=inf
                [tmp_path, tmp_delay] = dijkstra(matrix, [start_node,i], [end_node,j], 'v',duration, period, nodes_array, sats_array);
                if first || (tmp_delay <= delay )
                    delay = tmp_delay;
                    path = tmp_path;
                    first = false;
                end
            end
        end
    end
end

function [path, delay] = dijkstra(matrix, start, goal, dir,duration, period, nodes_array, sats_array)
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

            % if current == end_node
            %     break;
            % end

            neighbors = get_neighbors(matrix, current, rows, cols, dir, nodes_array, sats_array);
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

function neighbors = get_neighbors(matrix, position, rows, cols, dir, nodes_array, sats_array)
    neighbors = [];
    if strcmp(dir, 'v')
        for i = nodes_array
            if matrix(i, position(2)) ~= inf
                neighbor = [i, position(2)];
                if is_valid(neighbor, rows, cols)
                    neighbors = [neighbors; neighbor];
                end
            end
        end
    else
        for i = sats_array
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

function display_path(path)
    path_str = '';

    for i = 1:size(path, 1)
        node = path(i, :);
        if i == 1
            path_str = sprintf('N%d ---> S%d', node(1), node(2));
        else
            if i == size(path, 1)
                path_str = sprintf('%s ---> GS', path_str);
            else
                if mod(i, 2) == 0 % if even index
                    path_str = sprintf('%s ---> N%d', path_str, node(1));
                else % if odd index
                    path_str = sprintf('%s ---> S%d', path_str, node(2));
                end
            end
        end
    end

    disp(path_str);
end

function [path,min_delay] = dNR(matrix,start_node,end_node,connectivity_duration, orbital_period)
    numSat=length(matrix(1,:));
    numNodes= length(matrix(:,1));
    min_delay = inf;
    path = {'No Route'};
    for i=1:numSat
        if matrix(start_node,i)~=inf && matrix(end_node,i)~=inf
            delay = calculate_delay(matrix(start_node,i),matrix(end_node,i),connectivity_duration, orbital_period);
            if delay < min_delay
                path = {'N1', ['S' num2str(i)],'GS (NR)'};
                min_delay = delay;
            end
        end
    end
    % Display the NR path and delay
    disp('N1 to GS: ' );
    disp(['Delay of No Routing: ' num2str(min_delay)]);
    disp(['Best No Routing path : ' strjoin(path, ' -> ') ]);
    disp([' ' ]);
end

function [best_path,min_delay,str_matrix] = backward_research(matrix,start_node,end_node,connectivity_duration, orbital_period)
    numSat=length(matrix(1,:));
    numNodes= length(matrix(:,1));
    [NR_path,NR_delay] = dNR(matrix,start_node,end_node,connectivity_duration,orbital_period);
    NR_validity = true;
    indexes = [];
    dir = 'v';
    min_delay = inf;
    best_path = {'No Route'};
    for i=1:numSat
        if matrix(end_node,i)<NR_delay
            NR_validity = false;
            indexes = [indexes,[end_node;i]];
        else
            matrix(end_node,i) = inf;
        end
    end

    if NR_validity
        min_delay = NR_delay;
        best_path = NR_path;
        str_matrix = matrix;
    else
        str_matrix = simplify_matrix(matrix,indexes,dir,connectivity_duration,orbital_period,1);
    end

end

% Recursive simplification function
function str_matrix = simplify_matrix(matrix,indexes,dir,connectivity_duration,orbital_period,iter)
    numSat=length(matrix(1,:));
    numNodes= length(matrix(:,1));
    list_index = [];
    if isempty(indexes) || iter==numSat*numNodes
        str_matrix = matrix;
    else
        out_matrix = matrix;
        if dir == 'h'
            for x=indexes
                start = x(2,:);
                i = x(1,:);
                val = out_matrix(i,start);
                index = [];
                for j=1:numSat
                    if out_matrix(i,j)~=inf && j~=start && i~=j
                        if val+connectivity_duration-1<out_matrix(i,j)
                            out_matrix(i,j)=inf;
                        else
                            if ~ismember([i;j],list_index)
                                list_index = [list_index,[i;j]];
                            end
                        end
                    end
                end
            end
        else
            for x=indexes             
                start = x(1,:);
                i = x(2,:);
                val = out_matrix(start,i);
                index = [];
                for j=1:numNodes
                    if out_matrix(j,i)~=inf && j~=start && j~=i
                        if val+connectivity_duration-1<out_matrix(j,i)
                            out_matrix(j,i)=inf;
                        else
                            if ~ismember([j;i],index)
                                list_index= [list_index,[j;i]];
                            end
                        end
                    end
                end
            end
        end
        clear indexes;
        indexes = list_index;
        if dir == 'v'
            str_matrix = simplify_matrix(out_matrix,indexes,'h',connectivity_duration,orbital_period,iter+1);
        else
            str_matrix = simplify_matrix(out_matrix,indexes,'v',connectivity_duration,orbital_period,iter+1);
        end
    end
    
end

