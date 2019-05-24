function relativeGPSPosINS1(T1, T2)
%Position 1 extracted from table, coordinate direction unknown, possibly
%Pos=[x y z time]
%Origin is set to the first reading

%Choose Coordinate system
CS='lla'; 
Pos1NED=[T1.(strcat(CS,'_0_')) T1.(strcat(CS,'_1_')) T1.(strcat(CS,'_2_'))];
Pos2NED=[T2.(strcat(CS,'_0_')) T2.(strcat(CS,'_1_')) T2.(strcat(CS,'_2_'))];
Pos1Time= T1.timeOfWeek;
Pos2Time= T2.timeOfWeek;
%Find the first and last time-value
t0=max(T1.timeOfWeek(1),T2.timeOfWeek(1));
t1=min(T1.timeOfWeek(end),T2.timeOfWeek(end));
%Extract the vector for the same timeperiod
tVec1=find(T1.timeOfWeek>=t0 & T1.timeOfWeek<=t1);
tVec2=find(T2.timeOfWeek>=t0 & T2.timeOfWeek<=t1);
origin=Pos1NED(tVec1(1),:);
%Shift position to origin
P1shift=Pos1NED-origin;
P2shift=Pos2NED-origin;

P1shift=P1shift(tVec1,:);
P2shift=P2shift(tVec2,:);
hold on
plot3(P1shift(:,1), P1shift(:,2),P1shift(:,3), 'b-*')
plot3(0, 0, 0, 'kO', 'MarkerSize', 12, 'LineWidth', 4)
plot3(P2shift(:,1), P2shift(:,2), P2shift(:,3), 'r-o')
xlabel('GPS Position estimates with a fixed distance (160cm)')
view(2)
hold off
figure
M=length(Pos1Time);
N=length(Pos2Time);
max_i=min(M,N);
delta_p=Pos1NED(1:max_i,:)-Pos2NED(1:max_i,:);
delta_pnorm=vecnorm(Pos1NED(1:max_i,:)-Pos2NED(1:max_i,:),2,2);
subplot(121)
plot3(delta_p(:,1), delta_p(:,2), delta_p(:,3), 'go');
xlabel('Reciever distance over time in 3D')
subplot(122)
plot(delta_pnorm)
xlabel('Euclidian distance between recievers (true val. 160 cm)')
