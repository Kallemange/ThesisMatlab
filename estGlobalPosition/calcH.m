function H=calcH(x0, xs)
%Geometric distribution of the satellites to calculate the DOP-values
norms = sqrt(sum((xs-x0).^2,2));
% delta pseudo range:
G = [-(xs-x0)./norms];
G_ = [G ones(size(G, 1),1)];
H = inv(G_'*G_);