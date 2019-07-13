%% Positional estimate from the data contained in the logs

x1E=estGlobalPos(raw1E, ephE);
x2E=estGlobalPos(raw2E, ephE);
%%
x1N=estGlobalPos(raw1N, ephN, 1000, 10001);
x2N=estGlobalPos(raw2N, ephN, 1000, 10001);
%%
x1Ros=estGlobalPos(rawRos, ephRos);
%%
x1E_0706=estGlobalPos(raw1E_0706, ephE_0706);
x2E_0706=estGlobalPos(raw2E_0706, ephE_0706);
%%
x1N_0706=estGlobalPos(raw1N_0706, ephN_0706);
x2N_0706=estGlobalPos(raw2N_0706, ephN_0706);
%% Ta fram data över satelliternas rörelse över himlen vid de givna tillfällena 
% för referens mot datan som finns i https://www.gnssplanning.com/#/settings
posRec=[gpsData0706.lla_0_(1) gpsData0706.lla_1_(1), gpsData0706.lla_2_(1)];
posRecECEF=[gpsData0706.ecef_0_(1) gpsData0706.ecef_1_(1), gpsData0706.ecef_2_(1)];
satsMovement(x1E_0706, posRec,posRecECEF)