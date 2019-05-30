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
	syms E;
	eqn = E - eph.e*sin(E) == mk;
	solx = vpasolve(eqn, E);
	Ek = double(solx);

	dsv = eph.f0 + eph.f1*(t-eph.toc) + eph.f2*(t-eph.toc)^2 + F*eph.e*(eph.A^0.5)*sin(Ek);
	end