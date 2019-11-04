function [y_pred, MSE]=calc_y_pred(Xs, p, b, obs)
    y_pred=vecnorm(Xs-p,2,2)+b;
    MSE=sum(abs(obs-y_pred))/length(obs);
end
