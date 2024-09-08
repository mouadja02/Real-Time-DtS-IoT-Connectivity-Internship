clc; close all; clear ;

% Read the CSV data
data = readtable('access_intervals6.csv');

% Define the orbital period and connectivity duration
orbital_period = 5724; % =1.59h (StarLink satellites orbit period)
connectivity_duration = 420; % 7 min

N_nodes = 12;
N_sats = 20;

end_node = 11;

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


                                % for q = 1:N_sats
                                %     relevant_data = data(strcmp(data.Source, "S" + num2str(q)) & strcmp(data.Target, "N" + num2str(p)), :);
                                %     if ~isempty(relevant_data) && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o
                                %         str_delays(8) = calculate_delay(str_delays(7), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                %     else
                                %         continue;
                                %     end
                                % 
                                %     if str_delays(8) > min_delay
                                %         continue
                                %     end
                                % 
                                %     for r = 1:N_nodes
                                %         relevant_data = data(strcmp(data.Source, "S" + num2str(q)) & strcmp(data.Target, "N" + num2str(r)), :);
                                %         if ~isempty(relevant_data) && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p
                                %             total_delay = calculate_delay(str_delays(8), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                %             str_delays(9) = total_delay;
                                %             if r == N_nodes && total_delay < min_delay
                                %                 opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r)];
                                %                 min_delay  = total_delay;
                                %             end
                                %         else
                                %             continue;
                                %         end
                                % 
                                %         if str_delays(9) > min_delay
                                %             continue
                                %         end
                                % 
                                %         for s = 1:N_sats
                                %             relevant_data = data(strcmp(data.Source, "S" + num2str(s)) & strcmp(data.Target, "N" + num2str(r)), :);
                                %             if ~isempty(relevant_data) && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s
                                %                 str_delays(10) = calculate_delay(str_delays(9), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                %             else
                                %                 continue;
                                %             end
                                % 
                                %             if str_delays(10) > min_delay
                                %                 continue
                                %             end
                                % 
                                %             for t = 1:N_nodes
                                %                 relevant_data = data(strcmp(data.Source, "S" + num2str(s)) & strcmp(data.Target, "N" + num2str(t)), :);
                                %                 if ~isempty(relevant_data) && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t
                                %                     total_delay = calculate_delay(str_delays(10), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                %                     str_delays(11) = total_delay;
                                %                     if t == N_nodes && total_delay < min_delay
                                %                         opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t)];
                                %                         min_delay  = total_delay;
                                %                     end
                                %                 else
                                %                     continue;
                                %                 end
                                % 
                                %                 if str_delays(11) > min_delay
                                %                     continue
                                %                 end
                                % 
                                % 
                                %                 for u = 1:N_sats
                                %                     relevant_data = data(strcmp(data.Source, "S" + num2str(u)) & strcmp(data.Target, "N" + num2str(t)), :);
                                %                     if ~isempty(relevant_data) && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s && u~=i && u~=k && u~=m && u~=o && u~=q && u~=s
                                %                         str_delays(12) = calculate_delay(str_delays(11), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                %                     else
                                %                         continue;
                                %                     end
                                % 
                                %                     if str_delays(12) > min_delay
                                %                         continue
                                %                     end
                                %                     for v = 1:N_nodes
                                %                         relevant_data = data(strcmp(data.Source, "S" + num2str(u)) & strcmp(data.Target, "N" + num2str(v)), :);
                                %                         if ~isempty(relevant_data) && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t && v~=j && v~=l && v~=n && v~=p && v~=r && v~=t 
                                %                             total_delay = calculate_delay(str_delays(12), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                %                             str_delays(13) = total_delay;
                                %                             if v == N_nodes && total_delay < min_delay
                                %                                 opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t), "S" + num2str(u), "N" + num2str(v)];
                                %                                 min_delay  = total_delay;
                                %                             end
                                %                         else
                                %                             continue;
                                %                         end
                                % 
                                %                         if str_delays(13) > min_delay
                                %                             continue
                                %                         end
                                % 
                                %                         for w = 1:N_sats
                                %                             relevant_data = data(strcmp(data.Source, "S" + num2str(w)) & strcmp(data.Target, "N" + num2str(v)), :);
                                %                             if ~isempty(relevant_data) && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s && u~=i && u~=k && u~=m && u~=o && u~=q && u~=s && w~=i && w~=k && w~=m && w~=o && w~=q && w~=s && w~=u
                                %                                 str_delays(14) = calculate_delay(str_delays(13), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                %                             else
                                %                                 continue;
                                %                             end
                                % 
                                %                             if str_delays(14) > min_delay
                                %                                 continue
                                %                             end
                                % 
                                %                             for x = 1:N_nodes
                                %                                 relevant_data = data(strcmp(data.Source, "S" + num2str(w)) & strcmp(data.Target, "N" + num2str(x)), :);
                                %                                 if ~isempty(relevant_data) && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t && v~=j && v~=l && v~=n && v~=p && v~=r && v~=t && x~=j && x~=l && x~=n && x~=p && x~=r && x~=t && x~=v
                                %                                     total_delay = calculate_delay(str_delays(14), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                %                                     str_delays(15) = total_delay;
                                %                                     if w == N_nodes && total_delay < min_delay
                                %                                         opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t), "S" + num2str(u), "N" + num2str(v), "S" + num2str(w), "N" + num2str(x)];
                                %                                         min_delay  = total_delay;
                                %                                     end
                                %                                 else
                                %                                     continue;
                                %                                 end
                                %                                 if str_delays(15) > min_delay
                                %                                     continue
                                %                                 end
                                % 
                                %                                 for y = 1:N_sats
                                %                                     relevant_data = data(strcmp(data.Source, "S" + num2str(y)) & strcmp(data.Target, "N" + num2str(x)), :);
                                %                                     if ~isempty(relevant_data) && k~=i && m~=i && k~=m && k~=o && o~=i && m~=o && q~=i && m~=q && k~=q && q~=o && s~=o && s~=i && m~=s && k~=s && q~=s && u~=i && u~=k && u~=m && u~=o && u~=q && u~=s && w~=i && w~=k && w~=m && w~=o && w~=q && w~=s && w~=u && y~=i && y~=k && y~=m && y~=o && y~=q && y~=s && y~=u && y~=w
                                %                                         str_delays(16) = calculate_delay(str_delays(15), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                %                                     else
                                %                                         continue;
                                %                                     end
                                % 
                                %                                     if str_delays(16) > min_delay
                                %                                         continue
                                %                                     end
                                % 
                                %                                     for z = 1:N_nodes
                                %                                         relevant_data = data(strcmp(data.Source, "S" + num2str(y)) & strcmp(data.Target, "N" + num2str(z)), :);
                                %                                         if ~isempty(relevant_data) && l~=j && l~=n && j~=n && l~=p && p~=n && j~=p && j~=r && l~=r && r~=n && r~=p && t~=p && j~=t && l~=t && t~=n && r~=t && v~=j && v~=l && v~=n && v~=p && v~=r && v~=t && x~=j && x~=l && x~=n && x~=p && x~=r && x~=t && x~=v && z~=j && z~=l && z~=n && z~=p && z~=r && z~=t && z~=v && z~=x
                                %                                             total_delay = calculate_delay(str_delays(16), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                                %                                             str_delays(17) = total_delay;
                                %                                             if z == N_nodes && total_delay < min_delay
                                %                                                 opt_path = ["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n), "S" + num2str(o), "N" + num2str(p), "S" + num2str(q), "N" + num2str(r), "S" + num2str(s), "N" + num2str(t), "S" + num2str(u), "N" + num2str(v), "S" + num2str(w), "N" + num2str(x), "S" + num2str(y), "N" + num2str(z)];
                                %                                                 min_delay  = total_delay;
                                %                                             end
                                %                                         else
                                %                                             continue;
                                %                                         end
                                % 
                                %                                         if str_delays(17) > min_delay
                                %                                             continue
                                %                                         end
                                % 
                                %                                     end
                                %                                 end
                                %                             end
                                %                         end
                                %                     end
                                    %             end
                                    %         end
                                    %     end
                                    % end
                                % end
                            end
                        end
                    end
                end
            end
        end
    end
end
   
toc

display("Shortest path : ");
display(opt_path);

display("Delay = ");
display(min_delay);

% Function to calculate delay between nodes
function delay = calculate_delay(x, y, connectivity_duration, orbital_period)
    if x > y
        if x < y + connectivity_duration
            delay = max(x,0);
        else
            delay = y + orbital_period;
        end
    else
        delay = max(y,0);
    end
end

% Function to find minimum delay and its index
function [min_val, min_idx] = min_del(X)
    min_val = X(1);
    min_idx = 1;
    for i = 2:length(X)
        if X(i) < min_val
            min_val = X(i);
            min_idx = i;
        end
    end
end
