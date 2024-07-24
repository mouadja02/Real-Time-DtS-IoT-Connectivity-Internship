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
