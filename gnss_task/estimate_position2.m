function [x, b] = estimate_position2(xs, pr, numSat, x0, b0, dim, isSatPos)
	% estimate_position: estimate the user's position and user clock bias
	% Usage: [x, b, norm_dp, G] = estimate_position(xs, pr, numSat, x0, b0, dim)
	% Input Args: xs: satellite position matrix
	%             pr: corrected pseudo ranges (adjusted for known value of the
	%             satellite clock bias)
	%             numSat: number of satellites
	%             x0: starting estimate of the user position
	%             b0: starting point for the user clock bias
	%             dim: dimensions of the satellite vector. 3 for 3D, 2 for 2D
	% Notes: b and b0 are usually 0 as the current estimate of the clock bias
	% has already been applied to the input pseudo ranges.
	% Output Args: x: optimized user position
	%              b: optimized user clock bias
	%              norm_dp: normalized pseudo-range difference
	%              G: user satellite geometry matrix, useful for computing DOPs
	dx = 100*ones(1, dim);
	db = 0;
	norm_dp = 100;
	numIter = 0;
	b = b0;
    c=299792458;
	%while (norm_dp > 1e-4)
    %G = [EA2UNITV(xs.elev, xs.azim) ones(numSat,1)];
    G = [EA2UNITV(xs.elev, xs.azim)];
    sol = inv(G'*G)*G'*pr.P;
    dx = sol(1:dim)';
    %db = sol(dim+1);
	x = dx;
	b = db;
    
function G=EA2UNITV(elev, azim)
            G=[cosd(elev).*cosd(azim)...
                    cosd(elev).*sind(azim)...
                    -sind(elev)];

