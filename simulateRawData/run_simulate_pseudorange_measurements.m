raw=raw2;
eph=eph2;
%x=x1;
%eph=eph([eph.sat]<33);
g=gps2;
if any(strcmp(g.Properties.VariableNames, 'lla0'))
    p_true=lla2ecef([g.lla0(1), g.lla1(1), g.lla2(1)]);
elseif any(strcmp(g.Properties.VariableNames, 'lla_0_'))
    p_true=lla2ecef([g.lla_0_(1), g.lla_1_(1), g.lla_2_(1)]);
end
Id=17500;
if_bias=1;
c = 299792458;              % Speed of light (m/s)
clock_bias=c*(0.001-1e-5*cumsum(rand(length(raw),1)));

%pseudorange_simulated = simulate_pseudorange_measurements(receiver_pos, raw_obs, sat_eph_data, sat_idx, with_bias, clock_bias)

raw_sim=simulate_pseudorange_measurements(p_true, raw, eph, [eph.sat], if_bias, clock_bias);

x_sim=estGlobalPos(raw_sim, eph, sets, p_true);
%%
subplot(2,1,1)
plot(x_sim.xVec-p_true)
legend("x", "y", "z")
title("Difference position p_{est}-p_{true}")
subplot(2,1,2)
hold on
plot(clock_bias(1:5:end), 'LineWidth', 8)
plot(x_sim.tVec-x_sim.tVec(1),  x_sim.bVec, 'LineWidth', 3)
title("Calculated and true clock bias")
legend("dt_{true}", "dt_{est}")