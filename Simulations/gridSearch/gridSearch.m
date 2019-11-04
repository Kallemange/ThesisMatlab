function [p, b, t_min, MSE, minIdx]=gridSearch(eph, raw, tShift, p_true)
%IN:
% eph, double[]:    Ephemeris data
% raw, struct[]:    Observation data struct
% tShift, double[2]:Min-Max value for time shift.
%OUT:
% p, double[3]:     Estimated position (ECEF)
% b, double:        Estimated clock bias
%
%Sweep the satellite times to see what position best corresponds to true
%observations. Use only the Gauss Newton solver in estimate position for
%each observation and corresponding satellite positions.
%For each such state and corresponding satellite, create y_hat and compute
%|y-y_hat|. Choose i s.t. t+tShift(i) minimizes [y-y_hat|. 
%Make a finer resolution solution around better values of shift

%{
%Algorithm pseudocode:
    1. Calculate compensation factor for sv clock bias at obs for t
    2. Calculate nominal 
    3. Calculate satellite position at t+tShift
    4. Estimate b and p from obs given Xs
    5. Calculate y_hat given p, b and Xs
    6. Create high resolution solution at optimal tShift.
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nargin default values

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Declarations and defines
c           = 299792458;        % Speed of light
[~, iE, iR] = intersect([eph.sat], raw.data(:,1));
eph_t       = eph(iE);
obs         = raw.data(iR,5);
week        = eph(1).week;
[~, t]      = UTC_in_sec2GPStime(raw.ToW, week);
L           = length(eph_t);
dsv         = zeros(1, L);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Part 1 sv clock bias
for i = 1:L
    dsv(i) = estimate_satellite_clock_bias(t, eph_t(i));
end
obsAdj = obs+dsv'*c; %Update obs for satellite clock bias
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Part 2 Calculate reveiver state at t+tShift
M=length(tShift);
p=zeros(M,3);
b=zeros(M,1);
MSE=zeros(M,1);
y_predVec=zeros(L,M);
for i=1:length(tShift)
    tau=tShift(i);
    [Xs, p(i,:), b(i)]=calculate_Xs_states(eph_t, obsAdj, t+tau);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Part 3 Calculate y_pred and MSE
    [y_predVec(:,i), MSE(i)]=calc_y_pred(Xs, p(i,:),b(i), obsAdj);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 4

[~, minIdx]=min(MSE);

t_min=tShift([minIdx-2 minIdx+2]);

end
