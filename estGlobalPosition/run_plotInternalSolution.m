function run_plotInternalSolution(log_path, trueD)

direction='E';
%Logs to use for calculations
T1=log_path+"/"+direction+"1/gps.csv";
T2=log_path+"/"+direction+"2/gps.csv";
plotInternalSolution(T1,T2, trueD, direction, false);
direction='N';
T1=log_path+"/"+direction+"1/gps.csv";
T2=log_path+"/"+direction+"2/gps.csv";
plotInternalSolution(T1,T2, trueD, direction, false);