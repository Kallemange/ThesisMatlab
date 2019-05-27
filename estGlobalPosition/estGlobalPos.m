function estGlobalPos()
%Estimate global position from the raw data available in obsd_t and eph_t 
%calculations based on those presented in telesens

%A few steps are needed:
%1) Extract the eph data and put them in time-struct
    %*Each struct should have all values of the data up to given time. When
    %a new read is made an updated value may be introduced
%2) Perform global positioning of satellites
    %(Keep track of the time transformation from UTC-GPST)
%3) Try 3 different things:
       %a)Global positioning
       %b)Relative positioning from global estimates
       %c)Relative estimates from DD-method

load eph.mat

keyboard