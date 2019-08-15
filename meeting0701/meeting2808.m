%{
Meeting 28/8
Verifiera beteendet hos estimate_position.m mha simuleringar, i 3 steg
1) Helt utan fel
2) Fel i mottagarposition
3) Klockfel (ms)
4) Fel i beräknad satellitposition (slumpfel parameter/algoritmfel)
5) Fel i beräknad satellitposition (klockfel UNIX->ToW conversion)

Kolla konvergens baserat på olika fel i indata och plotta KLAR

Skall kolla hur konvergensen ser ut vid olika indata KLAR

For a given type of input noise, an error will be produced in the output
data. The behaviour is plotted in two kinds of graphs, investigating the
error in position estimate and clock bias estimate.
    1) How the error changes with an increasing error in input of given
    noise type, as well as the clock bias estimate.
    2) How the solution converges per iteration for both position and clock
    bias estimate.

%}
%%
addpath('../estGlobalPosition/')
addpath('../estGlobalPosition/SatsMove/')
addpath('../data');
addpath('../Simulations/GlobalPosEstimate')
load allLogData.mat
load allEstPos.mat
%% Testing the output of the simulations for different levels of input noise
%Error terms to be included in the simulations
in.eps.satPos=0; in.eps.recPos=0; in.eps.clockB=0; in.eps.gauss=0; in.eps.timeErr=0;
%Positions of satellites and receivers
in.pRec=[gpsData0706.ecef_0_(1) gpsData0706.ecef_1_(1) gpsData0706.ecef_2_(1)];
in.eph=ephE;
in.pSat=satPositions(in.eph, 0);
%%
% No noise 
in.noise='noiseless';
test_estimate_position(in);
% Receiver clock error
in.noise='clockB';
test_estimate_position(in);
% Satellite position error (gaussian)
in.noise='satPos';
test_estimate_position(in);
% Satellite position error (time conversion)
in.noise='clockErr';
test_estimate_position(in);
% Receiver positon error
in.noise='recPos';
test_estimate_position(in);
% Gaussian noise
in.noise='gauss';
test_estimate_position(in);
%% Testing the convergence of the simulations for different levels of input noise
in.eps.satPos=0; in.eps.recPos=0; in.eps.clockB=0; in.eps.gauss=0; in.eps.timeErr=0;
%Positions of satellites and receivers
in.pRec=[gpsData0706.ecef_0_(1) gpsData0706.ecef_1_(1) gpsData0706.ecef_2_(1)];
in.eph=ephE;
in.pSat=satPositions(in.eph, 0);

% No noise 
in.noise='noiseless';
test_estimate_position(in, 'convergence');
% Receiver clock error
in.noise='clockB';
test_estimate_position(in,'convergence');
% Satellite position error (gaussian)
in.noise='satPos';
test_estimate_position(in,'convergence');
% Satellite position error (time conversion)
in.noise='clockErr';
test_estimate_position(in,'convergence');
% Receiver positon error
in.noise='recPos';
test_estimate_position(in,'convergence');
% Gaussian noise
in.noise='gauss';
test_estimate_position(in,'convergence');