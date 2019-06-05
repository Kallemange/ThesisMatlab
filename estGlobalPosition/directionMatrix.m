function G=directionMatrix(xs, x0)
		norms = sqrt(sum((xs-x0).^2,2));
		G = [(xs-x0)./norms];
end