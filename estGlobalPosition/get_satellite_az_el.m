function [az el] = get_satellite_az_el(xs,ys,zs,xu,yu,zu)
    % get_satellite_az_el: computes the satellite azimuth and elevation given
    % the position of the user and the satellite in ECEF
    % Usage: [az el] = get_satellite_az_el(xs,ys,zs,xu,yu,zu)
    % Input Args: xs,ys,zs: satellite position in ECEF
    %              xu,yu,zu: user position in ECEF              
    % Output Args: azimuth and elevation
    if nargin<6
        yu=xu(2);
        zu=xu(3);
        xu=xu(1);
    end
    [lambda, phi, h] = WGStoEllipsoid(xu,yu,zu);
    lat = phi*180/pi;
    lng = lambda*180/pi;
    enu =rotxyz2enu([xs-xu,ys-yu,zs-zu]', lat, lng);
    az = atan2d(enu(1), enu(2));
    el = asind(enu(3)/norm(enu));
    % The azimuth and elevation
end

function enu=rotxyz2enu(xyz, lat, lon)

R1=rot(90+lon, 3);
R2=rot(90-lat, 1);

R=R2*R1;
enu=R*xyz;
end
