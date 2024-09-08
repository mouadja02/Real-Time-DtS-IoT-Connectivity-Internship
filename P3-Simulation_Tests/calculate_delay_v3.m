function [receiving_delay,receiving_duration,sending_delay,sending_duration] = calculate_delay_v3(x_receiving_delay,x_receiving_duration,x_sending_delay,x_sending_duration, y_receiving_delay,y_receiving_duration,y_sending_delay,y_sending_duration, orbital_period)
    if x_receiving_delay==inf || x_receiving_duration==0 || x_sending_delay==inf || x_sending_duration==0
        receiving_delay=inf;
        receiving_duration=0;
    else
        receiving_delay=x_receiving_delay;
        receiving_duration=x_receiving_duration;
    end
    if y_receiving_delay==inf || y_receiving_duration==0 || y_sending_delay==inf || y_sending_duration==0
        sending_delay=inf;
        sending_duration=0;
    else
        % Second connectivvity reception cases
        if x_sending_delay < y_receiving_delay
            receiving_delay=x_receiving_delay;
            if x_sending_delay+x_receiving_duration<=y_receiving_delay
                receiving_duration=x_receiving_duration;
                sending_delay = y_sending_delay;
                sending_duration = y_sending_duration;
            else
                if y_receiving_delay+y_receiving_duration <= x_sending_delay+x_receiving_duration
                    receiving_duration=y_receiving_duration+y_receiving_delay-x_sending_delay;
                    sending_delay = y_sending_delay;
                    sending_duration = y_sending_duration;
                else
                    receiving_duration=x_receiving_duration;
                    sending_delay = y_sending_delay;
                    sending_duration = y_sending_duration;
                end
            end
        else
            if x_sending_delay > y_receiving_delay
                if y_receiving_delay+y_receiving_duration<=x_sending_delay
                    receiving_delay = x_receiving_delay;
                    receiving_duration = x_receiving_duration;
                    a = floor((x_sending_delay)/orbital_period);
                    sending_delay = y_sending_delay + (a+1) * orbital_period;
                    sending_duration = y_sending_duration;
                else
                    if y_receiving_delay+y_receiving_duration<x_sending_delay+x_receiving_duration
                        receiving_delay = x_sending_delay;
                        receiving_duration=y_receiving_delay+y_receiving_duration-x_sending_delay;
                        if y_sending_delay<x_sending_delay
                            sending_delay = x_sending_delay;
                            sending_duration = y_sending_duration;
                        else 
                            sending_delay = y_start;
                            sending_duration = y_sending_duration;
                        end
                    else
                        receiving_delay = x_sending_delay;
                        receiving_duration = x_receiving_duration;
                        sending_delay = y_sending_delay;
                        sending_duration = y_sending_duration;
                    end
                end
            else
                receiving_delay = x_sending_delay;
                receiving_duration = min(x_receiving_duration,y_receiving_duration);
                sending_delay = y_sending_delay;
                sending_duration = y_sending_duration;
            end
        end
    end
end
                    
               