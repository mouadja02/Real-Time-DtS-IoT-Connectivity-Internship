% Function to convert node/satellite identifier to integer
function id = convert_to_int(identifier, numberOfNodes)
    if startsWith(identifier, 'N')
        id = str2double(extractAfter(identifier, 'N'));
    elseif startsWith(identifier, 'S')
        id = str2double(extractAfter(identifier, 'S')) + numberOfNodes;
    else
        error('Invalid identifier format');
    end
end