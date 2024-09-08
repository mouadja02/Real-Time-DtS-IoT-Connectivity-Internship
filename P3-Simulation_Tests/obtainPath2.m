function path = obtainPath2(nextNode, start_node, end_node, numNodes)
    % Reconstruct the path from start_node to end_node using the nextNode matrix
    path = {};
    current = start_node;
    end_ = 0;
    stop = 0;
    while current ~= end_node
        if isNode(current, numNodes)
            path{end_+1} = ['N', num2str(current)];
        else
            path{end_+1} = ['S', num2str(current)];
        end
        end_ = end_ + 1;
        current = nextNode(current, end_node);
        if current==0 || current == start_node
            stop = 1;
            break;
        end
    end
    if ~stop
        if isNode(end_node, numNodes)
            path{end_+1} = ['N', num2str(end_node)];
        else
            path{end_+1} = ['S', num2str(end_node)];
        end
    else
        path = {};
    end
end


% function pathStr = obtainPath(i, j, parent,numNodes, dist)
%     if dist(i, j) == inf
%         pathStr = {};
%     else
%         if parent(i, j) == 0 || parent(i, j) == i
%             pathStr = '-->';
%         else
%             if parent(i, j) > numNodes
%                 pathStr = {obtainPath(i, parent(i, j), parent,numNodes, dist), 'S', num2str(parent(i, j)), ' ', obtainPath(parent(i, j), j, parent,numNodes, dist)};
%             else
%                 pathStr = {obtainPath(i, parent(i, j), parent,numNodes, dist), 'N', num2str(parent(i, j)), ' ', obtainPath(parent(i, j), j, parent,numNodes, dist)};
%             end
%         end
%     end
% end