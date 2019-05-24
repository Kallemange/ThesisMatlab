
% Constants that we will need
% Speed of light
close all, clear all, clc
c = 299792458;
% Earth's rotation rate
omega_e = 7.2921151467e-5; %(rad/sec)

% load out data
data = load('rtcm_data.mat');
logRaw=readLog('3_8_134020');
logEph=logRaw{2};


% Data is a cell array containing data about different RTCM messages. We
% are interested in 1002 and 1019
% msgs is a an array of message ids (1002, 1019 etc)
msgs = [data.data{1,:}];

% Get indicies of ephemeris info (msg 1019)
[idx_1019] = find(msgs == 1019);
% Get indicies of raw pseudorange info (msg 1002)
[idx_1002] = find(msgs == 1002);
% Satellite ephemeris data is all mixed up since different satellites are visible at
% different epocks.
eph = [data.data{2, idx_1019}];
% Lets group data for each satellite
% find unique satellite indicies
sv_arr = unique(eph(1,:));
sv_arr2 = unique(logEph(:,1));
% eph_data will contain ephemeris data for all epochs grouped by satellite
% number
eph_data = {};

for i = 1: length(sv_arr)
    % find indicies of all entries corresponding to this satellite
    sv = sv_arr(i);
    idx = find(eph(1,:) == sv);
    eph_data{sv} = eph(:,idx);
end
for i=1:size(sv_arr2,1)
    sv2=(sv_arr2.sat(i));
    idx2=find(logEph.sat==sv2);
    eph_data2{sv2}=logEph(idx2,:);
end

% Now let's deal with 1002 messages. 1002 messages have two entries - first
% one (nav1) is a 6*1 array containing: reference station id, receiver time
% of week, number of satellites etc. See decode_1002.m in goGPS for details
% The important pieces of info in nav1 are the receiver time of week and the
% number of satellites visible
% The second one (nav2) contains a block of 56*5 for every epoch.
% Num of rows (56) refers to the maximum number of satellites in the
% constellation. Num of cols (5) is the number of data elements for each satellite.
% We are interested in the second element, the raw pseudorange.
% For those satellites for which no info is available,
% the rows of nav2 contain 0s.
nav1 = [data.data{2, idx_1002}];
nav2 = [data.data{3, idx_1002}];
nav11 = {};
%The data relating to each satellite and its pr is extracted from a
%much larger matrix
for i=1:size(logRaw{1},1)
    nav11{i}.obsCount=logRaw{1}(i,1);
    nav11{i}.tow=logRaw{1}(i,2)+logRaw{1}(i,3);
    %%To get the right number of values in next line, we set a multiple of
    %%the number of obs*steps between indices
    h=5;
    endVal=(nav11{i}.obsCount-1)*h;
    nav11{i}.data=[(logRaw{1}(i,4:h:endVal+4));(logRaw{1}(i,8:h:endVal+8))];
end
%keyboard
len = length(nav1);
len2= size(logRaw{1},1);
% Arrays to store various outputs of the position estimation algorithm
user_position_arr = [];
user_position_arr2= [];
HDOP_arr = [];
HDOP_arr2= [];
VDOP_arr = [];
VDOP_arr2 = [];
user_clock_bias_arr = [];
user_clock_bias_arr2= [];

