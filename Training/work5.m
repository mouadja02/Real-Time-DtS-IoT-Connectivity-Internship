    for y = 1:length(iot_array)
        % Access intervals
        ac = access(sat_array(x), iot_array(y));
        intvls = accessIntervals(ac);
        
        % Convert IoT coordinates to Cartesian coordinates (assumed ECEF)
        iot_lat_deg = iot_array(y).Latitude;
        iot_lon_deg = iot_array(y).Longitude;
        iot_lat = deg2rad(iot_lat_deg);
        iot_lon = deg2rad(iot_lon_deg);
        iot_x = R * cos(iot_lat) * cos(iot_lon);
        iot_y = R * cos(iot_lat) * sin(iot_lon);
        iot_z = R * sin(iot_lat);
        iot_pos = [iot_x; iot_y; iot_z];

        for k = 1:size(intvls, 1)
            % Only compute at the start time of each interval
            start_time = intvls.StartTime(k);
            duration = intvls.Duration(k);
            
            % Get satellite position at start time in Geographic coordinate frame
            [pos, vel] = states(sat_array(x), start_time, 'CoordinateFrame', 'geographic');
            
            % Convert satellite position from geographic to Cartesian (ECEF)
            sat_lat = deg2rad(pos(1));
            sat_lon = deg2rad(pos(2));
            sat_alt = pos(3); % Assume altitude is included in pos vector
            sat_x = (R + sat_alt) * cos(sat_lat) * cos(sat_lon);
            sat_y = (R + sat_alt) * cos(sat_lat) * sin(sat_lon);
            sat_z = (R + sat_alt) * sin(sat_lat);

            % Calculate Euclidean distance
            distance = sqrt((sat_x - iot_x)^2 + (sat_y - iot_y)^2 + (sat_z - iot_z)^2);
            
            % Store distance and duration
            distance_array = [distance_array; distance];
            duration_array = [duration_array; duration];
        end
    end
end


