function calcD=calcDist(trueP, sats, N, s)
%Add noise to pseudorange measurement
%IN

noSats=length(sats);
calcD=zeros(noSats, N);
for i=1:noSats
    trueD       = vecnorm(sats(i).path-trueP);
    whiteNoise  = randn(1,N)*s;                     %Gaussian white noise, no
    calcD(i,:)  = trueD+whiteNoise;                 
end
