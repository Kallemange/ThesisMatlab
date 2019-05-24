%Main file, Own implementation of DD estimate from GPSaidedINS
close all, clear all, clc
rmpath GPSaidedINS\
load GPSdata.mat
%% Extract the data
satIdx=[];
pr=[];
satPos=[];
for i=1:30
    if (~all(isnan(gps_data(i).PseudoRange)))
        satIdx=[satIdx; i];
        satPos=[satPos; gps_data(i).Satellite_Position_NED];
        pr=[pr;gps_data(i).PseudoRange];
    end
end
L=size(satPos,2);
truePos=ref_data.traj_ned;
for i=1:L
    P=pr(:,i);
    svID        = satIdx;
    sat         = satIdx;
    sats        = reshape(satPos(:,i), 3, 7);
    NED         = sats';
    azim        = round(atand(sats(2,:)./sats(1,:)))';
    elev        = round(atand(sats(3,:)./vecnorm(sats(1:2,:))))';
    sat1(i).data = table(svID, azim, elev, NED);
    sat1(i).ToW  = 0.2*(i-1);
    SNR         = [1:7]';
    raw1(i).data = table(sat, SNR,P);
    raw1(i).ToW  = 0.2*i;
    
end

%% Creating the pseudorange double difference

raw2=raw1;
for i=1:L
    %u               = EA2UNITV(sat1(i).data.elev,sat1(i).data.azim);
    u               =(sat1(i).data.NED)./vecnorm(sat1(i).data.NED')';
    dp              = (truePos(:,i)'*u')';
    raw2(i).data.P  = raw1(i).data.P+dp;
    raw2(i).ToW     = 0.2*i;
end
%% Creating a time-shifted data set raw2
tau=5;
raw2=raw1(1+tau:end);
sat2=sat1(1+tau:end);
L2=size(raw2,2);
for i=1:L2
    raw2(i).ToW=raw2(i).ToW-0.2*tau;
    sat2(i).ToW=sat2(i).ToW-0.2*tau;
end

%% Estimate the Global position from exercise
[xVec1 bVec1]=estimateGlobalPos(raw1, sat1, L);
[xVec2 bVec2]=estimateGlobalPos(raw2, sat2, L2);

%% Calculate Double Differenced r_ab
[r_ab, tVec] = calcR_ab(sat1,sat2, raw1, raw2);
%% Plot the spread of the data 
plotPos(xVec1, xVec2, truePos, r_ab, tau)
