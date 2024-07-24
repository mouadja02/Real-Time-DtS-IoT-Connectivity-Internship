clear all
clc
% Number of nodes and satellites
T_orbit=100;
T_visibile=10;
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
N_sats = 6;
N_nodes = 15;

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
    disp(['Delay of No Routing: ' num2str(hop_delay(W(i,sat_NR),W(end,sat_NR)))]);
    disp(['Best path : ' strjoin(bestPath, ' -> ') ]);
    disp(['Best path delay: ' num2str(bestDelay)   ]);
    toc
    disp([' ' ]);
    
    
end




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