function plotAngles(T1, T2, t0)

%Since the integrals are reset every period of integration, the cumsum
%gives a value of the estimated angles over time
if(any(strcmp(T1.Properties.VariableNames, 'theta_0_')))
    T1.Properties.VariableNames{10}='theta1_0_';
    T1.Properties.VariableNames{11}='theta1_1_';
    T1.Properties.VariableNames{12}='theta1_2_';
    T2.Properties.VariableNames{10}='theta1_0_';
    T2.Properties.VariableNames{11}='theta1_1_';
    T2.Properties.VariableNames{12}='theta1_2_';
end
%figure
%plot3(cumsum(T1.theta1_0_(t0:end)), cumsum(T1.theta1_1_(t0:end)), cumsum(T1.theta1_2_(t0:end)), '*')
%hold on
%plot3(cumsum(T2.theta1_0_), cumsum(T2.theta1_1_), cumsum(T2.theta1_2_), 'o')
figure
hold on

%Here I looked at the time shift between the sensors, and manually moved
%them to match

plot(cumsum(T1.theta1_0_(t0:end)))
plot(cumsum(T2.theta1_0_))
plot(cumsum(T1.theta1_1_(t0:end)))
plot(cumsum(T2.theta1_1_))
plot(cumsum(T1.theta1_2_(t0:end)))
plot(cumsum(T2.theta1_2_))
legend('\theta1_0', '\theta2_0', '\theta1_1','\theta2_1', '\theta1_2', '\theta2_2')
xlabel('Angular integration over time, each axis independently. Time shift due to manual startup manually removed')
    