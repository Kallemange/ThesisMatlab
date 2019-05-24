function R=Re2t(c1,lat,c2,lon);
% function for calculation of the rotation matrix for
% rotaion from e frame to t frame.
% function R=Re2t[c1,latitude,c2,longitude];

if(c1=='S')
    lat=-lat;
end

if(c2=='W')
    lon=-lon;
end

lat=lat/180*pi;
lon=lon/180*pi;

clat=cos(lat);
slat=sin(lat);

clon=cos(lon);
slon=sin(lon);

R=[-slat*clon -slat*slon  clat; 
   -slon          clon      0 ;
   -clat*clon -clat*slon -slat];

