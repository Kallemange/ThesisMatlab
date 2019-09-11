% Estimate global position using the raw data from observation and
% ephemeris data directly sampled from the satellite receiver

%% Step 1 Load data to memory
addpath('SatsMove/')
addpath('../data');
load allLogData.mat %Contains the raw log data organized in structs
load allEstPos.mat %Contains the positional estimate calculations already made
%% Step 2 compute the position based on the observation and ephmeris data
% 
% x=estGlobalPos([raw data], [ephemeris data], [step size](default=5), [t_end] (default=all))
% e.g.:
x1E_0706  = estGlobalPos(raw1E_0706, ephE_0706);
% x1N       = estGlobalPos(raw1N, ephN, 1, 100);
%x1Ros=estGlobalPos(rawRos, ephRos)