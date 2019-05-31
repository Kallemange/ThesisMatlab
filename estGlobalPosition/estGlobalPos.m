function xVec=estGlobalPos(raw, eph)
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
% Constants that we will need
% Speed of light
c = 299792458;
% Earth's rotation rate
omega_e = 7.2921151467e-5; %(rad/sec)
T=length(raw);
% initial position of the user
xu = [0 0 0];
% initial clock bias
b = 0;
%All the svID's available in the eph-data for referencing
satID=[eph(:).sat]';
satID=satID(satID<=32);
xVec=[];
t_end=10;
tVec=[raw(1:t_end).ToW];
for i=1:t_end
    %Time is converted from posix (seconds since 1970) to ToW used in GPS
    %to get alignment.
    t0Posix=datetime(raw(i).ToW,'ConvertFrom','posixtime');
    start_time=[t0Posix.Year, t0Posix.Month, t0Posix.Day, t0Posix.Hour, ...
                t0Posix.Minute, floor(t0Posix.Second)];
    [~, t]=UTC2GPStime(start_time);
    t=t+19;
    %Extract those measurements in raw which has corresponding eph-data
    %Also use only that eph-data for satellites which has an obs
    raw_t=sortrows(raw(i).data, 1);
    [~, iR, iE]=intersect(raw_t.sat,satID);
    obs=raw_t.P(iR);
    eph_t=eph(iE);
    %Calculate the satellite clock bias
    dsv = zeros(size(eph_t));
    for j=1:length(eph_t)
        dsv(j) = estimate_satellite_clock_bias(t, eph_t(j));   
    end
    %And transform it to a distance through c
    %Adjust the raw pr-measurement for the clock bias of the sv
    %(Looks unreasonably large with distances of up to 1e6)
    obsAdj=obs+dsv'*c;
    
    dx = 100*ones(1,3); db = 100;
    while(norm(dx) > 0.1 && norm(db) > 1)
        Xs = []; % concatenated satellite positions
        pr = []; % pseudoranges corrected for user clock bias
        for k=1:length(eph_t)
            % correct for our estimate of user clock bias. Note that
            % the clock bias is in units of distance
            cpr = obsAdj(k) - b;
            pr = [pr; cpr];
            % Signal transmission time
            tau = cpr/c;
            %For each satellite, calculate the ECEF-position in xyz. 
            [xs_, ys_, zs_]=get_satellite_position(eph_t(k),t-tau,1);
            % express satellite position in ECEF frame at time t
            theta = omega_e*tau;
            xs_vec = [cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0; 0 0 1]*[xs_; ys_; zs_];
            %xs_vec = [xs_ ys_ zs_]';
            Xs = [Xs; xs_vec'];
        end
        [x_, b_, norm_dp, G] = estimate_position(Xs, pr, length(iR), xu, b, 3);
        % Change in the position and bias to determine when to quit
        % the iteration
        dx = x_ - xu;
        db = b_ - b;
        xu = x_;
        b = b_;
    end
    %[lat lon alt]=ECEF2LLA(satPosECEF);
    %[[eph(:).sat]' lat*180/pi lon*180/pi]
    lla=ecef2lla(xu, 'WGS84');
    lla(1:2)
    xVec=[xVec; x_];
end
figure(1)
labelVec=['x', 'y', 'z'];
for i=1:3
    subplot(3,1,i)
    plot(tVec-tVec(1),xVec(:,i)-xVec(1,i), '*')
    xlabel(strcat(labelVec(i),'-axis in ECEF'))
end
keyboard


end
