% Data from EvalTool 
%Taking readings from the GPS-data mainly (ins1/gps1Pos)
%Stationary tests
%Testing different distances, static positions after movement approximately at:
% 25 cm
% 1 m
% 3 m
% 5 m
% 8.4 m
%Horizontal separation, vertical <10cm.
clear all, close all
T11=readtable('20190214_155011\LOG_SN34072_20190214_155011_0001_ins1.csv');
T12=readtable('20190214_155011\LOG_SN34072_20190214_155011_0002_ins1.csv');
T13=readtable('20190214_155011\LOG_SN34072_20190214_155011_0003_ins1.csv');
% T11=readtable('20190214_155011\LOG_SN34072_20190214_155011_0001_preintegratedImu.csv');
% T12=readtable('20190214_155011\LOG_SN34072_20190214_155011_0002_preintegratedImu.csv');
% T13=readtable('20190214_155011\LOG_SN34072_20190214_155011_0003_preintegratedImu.csv');
T1=[T11;T12;T13];
T21=readtable('20190214_155011\LOG_SN34090_20190214_155011_0001_ins1.csv');
T22=readtable('20190214_155011\LOG_SN34090_20190214_155011_0002_ins1.csv');
T23=readtable('20190214_155011\LOG_SN34090_20190214_155011_0003_ins1.csv');
% T21=readtable('20190214_155011\LOG_SN34090_20190214_155011_0001_preintegratedImu.csv');
% T22=readtable('20190214_155011\LOG_SN34090_20190214_155011_0002_preintegratedImu.csv');
% T23=readtable('20190214_155011\LOG_SN34090_20190214_155011_0003_preintegratedImu.csv');
T2=[T21; T22; T23];
%%
plotAngles(T1, T2, 1);
relativeGPSPos(T1,T2, 'lla');

%%
plot3(T1.ned_0_, T1.ned_1_, T1.ned_2_)
view(2)
hold on
plot3(T2.ned_0_, T2.ned_1_, T2.ned_2_)
%%
plot3(T1.lla_0_,T1.lla_1_, T1.lla_2_)
view(2)
hold on
plot3(T2.lla_0_,T2.lla_1_, T2.lla_2_)
%% Testing walk around a square
clear all, close all
%T1=readtable('20190214_160038\LOG_SN34090_20190214_160038_0001_gps1Pos.csv');
%T2=readtable('20190214_160038\LOG_SN34072_20190214_160038_0001_gps1Pos.csv');
T1=readtable('20190214_160038\LOG_SN34090_20190214_160038_0001_ins1.csv');
T2=readtable('20190214_160038\LOG_SN34072_20190214_160038_0001_ins1.csv');

relativeGPSPos(T1,T2, 'lla');
subplot(311)
plot(T1.timeOfWeek - T1.timeOfWeek(1), T1.ned_0_)
hold on
plot(T2.timeOfWeek- T1.timeOfWeek(1), T2.ned_0_)
ax1 = gca

subplot(312)
plot(T1.timeOfWeek- T1.timeOfWeek(1), T1.ned_1_)
hold on
plot(T2.timeOfWeek- T1.timeOfWeek(1), T2.ned_1_)
ax2 = gca

subplot(313)
plot(T1.timeOfWeek- T1.timeOfWeek(1), T1.ned_2_)
hold on
plot(T2.timeOfWeek- T1.timeOfWeek(1), T2.ned_2_)
ax3 = gca

linkaxes([ax1 ax2 ax3])

%%

T1=readtable('20190214_160038\LOG_SN34072_20190214_160038_0001_preintegratedImu.csv');
T2=readtable('20190214_160038\LOG_SN34090_20190214_160038_0001_preintegratedImu.csv');
%%
plotAngles(T1,T2,1);

%%
posFromIMU(T1,T2, 1)


