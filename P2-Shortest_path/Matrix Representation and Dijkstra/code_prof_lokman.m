clear all
clc
% Number of nodes and satellites
T_orbit=100;
T_visible=10;
% Define the delays matrix
W = [
    -2    45    63    87    63    47
    81    59    48    83    15    15
    47    42    79    29     8    -5
     3     4    55    -7    -5     9
    40    27    16    56    34    29
    39    10     1    70    13    83
    33    -7    83    86    34    10
    30    12    -7    46    65    -5
    35    14    25    56    11    27
    53    28    57     5    53    88
    18    39    90    -2    68    -2
    23    23    87    49    -9    -3
     1    54    36    26    15    37
    67    83    -3    11    88    57
    37    54    79    -3    57     1
    ];
N_sats = 4;
N_nodes = 6;

% Best path : N1 -> S4 -> N6 -> S3 -> GS (4 Hops)
% Best path : N2 -> S4 -> GS (2 Hops)
% Best path : N3 -> S1 -> N6 -> S3 -> GS (4 Hops)
% Best path : N4 -> S3 -> GS (2 Hops)
% Best path : N5 -> S4 -> N3 -> S1 -> N6 -> S3 -> GS (6 Hops)
% Best path : N6 -> S3 -> GS (2 Hops)
W = randi([0, 100], N_nodes + 1, N_sats) - 10 % "+1" for the ground station

    
% Step 3: Find the best path from nodes to GS considering DNR
for i = 1:1%N_nodes
    tic
    hops=inf;
    bestPath = {};
    bestDelay = inf;
    for j = 1:N_sats
        % check if one stage is the best
        stage_delay = hop_delay(W(i,j),W(end,j));
        if stage_delay < bestDelay
            if ~(stage_delay  == bestDelay && hops > 2)
                bestDelay = stage_delay;
                bestPath = {['N' num2str(i)], ['S' num2str(j)],['GS (2 Hops)']};
                hops=2;
            end
        end
        for k = 1:N_nodes
            if  k ~= i
                hop2_delay = hop_delay(W(i,j),W(k,j));
                for l_= 1:N_sats
                    if  l_ ~= j
                        hop3_delay = hop_delay(hop2_delay,W(k,l_));
                        % check if two stages are the best
                        stage_delay = hop_delay(hop3_delay,W(end,l_));
                        if stage_delay < bestDelay
                            if ~(stage_delay  == bestDelay && hops > 4)
                                bestDelay = stage_delay;
                                bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)],  ['GS (4 Hops)']};
                                hops=4;
                            end
                        end
                        for m = 1:N_nodes+1
                            if  k ~= m
                                hop4_delay = hop_delay(hop3_delay,W(m,l_));
                                for n= 1:N_sats
                                    if  l_ ~= n
                                        hop5_delay = hop_delay(hop4_delay,W(m,n));
                                        % check if three stages are the best
                                        stage_delay =   hop_delay(hop5_delay,W(end,n));
                                        if stage_delay < bestDelay
                                            if ~(stage_delay  == bestDelay && hops > 6)
                                                bestDelay = stage_delay;
                                                bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)], ['N' num2str(m)], ['S' num2str(n)],  ['GS (6 Hops)']};
                                                hops=6;
                                            end
                                        end
                                        for o = 1:N_nodes+1
                                            if  k ~= m
                                                hop6_delay = hop_delay(hop5_delay,W(m,l_));
                                                for p= 1:N_sats
                                                    if  l_ ~= n
                                                        hop7_delay = hop_delay(hop6_delay,W(m,n));
                                                        % check if four stages are the best
                                                        stage_delay =   hop_delay(hop7_delay,W(end,n));
                                                        if stage_delay < bestDelay
                                                            if ~(stage_delay  == bestDelay && hops > 8)
                                                                bestDelay = stage_delay;
                                                                bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)], ['N' num2str(m)], ['S' num2str(n)],    ['N' num2str(o)], ['S' num2str(p)], ['GS (8 Hops)']};
                                                                hops=8;
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
    
    % Choose the path with the minimum total delay
    
    
    % Display the best path and delay
    disp(['N' num2str(i) ' to GS: ' ]);
    [~,sat_NR]=min(W(i,:));
    dNR = hop_delay(W(i,sat_NR),W(end,sat_NR));
    disp(['Delay of No Routing: ' num2str(dNR)]);
    disp(['Best path : ' strjoin(bestPath, ' -> ') ]);
    disp(['Best path delay: ' num2str(bestDelay)   ]);
    toc
    disp([' ' ]);
    
    
