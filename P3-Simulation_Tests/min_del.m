

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