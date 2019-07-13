%Vi kör 4 ggr, i N1 och N2, sedan i E1 och E2 och även från ROS
addpath('../estGlobalPosition/')
addpath('../estGlobalPosition/SatsMove/')
addpath('../rSatRawData/')

%%
path="../Logs/Uggleviken0411/";
raw1E=readRawDataToFile(path+"E1/raw1.csv");
raw2E=readRawDataToFile(path+"E2/raw1.csv");
ephE=readEphDataFromFile(path+"/E1/raw2.csv");
%%
x1E=estGlobalPos(raw1E, ephE, 100, 2001);
x2E=estGlobalPos(raw2E, ephE, 100, 2001);
%%
raw1N=readRawDataToFile(path+"N1/raw1.csv");
raw2N=readRawDataToFile(path+"N2/raw1.csv");
ephN=readEphDataFromFile(path+"/N1/raw2.csv");
%%
x1N=estGlobalPos(raw1N, ephN, 1000, 10001);
x2N=estGlobalPos(raw2N, ephN, 1000, 10001);
%%
path="../Logs/";
rawRos=readRawDataFromBagFile(path+"gps_raw-gps-obs.csv");
ephRos=readEphDataFromBagFile(path+"gps_raw-gps-eph.csv");
%%
x1Ros=estGlobalPos(rawRos, ephRos, 100,1501);
%%
path="../Logs/Uggleviken0706/";
gpsData=readtable(strcat(path,'E1/gps.csv'));
raw1E_0706=readRawDataToFile(path+"E1/raw1.csv");
raw2E_0706=readRawDataToFile(path+"E2/raw1.csv");
ephE_0706=readEphDataFromFile(path+"E1/raw2.csv")
%%
x1E_0706=estGlobalPos(raw1E_0706, ephE_0706, 50,2001);
x2E_0706=estGlobalPos(raw2E_0706, ephE_0706, 50,2001);
%%
raw1N_0706=readRawDataToFile(path+"N1/raw1.csv");
raw2N_0706=readRawDataToFile(path+"N2/raw1.csv");
ephN_0706=readEphDataFromFile(path+"E1/raw2.csv");
%%
x1N_0706=estGlobalPos(raw1N_0706, ephN_0706, 50, 2001);
x2N_0706=estGlobalPos(raw2N_0706, ephN_0706, 50, 1901);
%% Ta fram data över satelliternas rörelse över himlen vid de givna tillfällena 
% för referens mot datan som finns i https://www.gnssplanning.com/#/settings
posRec=[gpsData.lla_0_(1) gpsData.lla_1_(1), gpsData.lla_2_(1)];
satsMovement(x1N, posRec)