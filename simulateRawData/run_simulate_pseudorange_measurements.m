r1=raw1(1:1000);
r2=raw2(1:1000);
eph=eph1;
%x=x1;
%eph([2 4 11 12])=[];
%=eph([1 3 5 6 7 8 9 10 13 14 15 17]);
g=gps2;
p1=[g.lla_0_(1), g.lla_1_(1), g.lla_2_(1)];
if any(strcmp(g.Properties.VariableNames, 'lla0'))
    p_true1=lla2ecef([g.lla0(1), g.lla1(1), g.lla2(1)]);
elseif any(strcmp(g.Properties.VariableNames, 'lla_0_'))
    p_true1=lla2ecef([g.lla_0_(1), g.lla_1_(1), g.lla_2_(1)]);
end
baseline=10;
if strcmp(dir, "N")
    [xN,yN,zN]=ned2ecef(baseline, 0,0,g.lla_0_(1),g.lla_1_(1),g.lla_2_(1),wgs84Ellipsoid);
    p_true2=[xN, yN, zN];
elseif strcmp(dir, "E")
    [xN,yN,zN]=ned2ecef(0,baseline, 0,g.lla_0_(1),g.lla_1_(1),g.lla_2_(1),wgs84Ellipsoid);
    p_true2=[xN, yN, zN];
end
if_bias=1;
c = 299792458;              % Speed of light (m/s)
clock_bias1=c*(1e-5*cumsum(rand(length(r1),1)));
clock_bias2=c*(1e-5*cumsum(rand(length(r2),1)));

%pseudorange_simulated = simulate_pseudorange_measurements(receiver_pos, raw_obs, sat_eph_data, sat_idx, with_bias, clock_bias)
bias=20;
signal_bias=bias*randn(size(eph));
%signal_bias(6)=0;
raw_sim1=simulate_pseudorange_measurements(sets, p_true1, r1, eph, [eph.sat], if_bias, clock_bias1, signal_bias);
raw_sim2=simulate_pseudorange_measurements(sets, p_true2, r2, eph, [eph.sat], if_bias, clock_bias2, signal_bias);

x_sim1=estGlobalPos(raw_sim1, eph, sets, p_true1);
x_sim2=estGlobalPos(raw_sim2, eph, sets, p_true2);

%%
[t1raw_sim, ~, t0r]     = findFirstLast(raw_sim1, raw_sim2);
D_sim                   = calcDiffPr(raw_sim1,raw_sim2,t1raw_sim, sets);
[tVec_sim, r_ab_sim, DD_sim, refSat, DOP]         = optimalSolPr(D_sim,eph, sets, p_true1); 
%%  
[t1_sim, t2_sim]=matchRecTime(x_sim1, x_sim2);
%%
plotGlobalAndDD(x_sim1,x_sim2,t1_sim, t2_sim,tVec_sim, r_ab_sim, baseline, dir,"sim", bias, p1)
%%
%plotResultDD(r_ab_sim,tVec_sim, DD_sim, dir, refSat, sets, DOP)