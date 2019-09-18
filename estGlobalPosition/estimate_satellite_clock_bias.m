	function dsv = estimate_satellite_clock_bias(t, eph)
	F = -4.442807633e-10;
	mu = 3.986005e14;
	A = eph.A;
	cmm = sqrt(mu/A^3); % computed mean motion
	tk = t - eph.toe;
	% account for beginning or end of week crossover
	if (tk > 302400)
		tk = tk-604800;
	end
	if (tk < -302400)
		tk = tk+604800;
	end
	% apply mean motion correction
	n = cmm + eph.deln;

	% Mean anomaly
	mk = eph.M0 + n*tk;

	% solve for eccentric anomaly
	Ek=keplerEq(mk,eph.e,10e-6);
    %syms E;
	%eqn = E - eph.e*sin(E) == mk;
	%solx = vpasolve(eqn, E);
	%Ek = double(solx);
    
	dsv = eph.f0 + eph.f1*(t-eph.toc) + eph.f2*(t-eph.toc)^2 + F*eph.e*(eph.A^0.5)*sin(Ek);
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