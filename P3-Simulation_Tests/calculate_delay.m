% Function to calculate delay between nodes
function delay = calculate_delay(x, y, connectivity_duration, orbital_period)
    if x==inf || y==inf
        delay=inf;
    else
        if x > y
            if x < y + connectivity_duration
                delay = max(x,0);
            else
                a = floor((x-connectivity_duration+1)/orbital_period);
                delay = y + (a+1)*orbital_period;
            end
        else
            delay = max(y,0);
        end
    end
end
