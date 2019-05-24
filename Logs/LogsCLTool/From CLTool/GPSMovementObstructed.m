%% Show relative GPS-positioning, with first
clear all
close all
T2=readtable('log3/LOG_SN34090_20190207_155313_0001_gps1Pos.csv');
T1=readtable('log4/LOG_SN34072_20190207_155311_0001_gps1Pos.csv');
relativeGPSPos(T1,T2);

%% Relative position from IMU data in translational movements
clear all
T1=readtable('0213/translation1/LOG_SN34090_20190213_091540_0001_preintegratedImu.csv');
T2=readtable('0213/translation2/LOG_SN34072_20190213_091542_0001_preintegratedImu.csv');
close all
t0=300;
posFromIMU(T1,T2, t0)
%plotAngles(T1,T2,t0)

%% Velocity, position and angle from stationary sensors
clear all
close all
T2=readtable('0213/still1/LOG_SN34090_20190213_111610_0001_preintegratedImu.csv');
T1=readtable('0213/still2/LOG_SN34072_20190213_111610_0001_preintegratedImu.csv');
t0=1;
plotAngles(T1,T2,t0)
%posFromIMU(T1,T2,t0)

%% Position and angles when performing 90 degree rotations
clear all
close all
T2=readtable('0213/angles1/preintegratedImuJoined.csv');
T1=readtable('0213/angles2/preintegratedImuJoined.csv');
t0=1000;
plotAngles(T1,T2,t0)
%posFromIMU(T1,T2,t0)



