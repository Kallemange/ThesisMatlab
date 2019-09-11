function [obs Xsat]=simulate_observation(in)
%IN
%in struct with (relevant fields)
%   eps, struct with noise types:
%       satPos:                     Satellite position error
%       recPos:                     Receiver position error
%       clockB:                     Receiver clock bias
%       gauss:                      Measurement white noise 
%OUT
%obs, double[n]:                    Vector with observations (pseudorange)

%Create simulated observations from satellite true position and receiver
%positions, and a noise term

%Noise in satellite position estimate
Xsat=in.pSat+in.eps.satPos*randn(size(in.pSat));
%Noise in receiver position
posRec=in.pRec+in.eps.recPos*randn(size(in.pRec));
%Euclidean distance
dist=vecnorm(in.pSat-posRec,2,2);
%Noise in observation due to receiver clock bias [m]
obs=dist+in.eps.clockB; %*randn(1);
%Gaussian noise
obs=obs+in.eps.gauss*randn(size(obs));

end



