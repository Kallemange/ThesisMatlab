function [r1, r2]=rRawData(path)
r1=readRawDataToFile(path+"1/raw1.csv");
r2=readRawDataToFile(path+"2/raw1.csv");
end