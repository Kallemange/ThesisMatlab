function [Xs, p, b]=calculate_Xs_states(eph, obs, t)
    L=length(eph);
    Xs          = zeros(L, 3);
    for j=1:L
        [xs, ys, zs]=get_satellite_position(eph(j), t);
        Xs(j,:)=[xs, ys, zs];
    end
    x0=zeros(1, 3);
    b0=0;
    [p, b]=estimate_position(Xs,obs, L, x0, b0, 3);
end