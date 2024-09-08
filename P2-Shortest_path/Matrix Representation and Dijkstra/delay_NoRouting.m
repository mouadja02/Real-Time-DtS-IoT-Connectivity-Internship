function [path,min_delay] = delay_NoRouting(matrix,connectivity_duration, orbital_period)
    numSat=length(matrix(1,:));
    min_delay = inf;
    path = {'No Route'};
    for i=1:numSat
        if matrix(1,i)~=inf && matrix(end,i)~=inf
            delay = hop_delay(matrix(1,i),matrix(end,i));
            if delay < min_delay
                path = {'N1', ['S' num2str(i)],'GS (NR)'};
                min_delay = delay;
            end
        end
    end
    % Display the NR path and delay
    disp('N1 to GS: ' );
    disp(['Delay of No Routing: ' num2str(min_delay)]);
    disp(['Best No Routing path : ' strjoin(path, ' -> ') ]);
    disp([' ' ]);
end
