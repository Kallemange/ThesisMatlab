function [s1, s2, r1, r2]=simulateRawData()
%{
Simulating raw and sat data with two receivers at a given distance and an
added white gaussian noise to confirm the calculations

Needed: 
    * Positional fixes, (0,0,0) and e.g. (10, 0, 0) in NED coord
    * Satellite positions over time
    * Caculate true distance
    * Add gaussian noise (as function of distance?)
    * Raw logs need: numSats, ToW~=10^9, data: 
                                            sat, SNR, (~LLI), (~code),P 
    * Sat logs need: numSats, ToW~=10^5, data:
                                            svID, elev, azim, prRes, CNO

pseudo code
    truePRec    - TRUE POS b AND b in ECEF coordinates (b=a+[10 0 0])
    truePSat    - Satellite true pos over time
                    * Round orbits at given distance from origin
    trueD       - True distance vecnorm (b-a)
    calcD       - Calculated distance = trueD+eps
    calcElev    - Calculated angle elev = atand(D/sqrt(N^2+E^2))
    calcAzim    - Calculated angle azim = atand(E/N)

    
    

%}
%For an ECEF-coordinate frame stockholm location
%truePRecA   = 1.0e+06*[3.0990 1.0111 5.4638];
trueP_a         = [0 0 0]';                     %True position receiver a
trueP_b         = trueP_a+[10 0 0]';            %True position receiver ab
noSats          = 8;                            %No of observed satellites
R0              = 20e6+randn(noSats,1)*1e5;     %Radius to satellite
angles.e0       = rand(noSats,1)*90;            %Starting angle elev
angles.e1       = rand(noSats,1)*90;            %Ending angle elev
angles.a0       = rand(noSats,1)*360;           %Starting angle azim
angles.a1       = rand(noSats,1)*360;           %Ending angle azim
N               = 500;                            %Number of epochs
sigma           = 10;

%whiteNoise      = @(N,s) randn(1,N)*s;          %Gaussian white noise, no

sats            = createSatPath(R0, angles, N, noSats); 

calcD_a         = calcDist(trueP_a, sats, N, sigma);
calcD_b         = calcDist(trueP_b, sats, N, sigma);

t0raw           = 1e9;
r1              = createRawLog(noSats, N, t0raw, calcD_a);
r2              = createRawLog(noSats, N, t0raw+0.1, calcD_b);

t0sat           = 10e5;
s1              = createSatLog(noSats, N, t0sat, sats, angles);
s2              = createSatLog(noSats, N, t0sat+0.1, sats, angles);    