end


for i=1:N_nodes+1
    for j=1:N_sats
        if W(i,j)>=dNR
            W(i,j)=inf;
        end
    end
end
W


%%

clear all
clc
% Number of nodes and satellites
T_orbit=100;
T_visible=10;

matrix = [6 74 46 22
    66 50 64 56
    77 23 32 86
    25 20 33 84
    59 35 2 36
    19 32 -8 14
    43 26 19 67];

N_sats = 4;
N_nodes = 6;

mc_iter = 1000;
CPU_processing_time = 0;

disp(['N' num2str(1) ' to GS: ' ]);
[~,sat_NR]=min(matrix(1,:));
dNR = hop_delay(matrix(1,sat_NR),matrix(end,sat_NR));

for iter=1:mc_iter    
    matrix = randi([0, 100], N_nodes + 1, N_sats) - 10; % "+1" for the ground station
    

    % Step 3: Find the best path from nodes to GS considering DNR
    tic;
    for i = 1:1%N_nodes
        hops=inf;
        bestPath = {};
        bestDelay = inf;
        for j = 1:N_sats
            % check if one stage is the best
            if matrix(i,j)~= inf
                stage_delay = hop_delay(matrix(i,j),matrix(end,j));
                if stage_delay < bestDelay
                    if ~(stage_delay  == bestDelay && hops > 2)
                        bestDelay = stage_delay;
                        bestPath = {['N' num2str(i)], ['S' num2str(j)],['GS (2 Hops)']};
                        hops=2;
                    end
                end
                for k = 1:N_nodes
                    if  k ~= i && matrix(i,j) ~= inf && matrix(k,j)~=inf
                        hop2_delay = hop_delay(matrix(i,j),matrix(k,j));
                        for l_= 1:N_sats
                            if  l_ ~= j && matrix(k,l_)~=inf
                                hop3_delay = hop_delay(hop2_delay,matrix(k,l_));
                                % check if two stages are the best
                                stage_delay = hop_delay(hop3_delay,matrix(end,l_));
                                if stage_delay < bestDelay
                                    if ~(stage_delay  == bestDelay && hops > 4)
                                        bestDelay = stage_delay;
                                        bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)],  ['GS (4 Hops)']};
                                        hops=4;
                                    end
                                end
                                for m = 1:N_nodes+1
                                    if  k ~= m && matrix(m,l_)~=inf
                                        hop4_delay = hop_delay(hop3_delay,matrix(m,l_));
                                        for n= 1:N_sats
                                            if  l_ ~= n &&  matrix(m,n)~=inf
                                                hop5_delay = hop_delay(hop4_delay,matrix(m,n));
                                                % check if three stages are the best
                                                stage_delay =   hop_delay(hop5_delay,matrix(end,n));
                                                if stage_delay < bestDelay
                                                    if ~(stage_delay  == bestDelay && hops > 6)
                                                        bestDelay = stage_delay;
                                                        bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)], ['N' num2str(m)], ['S' num2str(n)],  ['GS (6 Hops)']};
                                                        hops=6;
                                                    end
                                                end
                                                for o = 1:N_nodes+1
                                                    if  k ~= m && matrix(m,l_)~=inf
                                                        hop6_delay = hop_delay(hop5_delay,matrix(m,l_));
                                                        for p= 1:N_sats
                                                            if  l_ ~= n && matrix(m,n)~=inf
                                                                hop7_delay = hop_delay(hop6_delay,matrix(m,n));
                                                                % check if four stages are the best
                                                                stage_delay =   hop_delay(hop7_delay,matrix(end,n));
                                                                if stage_delay < bestDelay
                                                                    if ~(stage_delay  == bestDelay && hops > 8)
                                                                        bestDelay = stage_delay;
                                                                        bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)], ['N' num2str(m)], ['S' num2str(n)],    ['N' num2str(o)], ['S' num2str(p)], ['GS (8 Hops)']};
                                                                        hops=8;
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
    CPU_processing_time = CPU_processing_time + toc;
