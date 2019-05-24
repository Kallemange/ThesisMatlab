function u=findUnitV(s1)
%Function to find the unit vector pointing towards the SV in question
%The formula to produce these directional vectors is given by
%[sin a cos b, cos a cos b, sin b]'

for i=1
    elev     = s1(i).data.elev;
    azim     = s1(i).data.azim;
    %u.dir    = [sind(azim).*cosd(elev) cosd(azim).*cosd(elev) sind(elev)];
    %u.dir    = [cosd(elev).*cosd(azim) cosd( elev).*sind(azim) -sind(elev)];
    %[a b c]  = ecef2nedv(cosd(elev).*cosd(azim), cosd(elev).*sind(azim), -sind(elev),lla0.lat, lla0.long);   
    %u.dir    = [a b c];
    %https://se.mathworks.com/help/phased/ug/spherical-coordinates.html
    u.dir    = [cosd(elev).*cosd(azim) cosd(elev).*sind(azim) sind(elev)];
    
    u.sv     = s1(i).data.svID;
    u.ToW    = s1.ToW;
end
