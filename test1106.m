path1="Logs/1106_133954";
path2="Logs/1106_133956";
e1=readEphDataFromFile(path1+"/raw2.csv");
r1=readRawDataToFile(path1+"/raw1.csv");
e2=readEphDataFromFile(path2+"/raw2.csv");
r2=readRawDataToFile(path2+"/raw1.csv");

x1=estGlobalPos(r1, e1, sets);
x2=estGlobalPos(r2, e2, sets);
g1=readtable(path1+"/gps.csv");
g2=readtable(path2+"/gps.csv");
%%
figure
for i=1:3
    subplot(3,1,i)
    plot(x1.xVec(:,i)-mean(x1.xVec(:,i)))
    hold on
    plot(x2.xVec(:,i)-mean(x1.xVec(:,i)))
    plot(g1.ToWms/1000-g1.ToWms(1)/1000, g1.("ecef_"+num2str(i-1)+"_")-mean(x1.xVec(:,i)))
    plot(g2.ToWms/1000-g2.ToWms(1)/1000, g2.("ecef_"+num2str(i-1)+"_")-mean(x1.xVec(:,i)))
end
%%
for i=1:3
    subplot(3,1,i)
    plot(x1.llaVec(:,i)-mean(x1.llaVec(:,i)))
    hold on
    plot(x2.llaVec(:,i)-mean(x1.llaVec(:,i)))
    plot(g1.ToWms/1000-g1.ToWms(1)/1000, g1.("lla_"+num2str(i-1)+"_")-mean(x1.llaVec(:,i)))
    plot(g2.ToWms/1000-g2.ToWms(1)/1000, g2.("lla_"+num2str(i-1)+"_")-mean(x1.llaVec(:,i)))
end
%%
[g1t, g2t]=matchRecTimeGPS(gps1,gps2);
dpGPS=  [gps1.ecef_0_(g1t) gps1.ecef_1_(g1t) gps1.ecef_2_(g1t)]-...
        [gps2.ecef_0_(g2t) gps2.ecef_1_(g2t) gps2.ecef_2_(g2t)];
plot(vecnorm(abs(dpGPS),2,2)-10)