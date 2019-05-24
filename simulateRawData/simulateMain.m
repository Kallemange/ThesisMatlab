function [sat1, sat2, raw1, raw2]=simulateMain(t0raw, sets)
%Main file, reimplement the double difference (DD) without time stamps
%t0r=datetime(raw1(1).ToW,'ConvertFrom','posixtime');
t0r=datetime(t0raw,'ConvertFrom','posixtime');
start_time=[t0r.Year, t0r.Month, t0r.Day, t0r.Hour, t0r.Minute, floor(t0r.Second)];
[~, s]=UTC2GPStime(start_time);
%Adjust for leap seconds ~(-17) s
start_time(end)=start_time(end)+17;
s=s-17;
%Should load through the actual function for latest almanac, here we just
%load a saved almanac in order to make less requests for data from website
%almanac_data=Get_almanac_data(start_time);
load almanac.mat
%Get the time of applicability for this almanac
almT0=almanac_data(4);
%Get the satellite ID's
svID=almanac_data(1,:);
[M N]=size(almanac_data);

almT0=almanac_data(4);
%Get the satellite ID's
t=almT0+sets.sim.t;
L=length(t);
rec1=repmat(g2r('N',59,'E',18,0), 1,L);
rec2=rec1+sets.sim.dist*[ones(1,L); zeros(2, L)];

[M N]=size(almanac_data);
sat=almanac_data(1,:)';
%SNR=100*ones(length(sat), 1);
raw1=[]; raw2=[];
raw1.ToW=0; raw1.numSats=0; raw1.data=table(1);
raw2.ToW=0; raw2.numSats=0; raw2.data=table(1);
sets.noise.sysNoiseVec=sets.noise.sysNoise(N, L);

raw1=makeRawLog(almanac_data, L, rec1, sat, t, N, sets);
sets.sim.clockError=0;
sets.sim.t=sets.sim.skipT(sets.sim.t);
raw2=makeRawLog(almanac_data, L, rec2, sat, t, N, sets);
 
sat1=[]; sat2=[];
sat1.ToW=0; sat1.numSats=0; sat1.data=table(1);
sat2.ToW=0; sat2.numSats=0; sat2.data=table(1);
sat1=makeSatLog(almanac_data, L, rec1, sat, t, N, sets);
sat2=makeSatLog(almanac_data, L, rec2, sat, t, N, sets);

%[xVec2, b2]=globalEstFromRaw(raw2, s, almanac_data);

% plot3(xVec1(:,1), xVec1(:,2), xVec1(:,3), '*')
% %%
% t=[0:100:2*(11*60*60+58*60)];
% Rec_pos_ecef=g2r('N',59,'E',18,0);
% [M N]=size(almanac_data);
% figure
% hold on
% for k=1:N
%     for n=1:length(t)
%     [pos_ECEF(:,n), pos(:,n)] = Sat_pos(almanac_data(:,k),t(n));
%     end
%     [Range elev, azim]        = RangeandAngle(pos_ECEF, Rec1_pos_ecef);
% end
% 
% 
% t0r=datetime(raw1(1).ToW,'ConvertFrom','posixtime');
% start_time=[t0r.Year, t0r.Month, t0r.Day, t0r.Hour, t0r.Minute, floor(t0r.Second)];
% 
% [~, s]=UTC2GPStime(start_time);
% %Adjust for leap seconds ~(-17) s
% start_time(end)=start_time(end)+17;
% s=s-17;
% almanac_data=Get_almanac_data(start_time);
%Get the time of applicability for this almanac