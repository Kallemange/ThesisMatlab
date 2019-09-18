function compare_obs_sat_pos(raw,eph, pRec, version)
%COMPARE_OBS_SAT_POS 
%Comparison between observation and estimated distance between sat<->rec.
%in three versions: 
%   V1: No clock bias is taken into account, but clock bias is estimated 
% from minimizing value of |y-y_hat| 
% (y: observation, y_hat: expected observation |p-p_rec|
%
%   V2: Satellite clock bias is estimated and taken into account (added)
%
%   V3: Receiver clock bias is taken into account
%
%   V4: Satellite and receiver clock bias is taken into account
%
%   V5: Satellite position is estimated over long time and compared to
%   observation.
%}
%IN:
% raw, struct[]:        struct array containing raw observation data
% eph, struct[]:        struct array containing ephemeris data
% pRec, double[3]:      position in ECEF from internal solution (considered true)
% version, int:         Which version of the plots to show (as described above)
%OUT: 
% N/A

%Time vector
T=1:100;
eph=eph([eph.sat]<=32);
switch version
    case 1
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Version 1:
        estSatClockB=0;
        calculateDist(raw, eph,pRec,T,version,estSatClockB);
        figure(1)
        sgtitle([{"Difference between observation and estimated distance sv<->rec"},{"without any adjustments"}])
        xlabel("Time [s] since startup")
        ylabel("y-|p_{sat}-p_{rec}|", 'Interpreter', 'latex');
    case 2
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Version 2:
        estSatClockB=1;
        calculateDist(raw, eph,pRec,T,version,estSatClockB);
        figure(2)
        sgtitle([{"Difference between observation and estimated distance sv<->rec"},{"adjusting for sv clock bias"}])
        xlabel("Time [s] since startup")
        ylabel("y-|p_{sat}-p_{rec}|", 'Interpreter', 'latex');
    case 3
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Version 3:
        figure(3)
        estSatClockB=0;
        estRecClockB=1;
        calculateDist(raw, eph,pRec,T,version,estSatClockB, estRecClockB);
        sgtitle([{"Difference between observation and estimated distance sv<->rec"},...
            {"adjusting for rec clock bias"}])
        xlabel("Time [s] since startup")
        ylabel("y-|p_{sat}-p_{rec}|", 'Interpreter', 'latex');
    case 4
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Version 4:
        figure(4)
        estSatClockB=1;
        estRecClockB=1;
        pres=1e-6;
        calculateDist(raw, eph,pRec,T,version,estSatClockB, estRecClockB, pres);
        sgtitle([{"Difference between observation and estimated distance sv<->rec"},...
            {"adjusting for satellite and rec clock bias"}])
        xlabel("Time [s] since startup")
        ylabel("y-|p_{sat}-p_{rec}|", 'Interpreter', 'latex');
    case 5
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Version 5:
        figure(5)
        calcDistOverTime(raw,eph,pRec,T,version);
        
end

end

function calculateDist(raw, eph,pRec, T, version, estSatClockBias, estRecClockBias, pres)
c=physconst('lightspeed');
if nargin<8
    pres=1e-3;
end
if nargin<7
    estRecClockBias=0;
end
if nargin<6
    estSatClockBias=0;
end
figure(version)
hold on
errorVec=cell(size(eph));
allSats=[eph.sat];
[~, t0]=UTC_in_sec2GPStime(raw(1).ToW);
for i=T
    raw_t=raw(i);
    %Skip any observation where noSats<4 since they cant be used
    if length(raw_t.data.sat)<4
        continue
    end
    [~, iR, iE]=intersect([raw_t.data.sat], [eph.sat]);
    [~, t]=UTC_in_sec2GPStime(raw_t.ToW);
    eph_t=eph(iE);
    sats=[eph_t.sat];
    Xs=zeros(length(eph_t),3);
    for j=1:length(eph_t)
        [x, y, z]=get_satellite_position(eph_t(j),t-500);
        Xs(j,:)=[x y z];
    end
    %Calculated distance sv<-->rec
    dist=vecnorm(pRec-Xs,2,2);
    %Measured pseudorange
    obs=raw_t.data.P(iR);
    %Adjust for satellite clock bias
    dsv=zeros(size(eph_t));
    if estSatClockBias
        for j=1:length(eph_t)
            dsv(j) = estimate_satellite_clock_bias(t, eph_t(j));   
        end
        obs=obs+dsv'*c;
    end
    if estRecClockBias
        b0=0;
        [x, b]=estimate_position(Xs, obs, length(obs),pRec, b0, 3, pres);
        obs=obs+b;
    end
    err_t=obs-dist;
    for k=1:length(sats)
        [~, idx]=find(allSats==sats(k));
        errorVec{idx}(:,end+1)=[t err_t(k)];
    end
end
    for i=1:length(errorVec)
        if ~isempty(errorVec{i})
            plot(errorVec{i}(1,:)-t0, errorVec{i}(2,:))
        else
            allSats(i)=[];
        end
    end
    leg=legend(num2str(allSats'));
    title(leg,"svID")
end

function calcDistOverTime(raw, eph,pRec, T, version)
    figure(version)
    hold on
    errVec=[];
    allSats=[eph.sat];
    [~, t0]=UTC_in_sec2GPStime(raw(1).ToW);
    i=T(end);
    raw_t=raw(i);
    %Skip any observation where noSats<4 since they cant be used
    
    [~, iR, iE]=intersect([raw_t.data.sat], [eph.sat]);
    [~, t]=UTC_in_sec2GPStime(raw_t.ToW);
    eph_t=eph(iE);
    sats=[eph_t.sat];
    obs=raw_t.data.P(iR);
    Xs=zeros(length(eph_t),3);
    for j=-500:500
        for k=1:length(eph_t)
            [x, y, z]=get_satellite_position(eph_t(k),t+j);
            Xs(k,:)=[x y z];
        end
        dist=vecnorm(Xs-pRec,2,2);
        errVec(:,end+1)=obs-dist;
       
    end
   
    for i=1:11
        plot(-500:500,errVec(i,:))
    end
    ylabel("obs-|p-p_{rec}|", 'Interpreter', 'latex')
    xlabel("time shift [s]")

end