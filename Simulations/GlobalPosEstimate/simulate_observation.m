function obs=simulate_observation(in)
%Create simulated observations from satellite true position and receiver
%positions, and a noise term

%Noise in satellite position
Xsat=in.pSat+in.eps.satPos*randn(size(in.pSat));
%Noise in receiver position
posRec=in.pRec+in.eps.recPos*randn(size(in.pRec));
%Euclidean distance
dist=vecnorm(Xsat-posRec,2,2);
%Noise in observation due to receiver clock bias [m]
obs=dist+in.eps.clockB*randn(1);
%Gaussian noise
obs=obs+in.eps.gauss;

end



