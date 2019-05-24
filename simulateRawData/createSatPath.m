function sats=createSatPath(R, angles, N, noSats)
%IN
%R distance
%e0 starting angle elevation
%e1 ending angle elevation
%a0 starting angle azimuth
%a1 ending angle azimuth
%N number of steps

%OUT
%pos[3][] coordinates in a NED-frame
e0=angles.e0; e1=angles.e1;
a0=angles.a0; a1=angles.a1;

sats.svID=0;
sats.path=zeros(3,N);
sats=repmat(sats,1,noSats);
for i=1:noSats
    elev=linspace(e0(i),e1(i),N);
    azim=linspace(a0(i),a1(i),N);
    sats(i).svID    = i;
    sats(i).path    = setPos(R(i), elev, azim); 
end

function pos=setPos(R,elev, azim)
pos=[R*cosd(elev).*cosd(azim);...
     R*cosd(elev).*sind(azim);...
     -R*sind(elev);];
