function out=estGlobalPos(raw, eph, sets, posRec)
% Estimate global position from the raw data available in obsd_t and eph_t 
% calculations based on those presented in 
% http://www.telesens.co/2017/07/17/calculating-position-from-raw-gps-data/
% For each epoch (set of observation), calculations performed in 3 steps:
%   1. Calculate satellite clock bias for each satellite and transform to
%   distance
% Iterative Gauss-Jordan cost minimizing arguments to the cost function
% |y-f(p,b)| where 
%   y are the observations
%   f(p,b):=|p_sat-p|+c*dt, where
%       p_sat is the satellite positions
%       p is the estimated receiver position
%       dt is the estimated receiver clock bias
%       c is the speed of light
%   2. Calculate satellite position for given time
%   3. Calculate least square solution 
%IN 
% raw, struct[]:        observation data struct containing 
%   numsats, int[]:     # observed satellites    
%   ToW, double:        time of observation in unix seconds
%   data, double[][5]:  Matrix with columns sat, SNR, LLI, code, P (pseudorange)
%OUT
% out, struct[]:,               calculations struct with the fields:
%       bVec, double[]:         receiver clock bias [m]
%       xVec, double[][3]:      receiver position in ECEF
%       Hvec, cell[]:           satellite geometric distribution matrix
%       llaVec, double[][3]:    receiver position in lla-coordinates
%       tVec, double[]:         registered receiver time [GPST]
%       satID, int[]:           satellites available from ephemeris data
%       satPos, struct[]:       satellite positions with fields
%               pos, double[][4]: [time of week, (satellites position in ECEF)]
%               elAz, double[][4]:[time of week, elevation, azimuth, distance]
%       obsVec, struct[]: Observation data with fields:
%               obs, cell[]:    [time of week, raw pseudorange values]
%               obsAdj, cell[]: [time of week, pseudorange adjusted wrt c*dt]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Input argument cases
if nargin<4
    posRec  = sets.posECEF;
end
if (sets.optSol.OnlyGPS) % Remove all non GPS-satellites
    eph     =eph([eph(:).sat]<=sets.optSol.satIDMax);
end
if ~sets.globalPos.t_end % Final value used in the log
    t_end=length(raw);
end
elMask  = sets.optSol.elMask; % Elevation mask for satellites
h       = sets.globalPos.h;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constants
c       = 299792458;        % Speed of light
omega_e = 7.2921151467e-5;  % Earth's rotation rate [rad/sec]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Anonymous functions
%Indexing function to get the column in the dataset
I =@(var) find(["sat", "SNR", "LLI", "code", "P"]==var);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Instatiation of data 
xu              = [0 0 0];          % Initial position of the user
b               = 0;                % Initial clock bias
satID           = [eph(:).sat]';    % Get all the svID's available in the eph-data for referencing
out.bVec        = [];               % Receiver clock bias per iteration
out.xVec        = [];               % Receiver position in ECEF-coordinates
out.Hvec        = {};               % Receiver satellite geometry DOP-values
out.llaVec      = [];               % Receiver position in LLA-coordinates
out.satID       = satID;            % All satID's 
out.tVec        = [];               % Time of week [GPST]
out.visSV       = [];
week            = eph(1).week;      % GPS-week (since Jan 6 1980)
noSats          = length(eph);      % Number of satellites tracked
allSatPos.pos   = cell(noSats,1);   % Satellite positions over time [m ECEF]
allSatPos.elAz  = cell(noSats,1);   % Satellite position over time [m EL-AZ]
obsVec.obs      = cell(noSats,1);   % Raw observation [m]
obsVec.obsAdj   = cell(noSats,1);   % Observation adjusted for clock bias [m]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Main calculation loop
for i=1:h:t_end
    if (sets.print.Itr &&~mod(i,sets.print.Mod))
        "iteration "+str(i)
    end
    [~, t]          = UTC_in_sec2GPStime(raw(i).ToW, week); %Time conversion [POSIX->GPST]
    %Extract those measurements in raw and eph where data correspond for epoch
    raw_t           = sortrows(raw(i).data, I("sat"));
    [~, iR, iE]     = intersect(raw_t(:,I("sat")),satID);
    obs             = raw_t(iR,I("P"));
    SNR             = raw_t(iR,I("SNR"));
    eph_t           = eph(iE);
    [eph_t, obs, SNR]    = satElevMask(eph_t,obs, SNR, t, posRec, elMask); %Remove sats below elevMask
    if length(obs)<=4 %Minimum 4 sats used to calculate position and clock bias
        continue
    end
    
    % Calculate the satellite clock bias [s] using ephemeris data and ToW.
    % Transform it to distance through multiplication with c
    % Adjust the raw observation for the clock bias of the sv
    dsv = zeros(size(eph_t));
    for j=1:length(eph_t)
        dsv(j) = estimate_satellite_clock_bias(t, eph_t(j));   
    end 
    obsAdj=obs+dsv'*c;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % User position, clock bias and satellite position is iteratively
    % estimated until convergence in 2 steps using Gauss-Jordan solver
    % 1. Calculate satellite position at time of transmission
    % 2. Calculate receiver state for satellite positions
    % Reiterate 1 and 2 for updated values until convergence
    dx = 100*ones(1,3); db = 100;
    while(norm(dx) > 0.1 && norm(db) > 0.1)
        Xs = zeros(length(eph_t),3);    % Satellite position matrix
        pr = zeros(length(eph_t),1);    % Corrected obs wrt receiver clock bias
        for k=1:length(eph_t)
            cpr = obsAdj(k) - b;        % Adjust observation for current estimate of receiver clock bias.
            pr(k) = cpr;                % Store updated value
            tau = cpr/c;                % Signal transmission time
            %Calculate the ECEF-position in xyz at time of transmission.
            [xs_, ys_, zs_]=get_satellite_position(eph_t(k),t-tau,1);
            % express satellite position in ECEF frame at time t
            theta = omega_e*tau;        % Earth's rotation in tau seconds
            xs_vec = [cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0; 0 0 1]*[xs_; ys_; zs_];
            %xs_vec = [xs_; ys_; zs_];
            Xs(k,:)= xs_vec';            % Store satellite position
        end
        W=getW(SNR, Xs, posRec, sets);
        % Estimate position from satellite position and estimates
        [x_, b_] = estimate_position(Xs, pr, length(pr), xu, b, 3, 1e-3, W);
        % Update position and bias from estimates
        dx = x_ - xu;
        db = b_ - b;
        xu = x_;
        b = b_;
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Store positions of satellites and observations at time of observation
    % in cell struct
    [~, ~, satIdx_t]=intersect([eph_t(:).sat],[eph(:).sat]);
    for m=1:length(satIdx_t)
        n=satIdx_t(m);
        allSatPos.pos{n}(end+1,:)   = [t Xs(m,:)];
        [az, el, dist]              = ecef2elaz(Xs(m,:), posRec);
        [~,~,dist_est]              = ecef2elaz(Xs(m,:), xu);
        allSatPos.elAz{n}(end+1,:)  = [t, az, el, dist, dist_est];
        obsVec.obs{n}(end+1, :)     = [t obs(m)];
        obsVec.obsAdj{n}(end+1,:)   = [t pr(m)];
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Store the values calculated above
    out.xVec            = [out.xVec; x_];
    out.tVec(end+1)     = t;
    out.bVec            = [out.bVec b];
    out.llaVec          = [out.llaVec; ecef2lla(xu, 'WGS84')];
    out.Hvec{end+1}     = calcH(posRec, Xs); %Calculate the DOP-matrix values
    out.visSV(end+1,:)  = [t length(pr)];
