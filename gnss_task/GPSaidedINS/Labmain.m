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
in_data2=in_data;
in_data2.GNSS.pos_ned(:,261:end)=0;
out_data2=GPSaidedINS(in_data2,settings);

%% Plot the data 
disp('Plot data')
%Here another dataset without the GPS-aid is introduced and is plotted
%together with the original data
%plot_data2(in_data,out_data, out_data2);
plot_data(in_data2,out_data2)



