%My testing of this implementation with own data

close all, clear all, clc
%% Load data
disp('Loads data')
load('GNSSaidedINS_data.mat');

%% Load filter settings
disp('Loads settings')
settings=get_settings();

%% Run the GNSS-aided INS
disp('Runs the GNSS-aided INS')
T=readtable('20190214_160038\LOG_SN34072_20190214_160038_0001_ins1.csv');
T1=readtable('20190214_160038\LOG_SN34072_20190214_160038_0001_preintegratedImu.csv');
out_data=GPSaidedINS(in_data,settings);

%% Plot the data 
disp('Plot data')
plot_data(in_data,out_data);




