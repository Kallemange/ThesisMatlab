%Position from IMU-data, attempt at estimating position from data collected
%by IMU-sensors
clear all, close all
%T1=readtable('20190214_160038\LOG_SN34090_20190214_160038_0001_gps1Pos.csv');
%T2=readtable('20190214_160038\LOG_SN34072_20190214_160038_0001_gps1Pos.csv');
T1=readtable('20190214_160038\LOG_SN34072_20190214_160038_0001_preintegratedImu.csv');
T2=readtable('20190214_160038\LOG_SN34072_20190214_160038_0001_preintegratedImu.csv');
%%
posFromIMU(T1,T2, 1)
