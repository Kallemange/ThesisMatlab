%{
Meeting 28/8
Verifiera beteendet hos estimate_position.m mha simuleringar, i 3 steg
1) Helt utan fel
2) Fel i mottagarposition
3) Klockfel (ms)
4) Fel i beräknad satellitposition (parameter/algoritmfel)
5) Fel i beräknad satellitposition (klockfel UNIX->ToW conversion)

Kolla konvergens baserat på olika fel i indata och plotta
%}
%%
addpath('../estGlobalPosition/')
addpath('../estGlobalPosition/SatsMove/')
addpath('../data');
addpath('../Simulations/GlobalPosEstimate')
load allLogData.mat
load allEstPos.mat
%%
c=physconst('lightspeed');

%Error terms to be included in the simulations
eps.satPos=0; eps.recPos=0; eps.clockB=0; eps.gauss=0;
%Positions of satellites and receivers
pRec=[gpsData0706.ecef_0_(1) gpsData0706.ecef_1_(1) gpsData0706.ecef_2_(1)];
pSat=satPositions(ephE, 0);
%%
figure(1)
posError=[]; bError=[];
%Receiver clock error 
for i=0.001:-0.000002:0
    eps.clockB=c*i;
    pEst=test_estimate_position(pRec,pSat, eps);
    posError(end+1)=norm(pRec-pEst);
    bError(end+1)=eps.clockB;
end
eps.clockB=0;
plot(bError/c*1000,posError)
title("Error in position estimate as function of error in receiver clocktime")
xlabel("clock error [ms]")
ylabel("|true position-estimated position|")
%%
figure(2)
posError=[]; posNoise=[];
for i=[1:100 100:100:10000]
    eps.recPos=i;
    pEst=test_estimate_position(pRec,pSat,eps);
    posError(end+1)=norm(pRec-pEst);
    posNoise(end+1)=eps.recPos;
end
plot(posNoise, posError)