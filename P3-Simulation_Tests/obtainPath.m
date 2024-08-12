function pathStr = obtainPath(i, j, parent, numNodes)
    if parent(i, j) == 0 || parent(i, j) == i
        pathStr = '-->';
    else
        if parent(i, j) > numNodes
            pathStr = [obtainPath(i, parent(i, j), parent, numNodes), ' S', num2str(parent(i, j)-numNodes), ' ', obtainPath(parent(i, j), j, parent, numNodes)];
        else
            pathStr = [obtainPath(i, parent(i, j), parent, numNodes), ' N', num2str(parent(i, j)), ' ', obtainPath(parent(i, j), j, parent, numNodes)];
        end
    end
end
