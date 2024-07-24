clc; close all; clear;

% Read the CSV data
data = readtable('access_intervals2.csv');

% Define the orbital period and connectivity duration
orbital_period = 5724; % =1.59h (StarLink satellites orbit period)
connectivity_duration = 420; % 7 min

N_nodes = 4;
N_sats = 3;

paths = {};
delays = [];
str_delays = zeros(1,5);

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
            if j == N_nodes
                paths = [paths; {["N1", "S" + num2str(i), "N" + num2str(j)]}];
                delays = [delays, total_delay];
            end
        else
            continue;
        end

        for k = 1:N_sats 
            relevant_data = data(strcmp(data.Source, "S" + num2str(k)) & strcmp(data.Target, "N" + num2str(j)), :);
            if ~isempty(relevant_data) && k~=i
                str_delays(2) = calculate_delay(str_delays(1), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
            else
                continue;
            end
            
            for l = 1:N_nodes
                relevant_data = data(strcmp(data.Source, "S" + num2str(k)) & strcmp(data.Target, "N" + num2str(l)), :);
                if ~isempty(relevant_data) && l~=j
                    total_delay = calculate_delay(str_delays(2), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                    str_delays(3) = total_delay;
                    if l == N_nodes
                        paths = [paths; {["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l)]}];
                        delays = [delays, total_delay];
                    end
                else
                    continue;
                end

                for m = 1:N_sats
                    relevant_data = data(strcmp(data.Source, "S" + num2str(m)) & strcmp(data.Target, "N" + num2str(l)), :);
                    if ~isempty(relevant_data) && k~=i && m~=i && k~=m
                        str_delays(4) = calculate_delay(str_delays(3), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                    else
                        continue;
                    end
                    
                    for n = 1:N_nodes
                        relevant_data = data(strcmp(data.Source, "S" + num2str(m)) & strcmp(data.Target, "N" + num2str(n)), :);
                        if ~isempty(relevant_data) && l~=j && l~=n && j~=n
                            total_delay = calculate_delay(str_delays(4), seconds(min(relevant_data.StartTime)), connectivity_duration, orbital_period);
                            str_delays(5) = total_delay;
                            if n == N_nodes
                                paths = [paths; {["N1", "S" + num2str(i), "N" + num2str(j), "S" + num2str(k), "N" + num2str(l), "S" + num2str(m), "N" + num2str(n)]}];
                                delays = [delays, total_delay];
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

% Function to calculate delay between nodes
function delay = calculate_delay(x, y, connectivity_duration, orbital_period)
    if x > y
        if x < y + connectivity_duration
            delay = x;
        else
            delay = y + orbital_period;
        end
    else
        delay = y;
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
