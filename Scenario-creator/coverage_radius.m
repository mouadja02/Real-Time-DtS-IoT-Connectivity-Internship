function r = coverage_radius(h)
    R_earth  = 6371; % km
    r = R_earth * sqrt(power((h+R_earth)/R_earth,2)-1);
end