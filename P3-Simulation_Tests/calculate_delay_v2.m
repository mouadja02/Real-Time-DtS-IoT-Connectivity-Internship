function [delay,duration] = calculate_delay_v2(x_start, x_duration, y_start, y_duration, orbital_period)
    if x_start==inf || y_start==inf || x_duration==0 || y_duration==0
        delay=inf;
        duration=0;
    else
        if x_start > y_start
            if x_start < y_start + y_duration 
                if x_start+x_duration>=y_start+y_duration
                    delay = max(x_start,0);
                    duration = y_start+y_duration-x_start;
                else
                    delay = max(x_start,0);
                    duration = x_duration;
                end
            else
                a = floor((x_start-x_duration+1)/orbital_period);
                delay = y_start + (a+1)*orbital_period;
                duration = y_duration;
            end
        else
            if x_start < y_start
                if x_start+x_duration<y_start+y_duration && x_start+x_duration>y_start
                    delay = max(y_start,0);
                    duration = x_start+x_duration-y_start;
                else
                    delay = max(y_start,0);
                    duration = y_duration;
                end
            else % x_start==y_start
                delay = x_start;
                duration = min(x_duration,y_duration);
            end
        end
    end
end
