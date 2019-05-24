function [c1,lat,c2,lon,h]=r2g(v)
% function for convertion from ECEF rectangular coordinates 
% to geodetic coordinates
% function [N/S,latitude,E/W,longitude,height]=r2g(v)
% v=[x,y,z]'
% edit: isaac skog 29-10-2004

% check if N/S and E/W
if(v(3)<0)
    c1='S';
else
    c1='N';
end

if(v(2)<0)
    c2='W';
else
    c2='E';
end



% direct calculations of the longitude
lon=atan2(v(2),v(1));
lon=abs(lon*180/pi);

v=abs(v);

% semimajor axis lenght, [m]
a=6378137.0; 

% semiminor axis lenght, [m]
b=6356752.3142;

% flatness of the ellipsoid
f=(a-b)/a;

% eccentricity of the ellipsoid
e=sqrt(f*(2-f));

% init
h=0;
N=a;
p=sqrt(v(1)^2+v(2)^2);
old_lat=inf;
old_h=inf;

% iterate until convergence
while (1)
slat=v(3)/(N*(1-e^2)+h);  %slat=sin(lat);

lat=atan((v(3)+(e^2)*N*slat)/p);

N=a/sqrt(1-(e*sin(lat))^2);

h=p/cos(lat)-N;

    if (abs(h-old_h)<0.1 & abs(lat-old_lat)<1e-6)
    lat=lat*180/pi;
    return;
    end

old_h=h;
old_lat=lat;
end    