end
    
    % Choose the path matrixith the minimum total delay
    
    
% Display the best path and delay
disp(['Delay of No Routing: ' num2str(dNR)]);
disp(['Best path : ' strjoin(bestPath, ' -> ') ]);
disp(['Best path delay: ' num2str(bestDelay)   ]);
disp(['Processing time: ' num2str(CPU_processing_time/mc_iter)]);

disp([' ' ]);


%%
clear all
clc
% Number of nodes and satellites
T_orbit=100;
T_visible=10;

matrix = [6 74 46 22
    66 50 64 56
    77 23 32 86
    25 20 33 84
    59 35 2 36
    19 32 -8 14
    43 26 19 67];

N_sats = 10;
N_nodes = 17;

mc_iter = 1;
CPU_processing_time_1 = 0;
CPU_processing_time_2 = 0;

disp(['N' num2str(1) ' to GS: ' ]);

for iter=1:mc_iter    
    matrix = randi([0, 100], N_nodes + 1, N_sats) - 10; % "+1" for the ground station
    [~,sat_NR]=min(matrix(1,:));
    dNR = hop_delay(matrix(1,sat_NR),matrix(end,sat_NR));
    
    % matrix = [70 21 70 -2 28 5 75 12 49 42
    %     13 inf inf inf -2 inf inf inf 7 inf
    %     inf -1 3 inf inf inf inf inf inf inf
    %     inf inf inf inf inf inf inf inf inf inf
    %     inf inf inf inf inf inf inf inf inf inf
    %     inf inf inf inf inf inf inf inf inf inf
    %     inf 0 inf inf inf inf 15 inf inf inf
    %     inf inf inf 9 7 inf inf 3 inf inf
    %     18 18 11 2 3 4 inf inf -4 inf
    %     inf 5 inf inf inf inf 15 inf 8 inf
    %     inf -10 inf inf -6 -2 inf inf inf -10
    %     inf inf inf -9 inf inf inf inf inf -10
    %     inf inf inf inf inf -7 inf inf inf -2
    %     inf inf inf inf inf inf inf inf inf inf
    %     1 -6 -7 inf inf inf inf inf inf -8
    %     20 inf 19 inf inf 11 inf inf inf inf
    %     30 3 inf inf 30 inf inf inf inf inf
    %     32 inf 24 inf inf inf 12 -5 inf inf];
    


    matrix


    % Step 0: Benchmark
    tic;
    for i = 1:1%N_nodes
        hops=inf;
        bestPath = {};
        bestDelay = inf;
        for j = 1:N_sats
            % check if one stage is the best
            if matrix(i,j)~= inf
                stage_delay = hop_delay(matrix(i,j),matrix(end,j));
                if stage_delay < bestDelay
                    if ~(stage_delay  == bestDelay && hops > 2)
                        bestDelay = stage_delay;
                        bestPath = {['N' num2str(i)], ['S' num2str(j)],['GS (2 Hops)']};
                        hops=2;
                    end
                end
                for k = 1:N_nodes
                    if  k ~= i && matrix(i,j) ~= inf && matrix(k,j)~=inf
                        hop2_delay = hop_delay(matrix(i,j),matrix(k,j));
                        for l_= 1:N_sats
                            if  l_ ~= j && matrix(k,l_)~=inf
                                hop3_delay = hop_delay(hop2_delay,matrix(k,l_));
                                % check if two stages are the best
                                stage_delay = hop_delay(hop3_delay,matrix(end,l_));
                                if stage_delay < bestDelay
                                    if ~(stage_delay  == bestDelay && hops > 4)
                                        bestDelay = stage_delay;
                                        bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)],  ['GS (4 Hops)']};
                                        hops=4;
                                    end
                                end
                                for m = 1:N_nodes+1
                                    if  k ~= m && matrix(m,l_)~=inf
                                        hop4_delay = hop_delay(hop3_delay,matrix(m,l_));
                                        for n= 1:N_sats
                                            if  l_ ~= n &&  matrix(m,n)~=inf
                                                hop5_delay = hop_delay(hop4_delay,matrix(m,n));
                                                % check if three stages are the best
                                                stage_delay =   hop_delay(hop5_delay,matrix(end,n));
                                                if stage_delay < bestDelay
                                                    if ~(stage_delay  == bestDelay && hops > 6)
                                                        bestDelay = stage_delay;
                                                        bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)], ['N' num2str(m)], ['S' num2str(n)],  ['GS (6 Hops)']};
                                                        hops=6;
                                                    end
                                                end
                                                for o = 1:N_nodes+1
                                                    if  k ~= m && matrix(m,l_)~=inf
                                                        hop6_delay = hop_delay(hop5_delay,matrix(m,l_));
                                                        for p= 1:N_sats
                                                            if  l_ ~= n && matrix(m,n)~=inf
                                                                hop7_delay = hop_delay(hop6_delay,matrix(m,n));
                                                                % check if four stages are the best
                                                                stage_delay =   hop_delay(hop7_delay,matrix(end,n));
                                                                if stage_delay < bestDelay
                                                                    if ~(stage_delay  == bestDelay && hops > 8)
                                                                        bestDelay = stage_delay;
                                                                        bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)], ['N' num2str(m)], ['S' num2str(n)],    ['N' num2str(o)], ['S' num2str(p)], ['GS (8 Hops)']};
                                                                        hops=8;
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
         
    CPU_processing_time_1 = CPU_processing_time_1 + toc;
    % Display the best path and delay
    disp(['Delay of No Routing: ' num2str(dNR)]);
    disp(['Best path : ' strjoin(bestPath, ' -> ') ]);
    disp(['Best path delay: ' num2str(bestDelay)   ]);    
    disp([' ' ]);


    tic;
    % Etape 1: Eliminer tout delai superieur ou egal a dNR
    for i=1:N_nodes+1
        for j=1:N_sats
            if matrix(i,j)>=dNR
                matrix(i,j)=inf;
            end
        end
    end

    indices_queue = find(matrix(end, :) ~= inf);

    visited = zeros(N_nodes+1,N_sats);

    queue1 = find(matrix(end, :) ~= inf);

    for j=1:N_sats
        visited(1,j)=1;
        visited(end,j)=1;
    end
    
    queue2 = []; % Initialiser queue2
    
    % Étape 2: Parcours des éléments de queue1, Parcours vertical
    for idx = queue1
        dGS = matrix(end, idx);
        for i = 2:N_nodes
            visited(i, idx) = 1;
            if matrix(i, idx) > dGS + T_visible
                matrix(i, idx) = inf;
            else
                queue2 = [queue2; [i, idx]]; % Ajouter les indices en tant que nouvelle ligne
            end
        end
    end
    
    matrix_unchanged = @(old_matrix, new_matrix) isequal(old_matrix, new_matrix);
        
    % Boucle principale
    while true
        % Sauvegarder la matrice actuelle pour comparer plus tard
        matrix_old = matrix;
        
        % Étape 2: Traitement des lignes en utilisant queue2 , Parcours horizental
        queue3 = []; % Initialiser queue3
        for k = 1:size(queue2, 1)
            start_line = queue2(k, 1);
            start_column = queue2(k, 2);
            d1 = matrix(start_line, start_column);
            if d1 ~= inf
                for j = 1:N_sats
                    if j ~= start_column && visited(start_line, j) == 0
                        visited(start_line, j) = 1;
                        if matrix(start_line, j) > d1 + T_visible
                            matrix(start_line, j) = inf;
                        else
                            queue3 = [queue3; [start_line, j]]; % Ajouter les indices en tant que nouvelle ligne
                        end
                    end
                end
            end
        end
    
        % Étape 3: Traitement des colonnes en utilisant queue3 % Parcours vertical
        queue2 = []; % Réinitialiser queue2
        for k = 1:size(queue3, 1)
            start_line = queue3(k, 1);
            start_column = queue3(k, 2);
            d2 = matrix(start_line, start_column);
            if d2 ~= inf
                for i = 2:N_nodes
                    if i ~= start_line && visited(i, start_column) == 0
                        visited(i, start_column) = 1;
                        if matrix(i, start_column) > d2 + T_visible
                            matrix(i, start_column) = inf;
                        else
                            queue2 = [queue2; [i, start_column]]; % Ajouter les indices en tant que nouvelle ligne
                        end
                    end
                end
            end
        end
        
        % Condition d'arrêt: Vérifier si la matrice a changé
        if matrix_unchanged(matrix_old, matrix)
            break;
        end
    end
        
    valid_starting_sats = find(matrix(1, :) ~= inf);
    
    if length(valid_starting_sats) > 1
        % Parcourir les lignes de la matrice
        for i = 2:N_nodes
            if all(matrix(i, valid_starting_sats) == inf)
                matrix(i, :) = inf;
            end
        end
    end

    % Step 3: Find the best path from nodes to GS considering DNR
    for i = 1:1%N_nodes
        hops=inf;
        bestPath = {};
        bestDelay = inf;
        for j = 1:N_sats
            % check if one stage is the best
            if matrix(i,j)~= inf
                stage_delay = hop_delay(matrix(i,j),matrix(end,j));
                if stage_delay < bestDelay
                    if ~(stage_delay  == bestDelay && hops > 2)
                        bestDelay = stage_delay;
                        bestPath = {['N' num2str(i)], ['S' num2str(j)],['GS (2 Hops)']};
                        hops=2;
                    end
                end
                for k = 1:N_nodes
                    if  k ~= i && matrix(i,j) ~= inf && matrix(k,j)~=inf
                        hop2_delay = hop_delay(matrix(i,j),matrix(k,j));
                        for l_= 1:N_sats
                            if  l_ ~= j && matrix(k,l_)~=inf
                                hop3_delay = hop_delay(hop2_delay,matrix(k,l_));
                                % check if two stages are the best
                                stage_delay = hop_delay(hop3_delay,matrix(end,l_));
                                if stage_delay < bestDelay
                                    if ~(stage_delay  == bestDelay && hops > 4)
                                        bestDelay = stage_delay;
                                        bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)],  ['GS (4 Hops)']};
                                        hops=4;
                                    end
                                end
                                for m = 1:N_nodes+1
                                    if  k ~= m && matrix(m,l_)~=inf
                                        hop4_delay = hop_delay(hop3_delay,matrix(m,l_));
                                        for n= 1:N_sats
                                            if  l_ ~= n &&  matrix(m,n)~=inf
                                                hop5_delay = hop_delay(hop4_delay,matrix(m,n));
                                                % check if three stages are the best
                                                stage_delay =   hop_delay(hop5_delay,matrix(end,n));
                                                if stage_delay < bestDelay
                                                    if ~(stage_delay  == bestDelay && hops > 6)
                                                        bestDelay = stage_delay;
                                                        bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)], ['N' num2str(m)], ['S' num2str(n)],  ['GS (6 Hops)']};
                                                        hops=6;
                                                    end
                                                end
                                                for o = 1:N_nodes+1
                                                    if  k ~= m && matrix(m,l_)~=inf
                                                        hop6_delay = hop_delay(hop5_delay,matrix(m,l_));
                                                        for p= 1:N_sats
                                                            if  l_ ~= n && matrix(m,n)~=inf
                                                                hop7_delay = hop_delay(hop6_delay,matrix(m,n));
                                                                % check if four stages are the best
                                                                stage_delay =   hop_delay(hop7_delay,matrix(end,n));
                                                                if stage_delay < bestDelay
                                                                    if ~(stage_delay  == bestDelay && hops > 8)
                                                                        bestDelay = stage_delay;
                                                                        bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)], ['N' num2str(m)], ['S' num2str(n)],    ['N' num2str(o)], ['S' num2str(p)], ['GS (8 Hops)']};
                                                                        hops=8;
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
    CPU_processing_time_2 = CPU_processing_time_2 + toc;
