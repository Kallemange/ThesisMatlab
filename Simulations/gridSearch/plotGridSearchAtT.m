function [p_opt, b_opt]=plotGridSearchAtT(raw, eph, p_true)


tShift=@(T, h) (T(1):h:T(2));
t1=tShift([-10, 10], 0.1);
[p1, ~, t_min1, MSE1, idx1]=gridSearch(eph,raw,t1);
t2=tShift(t_min1, 0.01);
[p2, b2, t_min2, MSE2, idx2]=gridSearch(eph,raw,t2);
p_opt = p2(idx2,:);
b_opt = b2(idx2);
lla0=ecef2lla(p_true);
spheroid=wgs84Ellipsoid;
[pN, pE, pD]=ecef2ned(p1(:,1), p1(:,2),p1(:,3), lla0(1), lla0(2),lla0(3), spheroid );
p1NED=[pN, pE, pD];
[pN, pE, pD]=ecef2ned(p2(:,1), p2(:,2),p2(:,3), lla0(1), lla0(2),lla0(3), spheroid );
p2NED=[pN, pE, pD];



figure
subplot(3,1,1)
hold on
plot(t1, MSE1, '*')
plot(t1, vecnorm(p1NED,2,2))
legend("MSE", "\Deltap")
title("Time interval: [" +num2str(t1(1))+","+num2str(t1(end))+"]s")
xlabel("Time shift [s]")
ylabel("Mean square error (y-y_{hat})/N")
subplot(3,1,2)
plot(t2, MSE2, '*-')
hold on
D_hor=vecnorm(p2(:,1:2)-p_true(1:2), 2,2);
[min_hor, i_hor]=min(D_hor);
plot(t2, D_hor, '*-')
D_p=vecnorm(p2-p_true,2,2);
plot(t2, D_p, '*-')
[min_p, i_p]=min(D_p);

%plot(t2(i_hor), min_hor, 'or', 'MarkerSize', 10)
%plot(t2(i_p), min_p, 'or', 'MarkerSize', 10)
%plot(t2(idx2), MSE2(idx2), 'o', 'MarkerSize', 10)
legend("MSE", "||\DeltaN+\DeltaE||", "||p-p_{true}||")
title("Time interval: [" +num2str(t2(1))+","+num2str(t2(end))+"]s")
xlabel("Time shift [s]")
ylabel("Mean square error (y-y_{hat})/N")
subplot(3,1,3)
hold on
for i=1:3
    plot(t2,p2NED(:,i));
end
title("\Delta p_{NED}")
legend("\DeltaN", "\DeltaE", "\DeltaD")
xlabel("Time shift [s]")