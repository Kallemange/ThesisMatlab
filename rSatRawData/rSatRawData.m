function [e1, e2, r1 r2]= rSatRawData(path)
%Read the log data containing satellite directions and 
%pseudoranges into a cell-struct.
%IN path, folder name
%OUT raw data [2], eph data[2]

e1=readEphDataFromFile(path+"1/raw2.csv");
e2=readEphDataFromFile(path+"2/raw2.csv");
r1=readRawDataToFile(path+"1/raw1.csv");
r2=readRawDataToFile(path+"2/raw1.csv");


