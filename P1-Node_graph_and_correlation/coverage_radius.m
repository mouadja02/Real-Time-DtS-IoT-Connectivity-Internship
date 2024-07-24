function r = coverage_radius(h)
    R_earth  = 6371; % km
    %r = sqrt(power(R_earth+h,2)-R_earth*R_earth);
    if h<700 || h>1200
        A = (0.5*510072000) / (1+R_earth/h) ; % km2
        r = sqrt(A/pi);
    else
        %r = R_earth * sqrt(power((h+R_earth)/R_earth,2)-1)
        r = sqrt(power(R_earth+h,2)-R_earth*R_earth);

end