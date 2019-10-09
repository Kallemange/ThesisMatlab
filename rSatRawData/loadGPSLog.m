function [gps1, gps2, p1, p2]=loadGPSLog(path)
if isfile(path+"1/gps.csv")
    gps1=readtable(path+"1/gps.csv");
    gps2=readtable(path+"2/gps.csv");
    p1=mean([gps1.ecef_0_ gps1.ecef_1_ gps1.ecef_2_]);
    p2=mean([gps2.ecef_0_ gps2.ecef_1_ gps2.ecef_2_]);
else
    gps1=readtable(path+"1/ins.csv");
    gps2=readtable(path+"2/ins.csv");
    p1=mean(lla2ecef([gps1.lla0 gps1.lla1 gps1.lla2], 'WGS84'));
    p2=mean(lla2ecef([gps2.lla0 gps2.lla1 gps2.lla2], 'WGS84'));
end