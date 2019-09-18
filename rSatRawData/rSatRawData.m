function [e1, e2, r1 r2]= rSatRawData(path, dist)
%Read the log data containing satellite directions and 
%pseudoranges into a cell-struct.
%IN path, folder name
%OUT raw data [2], eph data[2]

e1=readEphDataFromFile(strcat(path, dist,'1/raw2.csv'));
e2=readEphDataFromFile(strcat(path, dist,'2/raw2.csv'));
r1=readRawDataToFile(strcat(path, dist,'1/raw1.csv'));
r2=readRawDataToFile(strcat(path, dist,'2/raw1.csv'));


