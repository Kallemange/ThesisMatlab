T3=readtable('log3/LOG_SN34090_20190207_155313_0002_preintegratedImu.csv');



%% Plot velocity
close all
hold on
plot(T3.vel1_0_+0.01, 'r')
plot(T3.vel1_1_+0.01, 'g')
plot(T3.vel1_2_+0.01, 'y')
plot(T3.vel2_0_, 'b')
plot(T3.vel2_1_, 'm')
plot(T3.vel2_2_, 'k')

%% Plot angles
close all
hold on
plot(T3.theta1_0_+0.01, 'r')
plot(T3.theta1_1_+0.01, 'g')
plot(T3.theta1_2_+0.01, 'y')
plot(T3.theta2_0_, 'b')
plot(T3.theta2_1_, 'm')
plot(T3.theta2_2_, 'k')