%     %Debugging:
%     if t-out.tVec(1)>=770
%         [az, el, dist] = ecef2elaz(Xs, posRec);
%         pr-dist
%         keyboard
%     end
end
    out.satPos          = allSatPos;
    out.obsVec          = obsVec;
end

function [eph, obs, SNR] = satElevMask(eph, obs, SNR, t, p, elMask)
%Rough elevation mask to remove readings at a low elevation.
%This does not take the clock bias and transmission time into account due
%to the fact of satellite position changing slowly
%IN
% eph, struct[]:    Ephemeris data to calculate position of sv
% obs, double[]:    Observation data at epoch
% t, double:        Time of week [GPST]
% p, double[3]:     Receiver position (rough)
% elMask, double:   Elevation mask threshold [degrees]
%OUT
% eph, struct[]:    Ephemeris data above elMask
% obs, double[]:    Observation corresponding to eph-data
Xs=zeros(length(eph),3);
for k=1:length(eph)
    [xs_, ys_, zs_]     = get_satellite_position(eph(k),t,1);
    Xs(k,:)              = [xs_ ys_ zs_];
end
[~, el]=ecef2elaz(Xs,p);
eph(el<elMask)=[];
obs(el<elMask)=[];
SNR(el<elMask)=[];
end

function W=getW(SNR, Xs, p, sets)
%Weighting scheme for satellite global positioning, described in
%Weighting models for GPS Pseudorange observations forland transportation in urban canyons
%IN:
    % SNR, double[]:    SNR value of sv signal
    % Xs, double[][3]:  Satellite position (ecef)
    % p, double[3]:     Receiver position (ecef)
    % sets, struct:     Simulation settings (use sets.globalPos.weights)
%OUT:
    % W, double[n][n]:  Diagonal matrix with weights
%Note: SNR given in 0.25dB, so is divided by 4

switch sets.globalPos.weights
    case "SNRelev"
        [~, el]=ecef2elaz(Xs, p);
        sigma=10.^(-0.1*SNR/4)./sind(el).^2;
        W=diag(1./sigma);
    case "SNR"
        sigma=10.^(-0.1*SNR/4);
        W=diag(1./sigma);
    case "elev"
        [~, el]=ecef2elaz(Xs, p);
        sigma=sind(el).^2;
        W=diag(sigma);
    otherwise
        W=1;
end     
end
