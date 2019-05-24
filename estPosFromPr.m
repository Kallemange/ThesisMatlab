function [D u]=estPosFromPr(s1,s2,r1,r2)

%Find times that both sensors are active for raw and sat data
%IN data1, data2, name of sorting variable
%OUT vector subset of valid indices wrt time
[t1raw, t2raw]      =findClosestReading(r1, r2);
[t1sat, t2sat]      =findClosestReading(s1, s2);

%Identify max time: t(end)-t(1) for raw and sat
t_maxraw=round(r1(t1raw(end)).ToW-r1(t1raw(1)).ToW, 2);
t_maxsat=round(s1(t1sat(end)).ToW-s1(t1sat(1)).ToW, 2);
t_max=min(t_maxraw,t_maxsat);

%Find all satellites which are shared between the sensors at each t
%IN data1, data2, valid time indices vector (1 and 2)
%OUT struct with Time, number of obs, shared satellites at valid indices
[s1shared,  s2shared]=findSharedSV(s1,s2, t1sat,t2sat);


%Find direction to the satellites, given elev and azim coordinates
%IN struct with all shared satellites
%OUT struct with directions and satellites and ToW
%u=[];
for i=1:min(length(t1sat), length(t2sat))
    try
    u(i)=findUnitV(s1shared(i));
    catch EM
        EM
        keyboard
    end
end
%Finds the satellites shared between r1, r2 and s1. Calculates the
%difference in pseudorange dp1-dp2 for each valid measurement
%IN raw data (1 and 2), valid times indices (1 and 2), valid satellites
%OUT cell-struct containing the pseudorange difference, sat ToW
D=calcDiffPr(r1,r2,t1raw,t2raw, s1shared, t_max);


