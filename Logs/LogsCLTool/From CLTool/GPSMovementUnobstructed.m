%% Test of GPS-error when in unobstructed terrain and moving around
clear all
T1=readtable('firstTest0211\logMovUnobstructed1\LOG_SN34072_20190211_144841_0001_ins1.csv');
T2=readtable('firstTest0211\logMovUnobstructed2\LOG_SN34090_20190211_144842_0001_ins1.csv');
close all
relativeGPSPos(T1,T2);

%% Test of GPS-error when in unobstructed terrain and standing still
clear all
close all
T3=readtable('firstTest0211\logStill1\LOG_SN34072_20190211_144319_0001_ins1.csv');
T4=readtable('firstTest0211\logStill2\LOG_SN34090_20190211_144321_0001_ins1.csv');

relativeGPSPos(T3,T4);
%plotAngles(T3,T4, 1);
%% Test of GPS-error when in unobstructed terrain and rotating
clear all
close all
T3=readtable('firstTest0211\logRot1\LOG_SN34072_20190211_145031_0001_ins1.csv');
T4=readtable('firstTest0211\logRot2\LOG_SN34090_20190211_145026_0001_ins1.csv');
%relativeGPSPos(T3,T4);
plotAngles(T4,T3, 102);
%% Test of angles 
%Here the angles of the preintegrated IMU-sensors is calculated
clear all, close all
T1=readtable('FirstTest0211\logAngles1\LOG_SN34072_20190211_145135_0001_preintegratedImu.csv');
T2=readtable('FirstTest0211\logAngles2\LOG_SN34090_20190211_145136_0001_preintegratedImu.csv');
plotAngles(T1, T2, 413);

