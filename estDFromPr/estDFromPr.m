function [D u]=estDFromPr(s1,s2,r1,r2, sets)

%Find times that both sensors are active for raw and sat data
%IN data1, data2, name of sorting variable
%OUT vector subset of valid indices wrt time
[t1raw, t2raw, t0r, t_endR]     = findFirstLast(r1, r2);
[t1sat, t2sat, ~, ~]            = findFirstLast(s1, s2);

%Find all satellites which are shared between the sensors at each t
%IN data1, data2, valid time indices vector (1 and 2)
%OUT struct with Time, number of obs, shared satellites at valid indices
[svShared]                      = findSharedSV2(s1,s2, t1sat,t2sat);


%Find direction to the satellites, given elev and azim coordinates
%IN struct with all shared satellites
%OUT struct with directions and satellites and ToW
%u=[];
for i=1:size(svShared,2)
    try
    u(i)=findUnitV(svShared(i));
    catch EM
        EM
        keyboard
    end
end
%Finds the satellites shared between r1, r2 and s1. Calculates the
%difference in pseudorange dp1-dp2 for each valid measurement
%IN raw data (1 and 2), valid times indices (1 and 2), valid satellites
%OUT cell-struct containing the pseudorange difference, sat ToW
D=calcDiffPr(r1,r2,t1raw,t2raw, svShared,t0r, t_endR);