% initial position of the user
xu = [0 0 0];
xu2= [0 0 0];
% initial clock bias
b = 0;
b2= 0;
% 1002 messages are spaced apart 200ms. Let's use 1 out of every 5 samples.
% This means that we'll compute position every second, which is sufficient
for idx = 1:len2
    % second element of nav1 contains receiver time of week
    rcvr_tow = nav1(2,idx);
    rcvr_tow = nav11{idx}.tow;
    % data block corresponding to this satellite
    nav_data = nav2(:, 5*(idx-1)+1: 5*idx);
    % find indicies of rows containing non-zero data. Each row corresponds
    % to a satellite
    ind = find(sum(nav_data,2) ~= 0);
    numSV = length(ind);
    numSV2= nav11{idx}.obsCount;
    eph_formatted_ = [];
    eph_formatted2_= [],
    % The minimum number of satellites needed is 4, let's go for more than
    % that to be more robust
    if (numSV2 > 4)
        pr_ = [];
        % Correct for satellite clock bias and find the best ephemeris data
        % for each satellite. Note that satellite ephemeris data (1019) is sent
        % far less frequently than pseudorange info (1002). So for every
        % epoch, we find the closest (in time) ephemeris data.
        for i = 1: numSV2,
            %sv_idx = ind(i);
            %sv_data = nav_data(sv_idx,:);
            % find ephemeris data closest to this time of week
            %[c_ eph_idx] = min(abs(eph_data{sv_idx}(18,:)-rcvr_tow));
            %eph_ = eph_data{sv_idx}(:, eph_idx);
            eph2_idx= max(find(logRaw{2}.sat==idx));
            eph2_=logRaw{2}(eph2_idx,:);
            if (isempty(eph2_ ))
                keyboard
                continue
            end
            keyboard
            % Convert the ephemeris data into a standard format so it can
            % be input to routines that process it to calculate satellite
            % position and satellite clock bias

            %eph_formatted = format_ephemeris3(eph_);
            eph_formatted = format_ephemeris3(eph2_);

            eph_formatted_{end+1} = eph_formatted;
            % To be correct, the satellite clock bias should be calculated
            % at rcvr_tow - tau, however it doesn't make much difference to
            % do it at rcvr_tow
            dsv = estimate_satellite_clock_bias(rcvr_tow, eph_formatted);
            % measured pseudoranges corrected for satellite clock bias.
            % Also apply ionospheric and tropospheric corrections if
            % available
            pr_raw = sv_data(2);
            pr_(end+1) = pr_raw + c*dsv;
        end
        if (isempty(eph_formatted2_))
            continue
        end
        % Now lets calculate the satellite positions and construct the G
        % matrix. Then we'll run the least squares optimization to
        % calculate corrected user position and clock bias. We'll iterate
        % until change in user position and clock bias is less than a
        % threhold. In practice, the optimization converges very quickly,
        % usually in 2-3 iterations even when the starting point for the
        % user position and clock bias is far away from the true values.
        dx = 100*ones(1,3); db = 100;
        while(norm(dx) > 0.1 && norm(db) > 1)
            Xs = []; % concatenated satellite positions
            pr = []; % pseudoranges corrected for user clock bias

            for i = 1: numSV,
                % correct for our estimate of user clock bias. Note that
                % the clock bias is in units of distance
                cpr = pr_(i) - b;
                pr = [pr; cpr];
                % Signal transmission time
                tau = cpr/c;
                % Get satellite position
                [xs_ ys_ zs_] = get_satellite_position(eph_formatted_{i}, rcvr_tow-tau, 1);
                % express satellite position in ECEF frame at time t
                theta = omega_e*tau;
                xs_vec = [cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0; 0 0 1]*[xs_; ys_; zs_];
                xs_vec = [xs_ ys_ zs_]';
                Xs = [Xs; xs_vec'];
            end
            % Run least squares to calculate new user position and bias
            [x_, b_, norm_dp, G] = estimate_position(Xs, pr, numSV, xu, b, 3);
            % Change in the position and bias to determine when to quite
            % the iteration
            dx = x_ - xu;
            db = b_ - b;
            xu = x_;
            b = b_;
        end % end of iteration
        % Convert from ECEF to lat/lng
        [lambda, phi, h] = WGStoEllipsoid(xu(1), xu(2), xu(3));
        % Calculate Rotation Matrix to Convert ECEF to local ENU reference
        % frame
        lat = phi*180/pi
        lon = lambda*180/pi
        R1=rot(90+lon, 3);
        R2=rot(90-lat, 1);
        R=R2*R1;
        G_ = [G(:,1:3)*R' G(:,4)];
        H = inv(G_'*G_);
        HDOP = sqrt(H(1,1) + H(2,2));
        VDOP = sqrt(H(3,3));
        % Record various quantities for saving and plotting
        HDOP_arr(end+1,:) = HDOP;
        VDOP_arr(end+1,:) = VDOP;
        user_position_arr(end+1,:) = [lat lon h];
        user_clock_bias_arr(end+1,:) = b;
    end
end
HDOP_arr;
%Function R=rot(angle (degrees), axis) returns a 3x3
%rotation matrix for rotating a vector about a single
%axis.  Setting axis = 1 rotates about the e1 axis,
%axis = 2 rotates about the e2 axis, axis = 3 rotates
%about the e3 axis.

function R=rot(angle, axis)
%function R=rot(angle (degrees), axis)

R=eye(3);
cang=cos(angle*pi/180);
sang=sin(angle*pi/180);

if (axis==1)
    R(2,2)=cang;
    R(3,3)=cang;
    R(2,3)=sang;
    R(3,2)=-sang;
end;

if (axis==2)
    R(1,1)=cang;
    R(3,3)=cang;
    R(1,3)=-sang;
    R(3,1)=sang;
end;

if (axis==3)
    R(1,1)=cang;
    R(2,2)=cang;
    R(2,1)=-sang;
    R(1,2)=sang;
end;

return;
end