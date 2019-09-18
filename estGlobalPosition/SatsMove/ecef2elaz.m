function [az, el, r]=ecef2elaz(x, x0)

%IN
%x,     double[n][3]:           satellite position in ecef
%x0,    double[3]:              user position in ecef
%OUT
%az,    double in (0,360):      azimuth of satellite wrt x0
%el,    double in (-90,90):     elevation of satellite wrt x0 (Polar angle wrt NED coordinate system)
%r,     double:                 radius to satellite

%Transform from ECEF 2 elev-azim wrt position given in INS receiver
%Transform to NED-coordinates
spheroid = referenceEllipsoid('wgs84'); %Needed for the correct transform in ecef2ned
%Transform to lla-coordinates for ecef2ned function
lla=ecef2lla(x0);
[N, E, D]=ecef2ned(x(:,1),x(:,2),x(:,3), lla(1), lla(2), lla(3), spheroid);
[az, el, r]=cart2sph(N, E, D);
az=180/pi*az;
if az<0
    az=360+az;
end
el=-180/pi*el;
