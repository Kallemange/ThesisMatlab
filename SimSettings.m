%Settings parameter to be sent in with all functions to further test the
%functionality of the simulation
clear global sets
global sets
%Simulation settings:
sets.sim.dist=100;              %True distance between receivers
sets.sim.t=0:0.2:10;            %The time interval between samples
sets.sim.skipT=@(t) t+1*randn(1,length(t));
sets.sim.skipSats=0.2;          %The prob that a rec. doesn't see a sv that it should see
sets.sim.minElev=1;             %Minimal elev-value for observable satellites
sets.sim.clockError=0.1;        %Clock error for receiver (to be mult by c)

%Simulation noise levels
sets.noise.Gnoise=0;            %Non-common Gaussian noise magnitude
sets.noise.sysNoiseMag=1000;    %Magnitude of sysNoise
sets.noise.sysNoiseVec=0;       %Matrix to contain the values in noise.sysNoise
sets.noise.sysNoise= @(M,N) sets.noise.sysNoiseMag*randn(M,N); %systematic noise
sets.noise.dirNoise=0;          %Gaussian Noise in the directions elev-azim
sets.noise.noiseH=0;            %Gaussian noise in the directions H-matrix (optimalSolPr)
sets.noise.round=1;             %Round off the value in the elev-azim measurements (sat)

%Optimal solution settings
sets.optSol.Weights="SNR";      %Options: "SNR", "elev", "elevSNR" Weighted matrix for LS-solution, possible values 
sets.optSol.elMask=15;          %elevation mask for satellites
sets.optSol.OnlyGPS=1;          %Switch if only to use GPS-satellites or all (if 1, only ephemeris for svID<satIDMax will be used)
sets.optSol.satIDMax=33;        %Maximum value of satID used (if OnlyGPS==1)

%Difference related calculations
sets.diffPr.interpol=0;         %Interpolate readings between obs t- and t+ for observations on rec2
sets.diffPr.threshold_t=0.2;    %Threshold for difference in time between obs_1 and obs_2

%Plot:                          %Which plots to show
sets.plots.isSim=0;             %If run is simulation or not
sets.plots.hist=1;              %Histogram over estimate distribution
sets.plots.histPerDir=0;        %Histogram over estimate per direction
sets.plots.cov=0;               %Covariance matrix satellite-readings 
sets.plots.posOverT=0;          %Position over time estimate
sets.plots.distOverT=1;         %Distance over time
sets.plots.DDVec=1;             %Double difference vector
sets.plots.residual=0;          %Residual over reconstruction errors
sets.plots.refSat=1;            %Satellite used as reference for DD
sets.plots.var= @(x) (var(x));  
sets.plots.global.plotGPS=0;    %Plot the internal solution together with the global position


%True position (approx) where logging was made (for frames and projection)
sets.posECEF=[3098534.400000,1011155.550000,5464107.630000]; 
sets.poslla=[59.352907,18.073239,31.999000];

%Settings related to global position estimate
sets.globalPos.h=5;             %Step size (1 equals all epochs)
sets.globalPos.t_end=0;         %Final epoch (0 equals all epochs)
sets.globalPos.weights="";

%Print data settings
sets.print.Itr=0;               %If print is made (only to check progress)
sets.print.Mod=1000;            %Frequency of printout

%Path to the correct log
sets.path=0;