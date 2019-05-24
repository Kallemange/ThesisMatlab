%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           
% Main script for the loosely-coupled feedback GNSS-aided INS system. 
%  
% Edit: Isaac Skog (skog@kth.se), 2016-09-01,  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all, clear all, clc
%% Load data
disp('Loads data')
load('GNSSaidedINS_data.mat');

%% Load filter settings
disp('Loads settings')
settings=get_settings();

%% Run the GNSS-aided INS
disp('Runs the GNSS-aided INS')
out_data=GPSaidedINS(in_data,settings);

%% Plot the data 
disp('Plot data')
plot_data(in_data,out_data);




