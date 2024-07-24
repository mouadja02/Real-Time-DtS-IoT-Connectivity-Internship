function T = visibility_estimation(h,r,dmin)
    G = 6.67E-20; % km3 kg-1 s-2
    M_earth = 5.972E24; % kg 
    R_earth  = 6371; % km
    C = (2/R_earth)*sqrt(power(R_earth+h,3)/(G*M_earth))
    T = zeros(1,length(dmin));
    for i=1:length(dmin)
        if r>dmin(i)
            T(i) = C * sqrt(r*r-dmin(i)*dmin(i));
        else 
            T(i) = 0;
        end
    end
end