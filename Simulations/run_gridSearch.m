%run_gridSearch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Run a grid search over the nominal time of the observation to see what
%time which best fits the observations by minimizing |y-y_hat| for all
%observations. 
addpath('Simulations/gridSearch/')
c           = 299792458;  
%%
raw=raw;
eph=eph;
x=x;
eph=eph([eph.sat]<33);
g=gps;
Id=5000;

p_true=lla2ecef([g.lla0(1), g.lla1(1), g.lla2(1)]);
[p, b]=plotGridSearchAtT(raw(Id), eph, p_true);

%%
% P Position estimate vector 
% B Clock bias estimate vector
% T Time vector
[P, B, T]=gridSearchAllT(raw, eph2);
%%

compare_globalPos_gridSearch(x, T,B)
