	function [lambda, phi, h] = WGStoEllipsoid(x,y,z)
	% WGStoEllipsoid Convert ECEF coordinates to Ellipsoidal (longitude, latitude, height above ellipsoid)
	% Usage: [lambda, phi, h] =  WGStoEllipsoid(x,y,z)
	% Input Args: coordinates in ECEF
	% Output Args: Longitude, Latitude in radians, height in meters

	% WGS ellipsoid params
	a = 6378137;
	f = 1/298.257;
	e = sqrt(2*f-f^2);
	% From equation 4.A.3,
	lambda = atan2(y,x);
	p = sqrt(x^2+y^2);

	% initial value of phi assuming h = 0;
	h = 0;
	phi = atan2(z, p*(1-e^2)); %4.A.5
	N = a/(1-(e*sin(phi))^2)^0.5;    
	delta_h = 1000000;
	while delta_h > 0.01
		prev_h = h;
		phi = atan2(z, p*(1-e^2*(N/(N+h)))); %4.A.5
		N = a/(1-(e*sin(phi))^2)^0.5;
		h = p/cos(phi)-N;
		delta_h = abs(h-prev_h);
	end
	end