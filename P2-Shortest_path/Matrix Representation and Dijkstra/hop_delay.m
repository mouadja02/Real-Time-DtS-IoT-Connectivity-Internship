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