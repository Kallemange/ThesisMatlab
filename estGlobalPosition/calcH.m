function H=calcH(x0, xs, lla0)
%Geometric distribution of the satellites to calculate the DOP-values
[N,E,D]=ecef2ned(xs(:,1),xs(:,2),xs(:,3),lla0(1), lla0(2), lla0(3), wgs84Ellipsoid);
norms = sqrt(sum((xs-x0).^2,2));
% delta pseudo range:
G = [-[N E D]./norms];
G_ = [G ones(size(G, 1),1)];

H = inv(G_'*G_);