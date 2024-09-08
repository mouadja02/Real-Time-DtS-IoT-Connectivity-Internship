function idx = getIndex(node, numNodes)
    % Convert node name to index
    if startsWith(node, 'N')
        idx = str2double(extractAfter(node, 'N'));
    else
        idx = numNodes + str2double(extractAfter(node, 'S'));
    end
end
