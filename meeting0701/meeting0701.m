%% Step 1 Load data to memory
addpath('../estGlobalPosition/')
addpath('../estGlobalPosition/SatsMove/')
addpath('../data');
load allLogData.mat
load allEstPos.mat
%% Step 2 Do the calculations (optional, if any calculation is rerun)
% Positional estimate from the data contained in the logs
% Run either of the versions available in the logs
%estGlobalPos([log data], [ephemeris data], [step length (default=5)],[# iterations (default=all)])

x1E=estGlobalPos(raw1E, ephE);
x2E=estGlobalPos(raw2E, ephE);
%%
x1N=estGlobalPos(raw1N, ephN);
x2N=estGlobalPos(raw2N, ephN);
%%
x1Ros=estGlobalPos(rawRos, ephRos);
%%
x1E_0706=estGlobalPos(raw1E_0706, ephE_0706);
x2E_0706=estGlobalPos(raw2E_0706, ephE_0706);
%%
x1N_0706=estGlobalPos(raw1N_0706, ephN_0706);
x2N_0706=estGlobalPos(raw2N_0706, ephN_0706);
%% Step 3 Plot the satellite trajectories
% Ta fram data �ver satelliternas r�relse �ver himlen vid de givna tillf�llena 
% f�r referens mot datan som finns i https://www.gnssplanning.com
% Samtliga motsvarande inst�llningar finns i gnssplanning.txt
posRec=[gpsData0706.lla_0_(1) gpsData0706.lla_1_(1), gpsData0706.lla_2_(1)];
posRecECEF=[gpsData0706.ecef_0_(1) gpsData0706.ecef_1_(1), gpsData0706.ecef_2_(1)];
%V�lj vilken logg som skall anv�ndas
satsMovement(x1E, posRec, posRecECEF, eph1E(1).week)
