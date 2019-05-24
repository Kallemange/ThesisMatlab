function posFromIMU(T1,T2, t0)
figure
hold on
plot(cumsum(T1.vel1_0_(t0:end)))
plot(cumsum(T2.vel1_0_))
plot(cumsum(T1.vel1_1_(t0:end)))
plot(cumsum(T2.vel1_1_))
xlabel('Velocity Preintegrated sensor 1 and 2, timeshifted manually')
figure
hold on
plot(cumsum(T1.vel1_2_(t0:end)))
plot(cumsum(T2.vel1_2_))
xlabel('Velocity Preintegrated sensor 3, timeshifted manually')

plot3(cumsum(T1.theta1_0_), cumsum(T1.theta1_1_), cumsum(T1.theta1_2_))

keyboard
    

