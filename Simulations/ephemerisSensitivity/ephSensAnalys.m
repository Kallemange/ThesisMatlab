function fig_pert=ephSensAnalys(ephPar, eph, t)
%fig=ephSensAnalys(parameters, eph, time)

%IN: 
% ephPar, struct:   parameters to perturb
%   names:  parameter name
%   mag:    perturbation magnitude
% eph, struct:      ephemeris parameters
% t, double[]:      time vector
%OUT:
% fig_pert, fig:    perturbation figure
% Simulate the behavior of the satellite path as a function of perturbation
% per parameter.
Xs=zeros(length(t),3);
Xs_per=zeros(length(t),3);
fig_pert=figure;
for i=1:length(ephPar.names)
    eph_perturbed=eph;
    perturbation=randn(1)*ephPar.mag(i);
    eph_perturbed.(ephPar.names(i))=eph_perturbed.(ephPar.names(i))+perturbation;
    for j=1:length(t)
        dt=estimate_satellite_clock_bias(t(j), eph);
        dt_perturbed=estimate_satellite_clock_bias(t(j), eph_perturbed);
        [x1,y1,z1]=get_satellite_position(eph, t(j)-dt);
        Xs(j,:)=[x1, y1, z1];
        [x_per,y_per,z_per]=get_satellite_position(eph_perturbed, t(j)-dt_perturbed);
        Xs_per(j,:)=[x_per, y_per, z_per];
        
    end
    subplot(3,6,i)
    plot(t/3600,vecnorm(Xs-Xs_per,2,2))
    title("\Delta"+ephPar.names(i)+": "+num2str(perturbation))
    xlabel("time [h]")
end
sgtitle("Difference in satellite position fix per parameter per "+num2str(round(t(end)/3600))+"h.")
end
