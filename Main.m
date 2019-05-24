%% Karl Lundin Master thesis project

%% Part1 
%Estimating the relative positions and the drift over time utilizing
%the global positions provided by the sensor
%Several measurements were made, with stationary and moving recievers,
%The relative positional estimates are presented based on the data from the
%IS units own calculations
close all, clear all, clc
%% Measurements from INS-log at stationary 1m
%{
T1=readtable('Uggleviken0312/1m1/Ins.csv');
T2=readtable('Uggleviken0312/1m2/Ins.csv');
%% 
relativeGPSPosINS(T1,T2, 'ned', 1, 1 );
%% Measurements from INS-log at stationary 2m
close all, clear all, clc
T1=readtable('Uggleviken0312/2m1/Ins.csv');
T2=readtable('Uggleviken0312/2m2/Ins.csv');
%%
relativeGPSPosINS(T1,T2, 'lla', 1, 2 );
%% Measurements from INS-log at stationary 7m
close all, clear all, clc
T1=readtable('Uggleviken0312/7m1/Ins.csv');
T2=readtable('Uggleviken0312/7m2/Ins.csv');
%%
relativeGPSPosINS(T1,T2, 'lla', 1, 7);
%% Measurements from INS-log while walking around
close all, clear all, clc
T1=readtable('Uggleviken0312/prom1/Ins.csv');
T2=readtable('Uggleviken0312/prom2/Ins.csv');
%%
relativeGPSPosINS(T1,T2, 'lla', 1, 0.5);
%% Measurements from INS-log with receivers aligned in N-direction
T2=readtable('Uggleviken0327/0327_N1/Ins.csv');
T1=readtable('Uggleviken0327/0327_N2/Ins.csv');
%%
relativeGPSPosINS(T1,T2, 'lla', 1, 1.6);
%% Measurements from INS-log with receivers aligned in E-direction
T2=readtable('Uggleviken0327/0327_E1/Ins.csv');
T1=readtable('Uggleviken0327/0327_E2/Ins.csv');
%%
relativeGPSPosINS(T1,T2, 'lla', 1, 1.6);
%% Measurements from INS-log with receivers aligned in D-direction
T2=readtable('Uggleviken0327/0327_D1/Ins.csv');
T1=readtable('Uggleviken0327/0327_D2/Ins.csv');
%%
relativeGPSPosINS(T1,T2, 'lla', 1, 1.6);
%}
%% Measurements from INS-log with receivers aligned in E-direction 10 m
T2=readtable('Uggleviken0411/E1/Ins.csv');
T1=readtable('Uggleviken0411/E2/Ins.csv');
%%
relativeGPSPosINS(T1,T2, 'ned', 1, 10, 2);
%% Measurements from INS-log with receivers aligned in N-direction 10 m
T2=readtable('Uggleviken0411/N1/Ins.csv');
T1=readtable('Uggleviken0411/N2/Ins.csv');
%%
relativeGPSPosINS(T1,T2, 'lla', 1, 10, 1);
%% Part 2
%Estimating the position of the sensors using the satellite information
%directions, and the pseudorange measurements
close all, clear all, clc
%% From sampling in uggleviken 0312 
%{
[sat1 sat2 raw1 raw2] = rSatRawData('Uggleviken0312/','1m');
%%
[sat1 sat2 raw1 raw2] = rSatRawData('Uggleviken0312/','2m');
%%
[sat1 sat2 raw1 raw2] = rSatRawData('Uggleviken0312/','7m');
%%
[sat1 sat2 raw1 raw2] = rSatRawData('Uggleviken0312/','prom');
%% From sampling in uggleviken 0327 
dir = 'N';
[sat1 sat2 raw1 raw2] = rSatRawData('Uggleviken0327/','0327_N');
%%
dir = 'E';
[sat1 sat2 raw1 raw2] = rSatRawData('Uggleviken0327/','0327_E');
%%
dir =' D';
[sat1 sat2 raw1 raw2] = rSatRawData('Uggleviken0327/','0327_D');
%}
%% Load all data from logfiles
dir =' N'; addpath rSatRawData\;
[sat1 sat2 raw1 raw2] = rSatRawData('Uggleviken0411/','N');
%%
dir =' E'; addpath rSatRawData\;
[sat1 sat2 raw1 raw2] = rSatRawData('Uggleviken0411/','E');
%% Or load them from a .mat file
%Stationary receivers at 10m separation in N or E direction
%load('10mN')
%load('10mE')
dir =' E'; addpath rSatRawData\;
%% My own simulated data
addpath simulateRawData\;
dir='N'
load GPSdata.mat;
trueNED=ref_data.traj_ned;
[sat1 sat2 raw1 raw2] = simulateRawData();
%% Simulated data from real GPS positions
%SimSettings
addpath simulateRawData\;
%addpath gnss_task\;
dir ='N';
t0=1.555058801792000e+09;
[sat1 sat2 raw1 raw2] = simulateMain(t0, sets);
% Calculate distance from pseudorange measurements
%IN satellite data[2], raw data[2]
%OUT pseudo range distance between reciever ab, unit vector to satellites
addpath estDFromPr\;
[D u]                 = estDFromPr(sat1,sat2, raw1, raw2, sets);
% Estimate the relative position from the pr-measurements
%Optimal solution calculated as inv(H'H)H'D for (x,y,z)
%IN pseudorange distance, directions to satellites
%OUT time since start, distance in xyz, clock-drift over time

addpath optimalSolPr\;
[tVec, r_ab, res, Sigma]         = optimalSolPr(D,u, sets); 
% Plot the results 
plotResultPr(r_ab,tVec, res, Sigma, dir, sets)