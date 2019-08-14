function obs=simulate_observation(posRec, Xsat, eps)
%Create simulated observations from satellite and receiver positions, and a
%noise term

%Noise in satellite position
Xsat=Xsat+eps.satPos*randn(size(Xsat));
%Noise in receiver position
posRec=posRec+eps.recPos*randn(size(posRec));
%Euclidean distance
dist=vecnorm(Xsat-posRec,2,2);
%Noise in observation due to receiver clock bias [m]
obs=dist+eps.clockB*randn(size(dist));