end
    
    % Choose the path matrixith the minimum total delay
    
    
% Display the best path and delay
disp(['Delay of No Routing: ' num2str(dNR)]);
disp(['Best path : ' strjoin(bestPath, ' -> ') ]);
disp(['Best path delay: ' num2str(bestDelay)   ]);
disp(['Processing time 1: ' num2str(CPU_processing_time_1/mc_iter)]);
disp(['Processing time 2: ' num2str(CPU_processing_time_2/mc_iter)]);

disp([' ' ]);

%%
clear all
clc
% Number of nodes and satellites
T_orbit=100;
T_visible=10;

matrix = [6 74 46 22
    66 50 64 56
    77 23 32 86
    25 20 33 84
    59 35 2 36
    19 32 -8 14
    43 26 19 67];

N_sats = 10;
N_nodes = 17;

mc_iter = 1000;
CPU_processing_time_1 = 0;
CPU_processing_time_2 = 0;

disp(['N' num2str(1) ' to GS: ' ]);
accuracy = 0;

for iter=1:mc_iter   
    matrix = randi([0, 100], N_nodes + 1, N_sats) - 10; % "+1" for the ground station
    [~,sat_NR]=min(matrix(1,:));
    dNR = hop_delay(matrix(1,sat_NR),matrix(end,sat_NR));

    % Step 0: Benchmark
    tic;
    for i = 1:1%N_nodes
        hops=inf;
        bestPath = {};
        bestDelay = inf;
        for j = 1:N_sats
            % check if one stage is the best
            if matrix(i,j)~= inf
                stage_delay = hop_delay(matrix(i,j),matrix(end,j));
                if stage_delay < bestDelay
                    if ~(stage_delay  == bestDelay && hops > 2)
                        bestDelay = stage_delay;
                        bestPath = {['N' num2str(i)], ['S' num2str(j)],['GS (2 Hops)']};
                        hops=2;
                    end
                end
                for k = 1:N_nodes
                    if  k ~= i && matrix(i,j) ~= inf && matrix(k,j)~=inf
                        hop2_delay = hop_delay(matrix(i,j),matrix(k,j));
                        for l_= 1:N_sats
                            if  l_ ~= j && matrix(k,l_)~=inf
                                hop3_delay = hop_delay(hop2_delay,matrix(k,l_));
                                % check if two stages are the best
                                stage_delay = hop_delay(hop3_delay,matrix(end,l_));
                                if stage_delay < bestDelay
                                    if ~(stage_delay  == bestDelay && hops > 4)
                                        bestDelay = stage_delay;
                                        bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)],  ['GS (4 Hops)']};
                                        hops=4;
                                    end
                                end
                                for m = 1:N_nodes+1
                                    if  k ~= m && matrix(m,l_)~=inf
                                        hop4_delay = hop_delay(hop3_delay,matrix(m,l_));
                                        for n= 1:N_sats
                                            if  l_ ~= n &&  matrix(m,n)~=inf
                                                hop5_delay = hop_delay(hop4_delay,matrix(m,n));
                                                % check if three stages are the best
                                                stage_delay =   hop_delay(hop5_delay,matrix(end,n));
                                                if stage_delay < bestDelay
                                                    if ~(stage_delay  == bestDelay && hops > 6)
                                                        bestDelay = stage_delay;
                                                        bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)], ['N' num2str(m)], ['S' num2str(n)],  ['GS (6 Hops)']};
                                                        hops=6;
                                                    end
                                                end
                                                for o = 1:N_nodes+1
                                                    if  k ~= m && matrix(m,l_)~=inf
                                                        hop6_delay = hop_delay(hop5_delay,matrix(m,l_));
                                                        for p= 1:N_sats
                                                            if  l_ ~= n && matrix(m,n)~=inf
                                                                hop7_delay = hop_delay(hop6_delay,matrix(m,n));
                                                                % check if four stages are the best
                                                                stage_delay =   hop_delay(hop7_delay,matrix(end,n));
                                                                if stage_delay < bestDelay
                                                                    if ~(stage_delay  == bestDelay && hops > 8)
                                                                        bestDelay = stage_delay;
                                                                        bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)], ['N' num2str(m)], ['S' num2str(n)],    ['N' num2str(o)], ['S' num2str(p)], ['GS (8 Hops)']};
                                                                        hops=8;
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
    path1 = bestPath;
    delay1 = bestDelay;
    CPU_processing_time_1 = CPU_processing_time_1 + toc;
    % % Display the best path and delay
    % disp(['Delay of No Routing: ' num2str(dNR)]);
    % disp(['Best path : ' strjoin(bestPath, ' -> ') ]);
    % disp(['Best path delay: ' num2str(bestDelay)   ]);    
    % disp([' ' ]);


    tic;
    
    matrix1 = matrix;

    % R1: Eliminer tout delai superieur ou egal a dNR
    for i=1:N_nodes+1
        for j=1:N_sats
            if matrix(i,j)>=dNR
                matrix(i,j)=inf;
            end
        end
    end

    matrix2 = matrix;

   if all(isinf(matrix(1, :))) || all(isinf(matrix(end, :)))
        accuracy = accuracy + 1;
   else
        [~,max_GS]=max(matrix(end,:));
        dGS_max = matrix(end,max_GS);
        [~,min_1]=min(matrix(1,:));
        d1_min = matrix(1,min_1);
    
        
        % R2+R3: Eliminer tout delai non accessibles par N1 et GS au pire des cas
        for i=1:N_nodes+1
            for j=1:N_sats
                if matrix(i,j)>dGS_max+10 || matrix(i,j) +10<d1_min
                    matrix(i,j)=inf;
                end
            end
        end
    
        matrix3 = matrix;
        
        % % R4
        % indices_queue = find(matrix(end, :) ~= inf);
        % 
        % visited = zeros(N_nodes+1,N_sats);
        % 
        % queue1 = find(matrix(end, :) ~= inf);
        % 
        % for j=1:N_sats
        %     visited(1,j)=1;
        %     visited(end,j)=1;
        % end
        % 
        % queue2 = []; % Initialiser queue2
        % 
        % % Étape 2: Parcours des éléments de queue1, Parcours vertical
        % for idx = queue1
        %     dGS = matrix(end, idx);
        %     for i = 2:N_nodes
        %         visited(i, idx) = 1;
        %         if matrix(i, idx) > dGS + T_visible
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
        %             for j = 1:N_sats
        %                 if j ~= start_column && visited(start_line, j) == 0
        %                     visited(start_line, j) = 1;
        %                     if matrix(start_line, j) > d1 + T_visible
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
        %             for i = 2:N_nodes
        %                 if i ~= start_line && visited(i, start_column) == 0
        %                     visited(i, start_column) = 1;
        %                     if matrix(i, start_column) > d2 + T_visible
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
        % valid_starting_sats = find(matrix(1, :) ~= inf);
        % 
        % if length(valid_starting_sats) > 1
        %     % Parcourir les lignes de la matrice
        %     for i = 2:N_nodes
        %         if all(matrix(i, valid_starting_sats) == inf)
        %             matrix(i, :) = inf;
        %         end
        %     end
        % end
        % 

        % % R6 
        % % Check rows
        % for i = 2:N_nodes
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
        % for j = 1:N_sats
        %     % Check how many elements are not inf in the column
        %     non_inf_elements = ~isinf(matrix(:, j));
        % 
        %     % If only one element is not inf, set it to inf
        %     if sum(non_inf_elements) == 1
        %         matrix(non_inf_elements, j) = inf;
        %     end
        % end


        % Step 3: Find the best path from nodes to GS considering DNR
        for i = 1:1%N_nodes
            hops=inf;
            bestPath = {};
            bestDelay = inf;
            for j = 1:N_sats
                % check if one stage is the best
                if matrix(i,j)~= inf
                    stage_delay = hop_delay(matrix(i,j),matrix(end,j));
                    if stage_delay < bestDelay
                        if ~(stage_delay  == bestDelay && hops > 2)
                            bestDelay = stage_delay;
                            bestPath = {['N' num2str(i)], ['S' num2str(j)],['GS (2 Hops)']};
                            hops=2;
                        end
                    end
                    for k = 1:N_nodes
                        if  k ~= i && matrix(i,j) ~= inf && matrix(k,j)~=inf
                            hop2_delay = hop_delay(matrix(i,j),matrix(k,j));
                            for l_= 1:N_sats
                                if  l_ ~= j && matrix(k,l_)~=inf
                                    hop3_delay = hop_delay(hop2_delay,matrix(k,l_));
                                    % check if two stages are the best
                                    stage_delay = hop_delay(hop3_delay,matrix(end,l_));
                                    if stage_delay < bestDelay
                                        if ~(stage_delay  == bestDelay && hops > 4)
                                            bestDelay = stage_delay;
                                            bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)],  ['GS (4 Hops)']};
                                            hops=4;
                                        end
                                    end
                                    for m = 1:N_nodes+1
                                        if  k ~= m && matrix(m,l_)~=inf
                                            hop4_delay = hop_delay(hop3_delay,matrix(m,l_));
                                            for n= 1:N_sats
                                                if  l_ ~= n &&  matrix(m,n)~=inf
                                                    hop5_delay = hop_delay(hop4_delay,matrix(m,n));
                                                    % check if three stages are the best
                                                    stage_delay =   hop_delay(hop5_delay,matrix(end,n));
                                                    if stage_delay < bestDelay
                                                        if ~(stage_delay  == bestDelay && hops > 6)
                                                            bestDelay = stage_delay;
                                                            bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)], ['N' num2str(m)], ['S' num2str(n)],  ['GS (6 Hops)']};
                                                            hops=6;
                                                        end
                                                    end
                                                    for o = 1:N_nodes+1
                                                        if  k ~= m && matrix(m,l_)~=inf
                                                            hop6_delay = hop_delay(hop5_delay,matrix(m,l_));
                                                            for p= 1:N_sats
                                                                if  l_ ~= n && matrix(m,n)~=inf
                                                                    hop7_delay = hop_delay(hop6_delay,matrix(m,n));
                                                                    % check if four stages are the best
                                                                    stage_delay =   hop_delay(hop7_delay,matrix(end,n));
                                                                    if stage_delay < bestDelay
                                                                        if ~(stage_delay  == bestDelay && hops > 8)
                                                                            bestDelay = stage_delay;
                                                                            bestPath = {['N' num2str(i)], ['S' num2str(j)], ['N' num2str(k)], ['S' num2str(l_)], ['N' num2str(m)], ['S' num2str(n)],    ['N' num2str(o)], ['S' num2str(p)], ['GS (8 Hops)']};
                                                                            hops=8;
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

        if bestDelay == inf
            bestDelay = dNR;
            bestPath = path1;
        end

        if bestDelay==delay1  || (length(bestPath)>length(path1) && bestDelay<=delay1)
            accuracy = accuracy+1;
        end
   end
    CPU_processing_time_2 = CPU_processing_time_2 + toc;
end
    
    % Choose the path matrixith the minimum total delay
    
    
% Display the best path and delay
disp(['Delay of No Routing: ' num2str(dNR)]);
disp(['Best path : ' strjoin(bestPath, ' -> ') ]);
disp(['Best path delay: ' num2str(bestDelay)   ]);
disp(['Processing time 1: ' num2str(CPU_processing_time_1/mc_iter)]);
disp(['Processing time 2: ' num2str(CPU_processing_time_2/mc_iter)]);
disp(['Accuracy: ' num2str(accuracy/10)]);

disp([' ' ]);




function total_delay = hop_delay(d_1,d_2)
% Calculate d_NR
hop1 =  d_1;
if d_2 < hop1 -10
    hop2 = 100 + d_2- d_1;  % Only consider the adjusted satellite to GS delay
else
    hop2 =  d_2 - max(0,d_1); % Consider both delays
end
total_delay = max(0,hop1) + max(0,hop2);
end