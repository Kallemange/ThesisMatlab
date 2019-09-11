function out=estGlobalPos(raw, eph, h, t_end)
%Estimate global position from the raw data available in obsd_t and eph_t 
%calculations based on those presented in telesens
%IN 
% raw - observation data struct containing 
%   - numsats: # observed satellites    
%   - ToW: time in unix seconds
%   - data: table with fields (sat, SNR, LLI, code, P (pseudorange)
%OUT
% out - calculations struct with the fields:
%       bVec: receiver clock bias [m]
%       xVec: receiver position in ECEF
%       Hvec: satellite geometric distribution matrix
%     llaVec: receiver position in lla-coordinates
%     tauVec: signal transmission time (probably not interesting)
%       tVec: receiver time in unix
%      satID: satellites available from ephemeris data
%     satPos: struct with fields:
%               pos: [(time of week) (satellites position in ECEF)]
%               pos_unadj: position without subtracting transmission time (ignore)
%               t: time of week [s]
%               elAz: satellite position in elevation-azimuth coordinates
%               wrt receiver position (position given by receiver used as
%               ground truth)
%     obsVec: struct with fields:
%               obs: raw pseudorange values
%               obsAdj: pseudorange adjusted wrt receiver clock bias estimate
%               t: time of week (GPS time) [s] 

%Args: T: epochs in raw       
% Constants that we will need
% Speed of light
c = 299792458;
% Earth's rotation rate
omega_e = 7.2921151467e-5; %(rad/sec)
%true position (within 10 m)
posRec=[59.3529   18.0732   31.9990];
T=length(raw);
% initial position of the user
xu = [0 0 0];
% initial clock bias
b = 0;
%All the svID's available in the eph-data for referencing
eph=eph([eph(:).sat]<=32);
satID=[eph(:).sat]';
satID=satID(satID<=32);
out.bVec=[];
out.xVec=[];
out.Hvec={};
out.llaVec=[];
out.tauVec=[];

if nargin<4
    t_end=T;
end
if nargin<3
    h=5;
end
tVec=[raw(1:h:t_end).ToW];
noSats=length(eph);
allSatPos.pos=cell(noSats,1);
allSatPos.pos_unadj=cell(noSats,1);
allSatPos.t=[];
allSatPos.elAz=cell(noSats,1);
obsVec.obs=cell(noSats,1);
obsVec.obsAdj=cell(noSats,1);
obsVec.t=[];

dsv = zeros(size(eph));
for i=1:h:t_end
    if mod(i,100)==1
        ['iteration:'    num2str(i)]
    end
    %Time is converted from posix (seconds since 1970) to ToW used in GPS
    %to get alignment. 
    [~, t]=UTC_in_sec2GPStime(raw(i).ToW);
    %Extract those measurements in raw which has corresponding eph-data
    %Also use only that eph-data for satellites which has an obs
    raw_t=sortrows(raw(i).data, 1);
    [~, iR, iE]=intersect(raw_t.sat,satID);
    obs=raw_t.P(iR);
    eph_t=eph(iE);
    if length(obs)<4
        continue
    end
    %Calculate the satellite clock bias
    for j=1:length(eph_t)
        dsv(j) = estimate_satellite_clock_bias(t, eph(j));   
    end    
    
    %And transform it to a distance through c
    %Adjust the raw pr-measurement for the clock bias of the sv
    obsAdj=obs+dsv(iE)'*c;
    
    dx = 100*ones(1,3); db = 100;
    while(norm(dx) > 0.1 && norm(db) > 1)
        Xs = []; % concatenated satellite positions
        Xs_unadj=[];
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
            %Without tau
            xs_unadj=0;
            ys_unadj=0;
            zs_unadj=0;
            %[xs_unadj, ys_unadj, zs_unadj]=get_satellite_position(eph_t(k),t,1);
            % express satellite position in ECEF frame at time t
            theta = omega_e*tau;
            %xs_vec = [cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0; 0 0 1]*[xs_; ys_; zs_];
            xs_vec = [xs_ ys_ zs_]';
            Xs = [Xs; xs_vec'];
            Xs_unadj=[Xs_unadj; xs_unadj ys_unadj zs_unadj];
        end
        [x_, b_, norm_dp, G] = estimate_position(Xs, pr, length(iR), xu, b, 3);
        % Change in the position and bias to determine when to quit
        % the iteration
        dx = x_ - xu;
        db = b_ - b;
        xu = x_;
        b = b_;
        
    end
    %Calculate the DOP-matrix values
    out.Hvec{end+1}=calcH(posRec, Xs);
    out.bVec=[out.bVec b];
    out.tauVec=[out.tauVec tau];
    lla=ecef2lla(xu, 'WGS84');
    out.llaVec=[out.llaVec; lla];
    out.xVec=[out.xVec; x_];
    out.tVec=tVec;
    out.satID=satID;
    %We must have an index putting satellite positions in the correct
    %place, through indexing all satellites in eph
    [~, ~, satIdx_t]=intersect([eph_t(:).sat],[eph(:).sat]);
    for m=1:length(satIdx_t)
        n=satIdx_t(m);
        allSatPos.pos{n}(end+1,:)=[t Xs(m,:)];
        allSatPos.pos_unadj{n}(end+1,:)=[t Xs_unadj(m,:)];
        [az, el, dist]=ecef2elaz(Xs(m,:), posRec);
        allSatPos.elAz{n}(end+1,:)=[raw(i).ToW, az, el, dist];
        obsVec.obs{n}(end+1, :)=[t obs(m)];
        obsVec.obsAdj{n}(end+1, :)=[t pr(m)];

    end
    
    allSatPos.t(end+1)=t;
    obsVec.t(end+1)=t;
    out.satPos=allSatPos;
    out.obsVec=obsVec;
end
end
