function [s1 s2 r1 r2]= rSatRawData(path, dist)
%Read the log data containing satellite directions and 
%pseudoranges into a cell-struct.
%IN path, folder name
%OUT satellite data[2], raw data [2]

r1=readRawDataToFile(strcat(path, dist,'1/Raw1.csv'));
r2=readRawDataToFile(strcat(path, dist,'2/Raw1.csv'));
s1=readSatDataToFile(strcat(path, dist,'1/sat.csv'));
s2=readSatDataToFile(strcat(path, dist,'2/sat.csv'));
