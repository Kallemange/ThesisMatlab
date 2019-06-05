function [r1, r2]=findValidTimeIndices(r1, r2)
%Find indices which are valid for the calculations, the smaller subset
%where both receivers are active. Then returns the vectors of indices where
%r1 and r2 can be used

%If r2 is later than r1, use that as first time. Else use r1
if(r1(1).ToW<r2(1).ToW)
    t0=r2(1).ToW;
else
    t0=r1(1).ToW;
end

%If r1 ends before r2, use that as final time. Else use r2
if(r1(end).ToW<r2(1).ToW)
    t_end=r1(end).ToW;
else
    t_end=r2(end).ToW;
end
r1=selectInd(r1, t0, t_end);
r2=selectInd(r2, t0, t_end);


function r=selectInd(r, t0, t1)
r=r([r(:).ToW]>=t0);
r=r([r(:).ToW]<=t1);
