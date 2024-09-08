% function path = obtainPath(prev, start_node, end_node, numNodes)
%     % Reconstruct the path from start_node to end_node using the prev matrix
%     path = {};
%     current = end_node;
%     end_ = 0;
% 
%     while current ~= start_node
%         if prev(start_node, current) == 0
%             path = {};  % No path exists
%             return;
%         end
% 
%         if isNode(current, numNodes)
%             path{end_+1} = ['N', num2str(current)];
%         else
%             path{end_+1} = ['S', num2str(current - numNodes)];
%         end
% 
%         current = prev(start_node, current);
%         end_ = end_ + 1;
%     end
% 
%     % Add the start node to the path
%     if isNode(start_node, numNodes)
%         path{end_+1} = ['N', num2str(start_node)];
%     else
%         path{end_+1} = ['S', num2str(start_node - numNodes)];
%     end
% 
%     % Reverse the path to start from the start_node
%     path = fliplr(path);
% end


function path = obtainPath(nextNode, start_node, end_node, numNodes)
    % Reconstruct the path from start_node to end_node using the nextNode matrix
    path = {};
    current = start_node;
    end_ = 0;
    while current ~= end_node
        if current==0
            break;
        end
        if isNode(current, numNodes)
            path{end_+1} = ['N', num2str(current)];
        else
            path{end_+1} = ['S', num2str(current - numNodes)];
        end
        end_ = end_ + 1;
        current = nextNode(current, end_node);

    end
    if isNode(end_node, numNodes)
        path{end_+1} = ['N', num2str(end_node)];
    else
        path{end_+1} = ['S', num2str(end_node - numNodes)];
    end
end

