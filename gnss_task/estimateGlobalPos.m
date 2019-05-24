function [xVec bVec]=estimateGlobalPos(raw, sat, L)
%Simple version, no need for time alignment etc.
c=299792458;
x0=zeros(1,3);
b0=0;
xVec=zeros(L,3); bVec=zeros(L,1);
for i=1:L
    xs=sat(i).data.NED;
    pr=raw(i).data.P;
    [x0 b0]=estimate_position(xs,pr,7, x0, b0, 3,1);
    xVec(i,:)=x0;
    bVec(i)=b0;
end
