function [Xs]=satPositions(eph, t)
L=length(eph);
%Satellite positions
Xs=zeros(L,3);
for i=1:L
    [x, y, z]=get_satellite_position(eph(i), t);
    Xs(i,:)=[x, y, z];
end


