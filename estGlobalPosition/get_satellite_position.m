	function [x y z] = get_satellite_position(eph, t, compute_harmonic_correction)
	% get_satellite_position: computes the position of a satellite at time (t) given the
	% ephemeris parameters. 
	% Usage: [x y z] =  get_satellite_position(eph, t, compute_harmonic_correction)
	% Input Args: eph: ephemeris data
	%             t: time 
	%             compute_harmonic_correction (optional): 1 if harmonic
	%             correction should be applied, 0 if not. 
	% Output Args: [x y z] in ECEF in meters
	% ephmeris data must have the following fields:
	% rcvr_tow (receiver tow)
	% svid (satellite id)
	% toc (reference time of clock parameters)
	% toe (referece time of ephemeris parameters)
	% af0, af1, af2: clock correction coefficients
	% ura (user range accuracy)
	% e (eccentricity)
	% sqrtA (sqrt of semi-major axis)
	% dn (mean motion correction)
	% m0 (mean anomaly at reference time)
	% w (argument of perigee)
	% omg0 (lontitude of ascending node)
	% i0 (inclination angle at reference time)
	% odot (rate of right ascension)
	% idot (rate of inclination angle)
	% cus (argument of latitude correction, sine)
	% cuc (argument of latitude correction, cosine)
	% cis (inclination correction, sine)
	% cic (inclination correction, cosine)
	% crs (radius correction, sine)
	% crc (radius correction, cosine)
	% iod (issue of data number)
    

	% set default value for harmonic correction
	switch nargin
		case 2
			compute_harmonic_correction=1;
	end 
	mu = 3.986005e14;
	omega_dot_earth = 7.2921151467e-5; %(rad/sec)

	% Now follow table 20-IV
	A = eph.A;
    try
	cmm = sqrt(mu/A^3); % computed mean motion
    catch EM
        
        keyboard
    end
	tk = t - eph.toe;
	% account for beginning of end of week crossover
	if (tk > 302400)
		tk = tk-604800;
	end
	if (tk < -302400)
		tk = tk+604800;
	end 
	% apply mean motion correction
	%n = cmm + eph.dn;
    %Updated: in IS documentation it's called deln (presumably)
    n = cmm + eph.deln;

	% Mean anomaly
    %mk = eph.m0 + n*tk;
    %Renamed
	mk = eph.M0 + n*tk;

	% solve for eccentric anomaly
    Ek =keplerEq(mk,eph.e,10e-6);
    %toc(tstart)
	% True anomaly:
	nu = atan2((sqrt(1-eph.e^2))*sin(Ek)/(1-eph.e*cos(Ek)), (cos(Ek)-eph.e)/(1-eph.e*cos(Ek)));
	%Ek = acos((eph.e  + cos(nu))/(1+eph.e*cos(nu)));

	%Phi = nu + eph.w;
    %Updated:
    Phi = nu + eph.omg;
    
	du = 0;
	dr = 0;
	di = 0;
	if (compute_harmonic_correction == 1)
	% compute harmonic corrections
	du = eph.cus*sin(2*Phi) + eph.cuc*cos(2*Phi);
	dr = eph.crs*sin(2*Phi) + eph.crc*cos(2*Phi);
	di = eph.cis*sin(2*Phi) + eph.cic*cos(2*Phi);
	end

	u = Phi + du;
	r = A*(1-eph.e*cos(Ek)) + dr;

	% inclination angle at reference time
	i = eph.i0 + eph.idot*tk + di;
	x_prime = r*cos(u);
	y_prime = r*sin(u);
	omega = eph.OMG0 + (eph.OMGd - omega_dot_earth)*tk - omega_dot_earth*eph.toe;
    

	x = x_prime*cos(omega) - y_prime*cos(i)*sin(omega);
	y = x_prime*sin(omega) + y_prime*cos(i)*cos(omega);
	z = y_prime*sin(i);

    end
    
    function E = keplerEq(M,e,eps)
% from https://se.mathworks.com/matlabcentral/fileexchange/39896-kepler-s-equation-solver
% Function solves Kepler's equation M = E-e*sin(E)
% Input - Mean anomaly M [rad] , Eccentricity e and Epsilon 
% Output  eccentric anomaly E [rad]. 
   	En  = M;
	Ens = En - (En-e*sin(En)- M)/(1 - e*cos(En));
    while ( abs(Ens-En) > eps )
		En = Ens;
		Ens = En - (En - e*sin(En) - M)/(1 - e*cos(En));
    end
	E = Ens;
end