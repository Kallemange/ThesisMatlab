function [xVec bVec]=estGlobalPos2(r, s)
%Global estimate from my sampled raw data
t0r=r(1).ToW;
t0s=s(1).ToW;
L=length(r);
c=299792458;
x0=zeros(1,3);
b0=0;
xVec=zeros(L,3); bVec=zeros(L,1);
isSatPos=0;
for i=1:L
    xs=s(floor((i-1)/10)+1).data;
    pr=r(i).data;
    [~, is, ir]=intersect(xs.svID, pr.sat);
    xs=xs(is,:);
    pr=pr(ir,:);
    noSats=length(ir);
    [x0 b0]=estimate_position2(xs,pr,noSats, x0, b0, 3, isSatPos);
    xVec(i,:)=x0;
    bVec(i)=b0;
end