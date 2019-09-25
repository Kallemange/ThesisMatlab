% Estimate global position using the raw data from observation and
% ephemeris data directly sampled from the satellite receiver

%% Step 1 Load data to memory
addpath('SatsMove/')
addpath('../data');
%load allLogData.mat %Contains the raw log data organized in structs
%load allEstPos.mat %Contains the positional estimate calculations already made
path="Logs/Uggleviken";
date="0706/";
dir="N";
[eph1, eph2, raw1, raw2] = rSatRawData(path+date+dir);

gps1=readtable(path+date+dir+"1/gps.csv");
gps2=readtable(path+date+dir+"2/gps.csv");
%% Step 2 compute the position based on the observation and ephmeris data
% 
% x=estGlobalPos([raw data], [ephemeris data], [step size](default=5), [t_end] (default=all))
% e.g.:
posRec=[59.3529   18.0732   31.9990];
posECEF=lla2ecef(posRec);
x1=estGlobalPos(raw1,eph1);
x2=estGlobalPos(raw2,eph2);
%x1E_0706  = estGlobalPos(raw1E_0706, ephE_0706);
% x1N       = estGlobalPos(raw1N, ephN, 1, 100);
%x1Ros=estGlobalPos(rawRos, ephRos)
%%
figure
for i=1:3
    
    subplot(3,1,i)
    hold on
    plot(x1.tVec,x1.xVec(:,i))
    plot(gps1.ToWms/1000, gps1.("ecef_"+num2str(i-1)+"_"))
    plot(x2.tVec, x2.xVec(:,i));
    plot(gps2.ToWms/1000,    gps2.("ecef_"+num2str(i-1)+"_"))
end
figure
for i=1:3    
    subplot(3,1,i)
    hold on
    plot(x1.llaVec(:,i)-posRec(i))
    plot(x2.llaVec(:,i)-posRec(i));
end
