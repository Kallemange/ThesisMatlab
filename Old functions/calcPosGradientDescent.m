function [x b]=calcPosGradientDescent(D,u, x0,b0)
dx = 100;
db = 0;
norm_dp = 100;
numIter = 0;
b = b0;
[~,iD,iu]=intersect(D.sat, u.sv);
%while (norm_dp > 1e-4)
while norm(dx) > 1e-3
    norms = sqrt(sum((xs-x0).^2,2));
    % delta pseudo range:
    dp = pr - norms + b - b0;
    G = [-(xs-x0)./norms ones(numSat,1)];
    sol = inv(G'*G)*G'*dp;
    dx = sol(1:dim)';
    db = sol(dim+1);
    norm_dp = norm(dp);
    numIter = numIter + 1;
    x0 = x0 + dx;
    b0 = b0 + db;
end
x = x0;
b = b0;