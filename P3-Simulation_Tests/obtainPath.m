function pathStr = obtainPath(i, j, parent, dist, numNodes)
    if dist(i, j) == inf
        pathStr = ' no path to ';
    else
        if parent(i, j) == 0 || parent(i, j) == i
            pathStr = '-->';
        else
            if parent(i, j) > numNodes
                pathStr = [obtainPath(i, parent(i, j), parent, dist, numNodes), ' S', num2str(parent(i, j)-numNodes), ' ', obtainPath(parent(i, j), j, parent, dist, numNodes)];
            else
                pathStr = [obtainPath(i, parent(i, j), parent, dist, numNodes), ' N', num2str(parent(i, j)), ' ', obtainPath(parent(i, j), j, parent, dist, numNodes)];
            end
        end
    end
end
