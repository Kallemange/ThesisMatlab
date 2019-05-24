%Estimate global position from raw data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The principal trajectory comes from almanac data. Given a certain t0 from
% the almanac data, the current t is passed as argument
% TODO: In addition to that, epehmeris data is broadcasted for more precise
% positioning from the individual satellites. 
%
%
% MAIN:
% The global position of the user is calculated through least squares
% solution of the pseudorange measurement and the calculated positions 
% of the sv at time t.
% 
% 
% ISSUES:
% Problem: must match the time of receiver UNIX-time to that of local start
% time. The raw-measurement time stamp is given in seconds since 1970 (Jan 1
% assumed). The value can be converted to date-time using
% t0=datetime(1554985528,'ConvertFrom','posixtime'), (equal to [2019 4 11 12 25 28]);
% s=UTC2GPStime(t0)
% Where s is seconds of week, as used by GPS system. The difference between
% s and the value of sat (gps_sat_t) is ~17s, which can be explained with
% the GPS leap seconds introduced and should be compensated for.

t0r=datetime(raw1(1).ToW,'ConvertFrom','posixtime');
start_time=[t0r.Year, t0r.Month, t0r.Day, t0r.Hour, t0r.Minute, floor(t0r.Second)];

[~, s]=UTC2GPStime(start_time);
%Adjust for leap seconds ~(-17) s
start_time(end)=start_time(end)+17;
s=s-17;
almanac_data=Get_almanac_data(start_time);
%Get the time of applicability for this almanac
almT0=almanac_data(4);
%Get the satellite ID's
svID=almanac_data(1,:);
[M N]=size(almanac_data);
%%
t=almT0+[0:1:100];
L=length(t);
rec1=repmat(g2r('N',59,'E',18,0), 1,L);
rec2=rec1+1000*[ones(1,L); zeros(2, L)];
[M N]=size(almanac_data);
sat=almanac_data(1,:)';
%SNR=100*ones(length(sat), 1);
raw1=[]; raw2=[];
raw1.ToW=0; raw1.numSats=0; raw1.data=table(1);
raw2.ToW=0; raw2.numSats=0; raw2.data=table(1);
raw1=makeRawLog(almanac_data, L, rec1, sat, t, N);
raw2=makeRawLog(almanac_data, L, rec2, sat, t, N);
 
sat1=[]; sat2=[];
sat1.ToW=0; sat1.numSats=0; sat1.data=table(1);
sat2.ToW=0; sat2.numSats=0; sat2.data=table(1);
sat1=makeSatLog(almanac_data, L, rec1, sat, t, N);
sat2=makeSatLog(almanac_data, L, rec2, sat, t, N);
