function test_gradient_descent(eph, b, t, sets)
%IN:
%eph, struct[]:         ephemeris data
%b, double[]:           receiver clock error
%t, double[]:           nominal time of sampling
%sets, struct:          simulation settings
%OUT:
%N/A
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
DESCRIPTION:
Create pseudorange obervations for receiver at position given by sets.posECEF
and satellite position calculated at t+b-tau, where:
t   := nominal time
b   := receiver clock bias
tau := time of flight (||p_rec-p_sv||/c) (speed of light)

Observation model: 
Observations are made without added noise


%}

x=estGlobalPos(raw, eph, sets);

end