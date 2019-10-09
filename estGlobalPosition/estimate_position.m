	function [x, b, norm_dp, G, xVec, bVec] = estimate_position(xs, pr, numSat, x0, b0, dim, pres)
	% estimate_position: estimate the user's position and user clock bias
	% Usage: [x, b, norm_dp, G] = estimate_position(xs, pr, numSat, x0, b0, dim)
	% Input Args: xs: satellite position matrix
	%             pr: corrected pseudo ranges (adjusted for known value of the
	%             satellite clock bias)
	%             numSat: number of satellites
	%             x0: starting estimate of the user position
	%             b0: starting point for the user clock bias
	%             dim: dimensions of the satellite vector. 3 for 3D, 2 for 2D
    %             pres (optional): precision, argument for when iteration stops
	% Notes: b and b0 are usually 0 as the current estimate of the clock bias
	% has already been applied to the input pseudo ranges.
	% Output Args: x: optimized user position
	%              b: optimized user clock bias
	%              norm_dp: normalized pseudo-range difference
	%              G: user satellite geometry matrix, useful for computing DOPs
    %              xVec: receiver position estimate at each iteration
    %              bVec: clock bias estimate at each iteration
    noIter=1;
	dx = 100*ones(1, dim);
	db = 0;
	norm_dp = 100;
	numIter = 0;
	b = b0;
    if nargin<7
        pres=1e-3;
    end    
    xVec=x0; bVec=b0;
	%while (norm_dp > 1e-4)
	while (norm(dx) > pres &&noIter<10)
        noIter=noIter+1;
		norms = sqrt(sum((xs-x0).^2,2));
		% delta pseudo range:
		dp = pr - norms + b - b0;
		G = [-(xs-x0)./norms ones(numSat,1)];
		sol = (G'*G)\(G'*dp);
		dx = sol(1:dim)';
		db = sol(dim+1);
		norm_dp = norm(dp);
		numIter = numIter + 1;
		x0 = x0 + dx;
		b0 = b0 + db;
        xVec(end+1,:)=x0;
        bVec(end+1)=b0;
	end
	x = x0;
	b = b0;
	end