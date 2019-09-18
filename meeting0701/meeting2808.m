%{
Part1:
TEST_ESTIMATE_POSITION:
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

How to run:
1) Load data
2) Create starting positions for receiver and satellites
3) Test the output of the simulations, either testing output or convergence
as specified by providing argument 'convergence'
--------------------------------------------------------------------------
Part 2: Relative position histograms from internal solution.
Plots histogram over indivudual estimates, using receiver 1 as reference 
position x0, as well as histogram over distance between estimated position 
between receivers. This is based on sampling estimates directly from
receiver, meaning that the position is at all times given by receiver
--------------------------------------------------------------------------
Part 3: Test magnitude between theoretical distance receiver<-->satellite
and measured. 
--------------------------------------------------------------------------
Part 4: Test Delta P over time for double differentiated satellite
measurements

Values of the distance between receivers should be in the range ±10 m
If values wa



%}
%% Load Data
addpath('../estGlobalPosition/')
addpath('../estGlobalPosition/SatsMove/')
addpath('../data');
addpath('../Simulations/GlobalPosEstimate')
load allLogData.mat
load allEstPos.mat
%% Create the starting position and satellite positions 
%Positions of satellites and receivers
in.pRec=[gpsData0706.ecef_0_(1) gpsData0706.ecef_1_(1) gpsData0706.ecef_2_(1)];
eph=ephE;
pSat=satPositions(eph, 0);
[~,elev]=ecef2elaz(pSat,in.pRec);
in.pSat=pSat(elev>10,:);
in.eph=eph(elev>10);
in.pSat=pSat(1:4,:);
in.eph=eph(1:4);
clearvars elev pSat eph;
%Error terms to be included in the simulations
in.eps.satPos=0; in.eps.recPos=0; in.eps.clockB=0; in.eps.gauss=0; in.eps.timeErr=0;
%% Testing the output of the simulations for different levels of input noise
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
%in.noise='recPos';
%test_estimate_position(in);
% Gaussian noise
in.noise='gauss';
test_estimate_position(in);
%% Testing the convergence of the simulations for different levels of input noise
% No noise 
in.noise='noiseless';
test_estimate_position(in, 'convergence', 1e-8);
% Receiver clock error
in.noise='clockB';
test_estimate_position(in,'convergence');
% Satellite position error (gaussian)
in.noise='satPos';
test_estimate_position(in,'convergence');
% Satellite position error (time conversion)
in.noise='clockErr';
test_estimate_position(in,'convergence');
% Receiver position error
%in.noise='recPos';
%test_estimate_position(in,'convergence');
% Gaussian noise
in.noise='gauss';
test_estimate_position(in,'convergence');
% Mixed noise in receiver position and clock bias
in.noise='mixedNoise';
test_estimate_position(in,'convergence', 1e-8);

%% Part 2: New plots over relative position from internal solution
%This plots the histogram of positions with rec1 as reference position p_0, 
%as well as the histogram of relative position between receivers.
close all
log_path='../Logs/Uggleviken0706';
%True distance between receivers
trueD=10; 
%True direction between receivers
direction='E';
%Logs to use for calculations
T1=strcat(log_path,'/',direction,'1/gps.csv');
T2=strcat(log_path,'/',direction,'2/gps.csv');
plotInternalSolution(T1,T2, trueD, direction, false);
direction='N';
T1=strcat(log_path,'/',direction,'1/gps.csv');
T2=strcat(log_path,'/',direction,'2/gps.csv');
plotInternalSolution(T1,T2, trueD, direction, false);
%% Part 3:
addpath('SatsMove/')
addpath('../data');
load allLogData.mat %Contains the raw log data organized in structs
load allEstPos.mat %Contains the positional estimate calculations already made
% Step 2 compute the position based on the observation and ephmeris data
% 
%true position given by pRec as internal solution of E1_0706
pRec=[gpsData0706.ecef_0_(1) gpsData0706.ecef_1_(1) gpsData0706.ecef_2_(1)];
%Following 5 versions are run, using the input argument i
%   V1: No clock bias is taken into account, but clock bias is estimated 
% from minimizing value of |y-y_hat| (y: observation, y_hat: expected observation |p-p_rec|)
%   V2: Satellite clock bias is estimated and taken into account (added)
%   V3: Receiver clock bias is taken into account
%   V4: Satellite and receiver clock bias is taken into account
%   V5: Satellite position is estimated over long time and compared to
%   observation.
for i=1:5
compare_obs_sat_pos(raw1E_0706,ephE_0706,pRec, i);
end

%% Part 4 
%Compute relative position from observation data and own 
%calculation of satellite position
%% Read data from logfiles
dir =' N'; addpath rSatRawData\;
path="Logs/";
date="Uggleviken0706/";
[sat1 sat2 raw1 raw2] = rSatRawData(path+date,"N");
%%

% Calculate distance from pseudorange measurements
%IN satellite data[2], raw data[2]
%OUT pseudo range distance between reciever ab, unit vector to satellites
addpath estDFromPr\;
[D u]                 = estDFromPr(sat1,sat2, raw1, raw2, sets);

% Estimate the relative position from the pr-measurements
%Optimal solution calculated as inv(H'H)H'D for (x,y,z)
%IN pseudorange distance, directions to satellites
%OUT time since start, distance in xyz, clock-drift over time

addpath optimalSolPr\;
'optimalSol'
[tVec, r_ab, res, Sigma]         = optimalSolPr(D,u, sets); 

% Plot the results 
plotResultPr(r_ab,tVec, res, Sigma, dir, sets)

