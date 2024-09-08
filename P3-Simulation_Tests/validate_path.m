function delay = validate_path(matrix,dist,path,connectivity_duration,orbital_period, numNodes)
    in = 0;
    for i = 1:length(path)
        in = 1;
        num_str = regexp(path{i}, '\d+', 'match');
        numbers(i) = str2double(num_str{1});
    end
    if ~in || isscalar(numbers)
        delay = dist;
        return;
    else
        
        if numbers(1)<=numNodes
            if matrix(numbers(1),numbers(2)-numNodes)<dist
                delay = matrix(numbers(1),numbers(2)-numNodes);
            else
                delay = inf;
                return;
            end
        else
            if matrix(numbers(2),numbers(1)-numNodes)<dist
                delay = matrix(numbers(2),numbers(1)-numNodes);
            else
                delay = inf;
                return;
            end
        end
        i=2;
        while i<length(numbers)
            a = numbers(i);
            b = numbers(i+1);
            if a<=numNodes
                delay=calculate_delay(delay,matrix(a,b-numNodes),connectivity_duration,orbital_period);
            else
                delay=calculate_delay(delay,matrix(b,a-numNodes),connectivity_duration,orbital_period);
            end
    
            if delay>dist
                delay = inf;
                return;
            end
    
            i = i+1;
        end
    end
end