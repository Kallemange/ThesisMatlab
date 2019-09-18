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
raw1N=readRawDataToFile(path+"N1/raw1.csv");
raw2N=readRawDataToFile(path+"N2/raw1.csv");
ephN=readEphDataFromFile(path+"/N1/raw2.csv");
%%
path="../Logs/";
rawRos=readRawDataFromBagFile(path+"gps_raw-gps-obs.csv");
ephRos=readEphDataFromBagFile(path+"gps_raw-gps-eph.csv");
%%
path="../Logs/Uggleviken0706/";
gpsData=readtable(strcat(path,'E1/gps.csv'));
raw1E_0706=readRawDataToFile(path+"E1/raw1.csv");
raw2E_0706=readRawDataToFile(path+"E2/raw1.csv");
ephE_0706=readEphDataFromFile(path+"E1/raw2.csv")

%%
raw1N_0706=readRawDataToFile(path+"N1/raw1.csv");
raw2N_0706=readRawDataToFile(path+"N2/raw1.csv");
ephN_0706=readEphDataFromFile(path+"E1/raw2.csv");