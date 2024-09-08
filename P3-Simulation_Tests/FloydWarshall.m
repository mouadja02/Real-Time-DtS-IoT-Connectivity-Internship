function [min_delay, opt_path] = FloydWarshall(matrix, numNodes, numSats, start_node, end_node, connectivity_duration, orbital_period)
    V = numNodes + numSats;
    delays = inf(V, V);
    durations = inf(V,V);
    nextNode = zeros(V, V);  % Change to track the nextNodeious node instead of the next node
    
    for i = 1:numNodes
        for j = 1:numSats
            if matrix(i,j) ~= inf
                delays(i, j+numNodes) = matrix(i, j);
                delays(j+numNodes, i) = matrix(i, j);
                durations(j+numNodes, i) = connectivity_duration;
                durations(i, j+numNodes) = connectivity_duration;
                nextNode(i, j+numNodes) = j+numNodes; 
                nextNode(j+numNodes, i) = i;  
            end
        end
    end

    for i = 1:V
        delays(i, i) = 0;
        durations(i, i) = 0;
        nextNode(i,i) = i;
    end

    for k = 1:V
        for i = 1:V
            for j = 1:V
                if delays(i, k) ~= inf && delays(k, j) ~= inf 
                    nextNode(i, j) = nextNode(i, k); 
                    path = 
                    [delay_via_k,duration_via_k] = calculate_delay_v2(delays(i, k), durations(i, k), delays(k,j), durations(k, j), orbital_period);
                    
                    % % Debugging section for specific nodes
                    % if i == 5+numNodes && j==2 %&& k==1+numNodes
                    %     % Display paths
                    %     path_i_to_k = obtainPath(nextNode, i, k, numNodes);
                    %     path_k_to_j = obtainPath(nextNode, k, j, numNodes); 
                    %     disp(['Path from i to k: ', strjoin(path_i_to_k, ' -> ')]);
                    %     disp(['Path from k to j: ', strjoin(path_k_to_j, ' -> ')]);
                    %     disp(['Total delay via k: ', num2str(delay_via_k)]);
                    %     disp(['duration: ', num2str(duration_via_k)]);
                    %     disp(['Current delay: ', num2str(sending_delays(i,j))]);
                    %     disp("------------------------------------");
                    % end

                    if delays(i, j) > delay_via_k
                        delays(i, j) = delay_via_k;
                        durations(i, j) = duration_via_k;
                        nextNode(i, j) = nextNode(i, k); 
                    end

                    if delays(j, j) ~= 0
                        disp(['Negative cycle at: ', num2str(j)]);
                        return;
                    end
                end
            end
        end
    end
    % Retrieve the shortest path
    min_delay = delays(start_node, end_node);
    opt_path = obtainPath(nextNode, start_node, end_node, numNodes);

end


% function [min_delay, opt_path] = FloydWarshall(matrix, numNodes, numSats, start_node, end_node, connectivity_duration, orbital_period)
%     V = numNodes + numSats;
%     sending_delays = inf(V, V);
%     receiving_delays  = inf(V, V);
%     sending_durations = inf(V, V);
%     receiving_durations = inf(V,V);
%     nextNode = zeros(V, V);  % Change to track the nextNodeious node instead of the next node
% 
%     for i = 1:numNodes
%         for j = 1:numSats
%             if matrix(i,j) ~= inf
%                 sending_delays(i, j+numNodes) = matrix(i, j);
%                 sending_delays(j+numNodes, i) = matrix(i, j);
%                 receiving_delays(i, j+numNodes) = matrix(i, j);
%                 receiving_delays(j+numNodes, i) = matrix(i, j);
%                 sending_durations(i, j+numNodes) = connectivity_duration;
%                 sending_durations(j+numNodes, i) = connectivity_duration;
%                 receiving_durations(j+numNodes, i) = connectivity_duration;
%                 receiving_durations(i, j+numNodes) = connectivity_duration;
%                 nextNode(i, j+numNodes) = j+numNodes; 
%                 nextNode(j+numNodes, i) = i;  
%             end
%         end
%     end
% 
%     for i = 1:V
%         sending_delays(i, i) = 0;
%         receiving_delays(i, i) = 0;
%         sending_durations(i, i) = 0;
%         receiving_durations(i, i) = 0;
%         nextNode(i,i) = i;
%     end
% 
%     for k = 1:V
%         for i = 1:V
%             for j = 1:V
%                 if sending_delays(i, k) ~= inf && sending_delays(k, j) ~= inf && receiving_delays(i, k) ~= inf && receiving_delays(k, j) ~= inf
%                     [receiving_delay_via_k, receiving_duration_via_k, sending_delay_via_k, sending_duration_via_k] = calculate_delay_v3(sending_durations(i, k), sending_durations(i, k), receiving_delays(k,j), receiving_durations(k, j), sending_delays(k,j), sending_durations(k, j), orbital_period);
% 
%                     % Debugging section for specific nodes
%                     if i == 5+numNodes && j==2 %&& k==1+numNodes
%                         % Display paths
%                         path_i_to_k = obtainPath(nextNode, i, k, numNodes);
%                         path_k_to_j = obtainPath(nextNode, k, j, numNodes); 
%                         disp(['Path from i to k: ', strjoin(path_i_to_k, ' -> ')]);
%                         disp(['Path from k to j: ', strjoin(path_k_to_j, ' -> ')]);
%                         disp(['From i to k : Receive data: ', num2str(receiving_delays(i,k)),'(', num2str(receiving_durations(i,k)),') ,  Sending delay from k to j: ', num2str(sending_delays(i,k)),'(', num2str(sending_durations(i,k)),') ']);
%                         disp(['From k to j : Receive data: ', num2str(receiving_delays(k,j)),'(', num2str(receiving_durations(k,j)),') ,  Sending delay from k to j: ', num2str(sending_delays(k, j)),'(', num2str(sending_durations(k,j)),') ']);
%                         disp(['Total delay via k: ', num2str(sending_delay_via_k)]);
%                         disp(['duration: ', num2str(sending_duration_via_k)]);
%                         disp(['Current delay: ', num2str(sending_delays(i,j))]);
%                         disp("------------------------------------");
%                     end
% 
%                     if sending_delays(i, j) > sending_delay_via_k
%                         receiving_delays(i, j) = receiving_delay_via_k;
%                         receiving_durations(i, j) = receiving_duration_via_k;
%                         sending_delays(i, j) = sending_delay_via_k;
%                         sending_durations(i, j) = sending_duration_via_k;
%                         nextNode(i, j) = nextNode(i, k); 
%                     end
% 
%                     if sending_delays(j, j) ~= 0
%                         disp(['Negative cycle at: ', num2str(j)]);
%                         return;
%                     end
%                 end
%             end
%         end
%     end
%     % Retrieve the shortest path
%     min_delay = sending_delays(start_node, end_node);
%     opt_path = obtainPath(nextNode, start_node, end_node, numNodes);
% 
% end
