%% Karl Lundin Master thesis project
close all, clear all, clc
%{
Part1:
TEST_ESTIMATE_POSITION:
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
and measured. (Removed)
--------------------------------------------------------------------------
Part 4: Test Delta P over time for double differentiated satellite
measurements
Values of the distance between receivers should be in the range �10 m
If values wa
--------------------------------------------------------------------------
Part 5: Test global position estimate
Estimate the position of the receivers from observation data and
calculations of satellite positions

%}

%% Part 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load Data
SimSettings;
addpath('estGlobalPosition/')
addpath('estGlobalPosition/SatsMove/')
addpath('Simulations/GlobalPosEstimate')
addpath('rSatRawData/')
addpath('Simulations/')
path="Logs/Uggleviken";
date="0411/";
dir="E";
sets.path=path+date+dir;
trueD=10;
[eph1, eph2] = rEphData(path+date+dir);
[raw1, raw2] = rRawData(path+date+dir);
addpath('SatsMove/')
addpath('../data');
addpath("../Logs");
[gps1, gps2, p1, p2]=loadGPSLog(path+date+dir);

%% Create the starting position and satellite positions 
%Positions of satellites and receivers
in.pRec=p1;
eph=eph1;
pSat=satPositions(eph, 0);
[~,elev]=ecef2elaz(pSat,in.pRec);
in.pSat=pSat(elev>sets.optSol.elMask,:);
in.eph=eph(elev>sets.optSol.elMask);
in.pSat=pSat(1:4,:);
in.eph=eph(1:4);
clearvars elev pSat eph;
%Error terms to be included in the simulations
in.eps.satPos=0; in.eps.recPos=0; in.eps.clockB=0; in.eps.gauss=0; in.eps.timeErr=0;
%% Testing the output of the simulations for different levels of input noise
% No noise 
run_test_estimate_position(in)

%% Part 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%New plots over relative position from internal solution
%This plots the histogram of positions with rec1 as reference position p_0, 
%as well as the histogram of relative position between receivers.
plotInternalSolution(gps1,gps2, trueD, dir, false);

%% Part 4 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compute relative position from observation data and own 
%calculation of satellite position

% Calculate distance from pseudorange measurements
%IN satellite data[2], raw data[2]
%OUT pseudo range distance between reciever ab, unit vector to satellites
addpath estDFromPr\;
[t1raw, ~, t0r]     = findFirstLast(raw1, raw2);
D                   = calcDiffPr(raw1,raw2,t1raw, sets);

% Estimate the relative position from the pr-measurements
%Optimal solution calculated as r=(H'*W*H)\H'*W*D for (x,y,z)
%IN pseudorange distance, directions to satellites
%OUT time since start, distance in xyz, clock-drift over time
addpath optimalSolPr\;
[tVec, r_ab, DD, refSat]         = optimalSolPr(D,eph1, sets); 
%Plot results from calculations performed above
plotResultDD(r_ab,tVec, DD, dir, refSat, sets)
%% Part 5 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimate global position
% compute the position based on the observation and ephmeris data 
% x=estGlobalPos([raw data], [ephemeris data], [step size](default=5), [t_end] (default=all))
x1=estGlobalPos(raw1,eph1, sets, p1);
x2=estGlobalPos(raw2,eph2, sets, p2);

%% Plot estimates
[fig1, fig2, fig3, fig4]=plot_global_estimate(x1, x2, gps1, gps2, sets);
sgtitle(fig1, {"Position difference in NED-coordinates, dist_{true}=10m "+dir+"-dir", ...
               "x_0:= first reading of receiver 1"})
sgtitle(fig2, {"Position difference in ECEF-coordinates, dist_{true}=10m "+dir+"-dir", ...
               "x_0:= first reading of receiver 1"})
sgtitle(fig3, {"Difference obs-||p_{sat}-p_{true}|| per satellite over time",...
               "obs adjusted for sv and receiver bias"})
sgtitle(fig4, {"Difference obs-||p_{sat}-p_{est}|| per satellite over time", ...
               "obs adjusted for sv and receiver bias"})         