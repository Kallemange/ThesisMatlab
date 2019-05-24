%% Create sat and raw data from almanac data for a user defined path

t0s=sat1(1).ToW;
t0r=datetime(raw1(1).ToW,'ConvertFrom','posixtime');
%t0r=datetime(1552030199,'ConvertFrom','posixtime');
start_time=[t0r.Year, t0r.Month, t0r.Day, t0r.Hour, t0r.Minute, floor(t0r.Second)];
%start_time=[2019 04 08 07 30 0];

[satPos, satID, tSat, almT0]=Orbit(start_time);
almT0=str2double(almT0);
t0=find(almT0+t<sat1(1).ToW, 1, 'last');
%%
%Create a stationary position
tRec=0:0.2:3600;

Rec1_ecef=g2r('N',59,'E',18,0);
Rec1_ecef=repmat(Rec1_ecef,1, length(tRec));
%Create another position moving around 1st
Rec2_ecef=Rec1_ecef+10*[sind(tRec); cosd(tRec); zeros(1, length(tRec))]+0.1*randn(3,length(tRec));
%%
% Create the distance between receivers and satellites
for i=1:length(tRec)
   [trueD, trueE, trueA]=RangeandAngle(satPos, Rec1_ecef, tRec(i), tSat,i);
end