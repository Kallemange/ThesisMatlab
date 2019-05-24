function [Range elev, azim]=RangeandAngle(Sat_pos_ecef,Rec_pos_ecef, sets)

[M N]=size(Sat_pos_ecef);
%[M N]=size(Sat_pos_ecef');

% Calculate Ranges
Vec_sat_rec=Sat_pos_ecef-repmat(Rec_pos_ecef,M/3,1);
%Vec_sat_rec=Sat_pos_ecef-repmat(Rec_pos_ecef',1,9);
Range=sqrt(dot(Vec_sat_rec,Vec_sat_rec));

% Calculate angle between horizont and satellite
[c1,latitude,c2,longitude,h]=r2g(Rec_pos_ecef);
R=Re2t(c1,latitude,c2,longitude);
Sat_pos_ned=R*Vec_sat_rec;
heigth=-Sat_pos_ned(3,:);

elev=asind(heigth./Range);
azim=atand(Sat_pos_ned(2,:)./Sat_pos_ned(1,:));
callingFunc=dbstack;
%Check that it's make sat log that calls the function and not any other
if (strcmp(callingFunc(2).name,'makeSatLog')) 
    elev=elev+sets.noise.dirNoise*randn(size(elev));
    azim=azim+sets.noise.dirNoise*randn(size(elev));
end
    
%Transform angles from [-90,90]->[-180,180]
if (Sat_pos_ned(1)<0&&Sat_pos_ned(2)>0)
    azim=azim+180;
elseif(Sat_pos_ned(1)<0&&Sat_pos_ned(2)<0)
    azim=azim-180;
end




