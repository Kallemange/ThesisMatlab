function estGlobalPos(raw, eph)
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

%Args: T: epochs in raw       

T=length(raw);
for i=1:T
    %t=1558449864;
    %t0r=datetime(t,'ConvertFrom','posixtime');
    t=raw(i).ToW;
    t0r=datetime(raw(1).ToW,'ConvertFrom','posixtime');
    testtime=0;
    %All satellite positions in a n*3-matrix
    satPosECEF=zeros(length(eph),3);
    %Calculate the satellite clock bias
    %dsv = estimate_satellite_clock_bias(t, eph);
    for j=1:length(eph)
        %For each satellite, calculate the ECEF-position in xyz. 
        [xs, ys, zs]=get_satellite_position(eph(j),t,1);      
        satPosECEF(j,:)=[xs, ys, zs];        
    end
    %[lat lon alt]=ECEF2LLA(satPosECEF);
    %[[eph(:).sat]' lat*180/pi lon*180/pi]
    lla=ecef2lla(satPosECEF, 'WGS84');
    [[eph(:).sat]' lla(:,1:2)]
    keyboard
end
    
keyboard