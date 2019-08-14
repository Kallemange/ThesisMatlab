function p_est=test_estimate_position(p,pSat, eps)
%IN:
%   p, double[3]: True position of receiver in ECEF (from internal solution of receiver)
%   pSat double[i*3]: position of satellites at time of tansmission.
%   eps, struct:  noise level (epsilon)
%           -satPos     Noise in satellite positions
%           -recPos     Noise in receiver position
%           -clockB     Noise in clock bias
%           -Gauss      Gaussian noise added on observation
%OUT:
%   NA
%
%Testing estimate_position with different noise levels and plotting the
%results in order to see that the function converges as expected
pr=simulate_observation(p,pSat,eps);


%Estimate position using receiver observations and calculated positions of
%the satellites
x0=[0 0 0];
p_est=estimate_position(pSat, pr, length(pr), x0,0, 3);


end