function plotInternalSolution(path1, path2)
%Function to provide plots of global positional fixes from the internal
%solution of the receivers. Plots are showing:
%1) Global position wrt the mean position of x1 in NED-frame
%2) Radial distance over time between receivers
%3) Distance in NED over time between receivers
%IN
%path [string], path [string] (optional)
%OUT
%N/A
x1=readtable(path1);
if nargin==2
    x2=readtable(path2);
end
wgs84 = wgs84Ellipsoid;
%Transform the position to NED-coordinates wrt the position of rec1
[x y z]=ecef2ned(x1.ecef_0_, x1.ecef_1_, x1.ecef_2_,x1.lla_0_(1), x1.lla_1_(1), x1.lla_2_(1), wgs84);
rec1.pos=[x y z];
rec1.t=x1.ToWms;
[x y z]=ecef2ned(x2.ecef_0_, x2.ecef_1_, x2.ecef_2_,x2.lla_0_(1), x2.lla_1_(1), x2.lla_2_(1), wgs84);
rec2.pos=[x y z];
rec2.t=x2.ToWms;

for i=1:3
    subplot(3, 1, i)
    plot(rec1.t,rec1.pos(:,i))
    hold on
    plot(rec2.t, rec2.pos(:,i));
end