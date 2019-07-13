function [az, el, r]=ecef2elaz(x, x0)
%Transform from ECEF 2 elev-azim wrt position given in INS receiver
%IN
%x      satellite position in ecef
%x0     user position in ecef
%OUT
%el     elevation of satellite wrt x0 (Polar angle wrt NED coordinate system)
%az     azimuth of satellite wrt x0
%r      radius to satellite


%Transform to NED-coordinates
spheroid = referenceEllipsoid('wgs84'); %Needed for the correct transform in ecef2ned
[N, E, D]=ecef2ned(x(:,1),x(:,2),x(:,3), x0(1), x0(2), x0(3), spheroid);
[az, el, r]=cart2sph(N, E, D);
az=180/pi*az;
if az<0
    az=360+az;
end
el=-180/pi*el;
%keyboard