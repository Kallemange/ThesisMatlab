%Sensitivity analysis for ephemeris data
addpath("Simulations\ephemerisSensitivity\");
eph=eph1(2);
ephPar.names=string(fields(eph));
ephPar.names([1:11, 27, 28, 31])=[];
ephPar.mag=[1, 1e-6, 1e-6, 1e-6,...
            1e-6,1e-6,1e-9, 1e-9,...
            1e-11,1e-6, 1e-6,1e-6,...
            1e-6,1e-7, 1e-8, 1e-4,1e-12];
t=1:100:3600*24;
fig_pert=ephSensAnalys(ephPar, eph, t);
savefig(fig_pert, 'Simulations/ephemerisSensitivity/fig_pert')