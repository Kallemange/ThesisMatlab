function pr=simPr(r, sets, i)
c=299792458; %Speed of light
%Create a pseudorange measurement from raw data

%1st version: only true distance+normal dist noise
%pr=r+sets.noise.Gnoise*randn(size(r));

%2nd version: added a static extra noise for all measurements
%pr=r+sets.noise.sysNoise+sets.noise.Gnoise*randn(size(r));

%3rd version: added a random extra noise(shared for rec.1 and 2 each
%iteration)
%pr=r+sets.noise.sysNoiseVec(:,i)+sets.noise.Gnoise*randn(size(r));

%4th version: adding a clock error (first rec.) mult by c
pr=r+sets.noise.sysNoiseVec(:,i)+sets.noise.Gnoise*randn(size(r))...
    +sets.sim.clockError*c;