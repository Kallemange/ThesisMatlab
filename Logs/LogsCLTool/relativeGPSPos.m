function relativeGPSPos(T1, T2, CS)
%Position 1 extracted from table, coordinate direction unknown, possibly
%Origin is set to the first reading of table T1
%Readings are taken in from a lla-coordinate system, and transformed to a
%NED system using the MATLAB-command geodetic2ned


%Choose Coordinate system
Pos1NED=[T1.(strcat(CS,'_0_')) T1.(strcat(CS,'_1_')) T1.(strcat(CS,'_2_'))];
Pos2NED=[T2.(strcat(CS,'_0_')) T2.(strcat(CS,'_1_')) T2.(strcat(CS,'_2_'))];

if(any(strcmp(T1.Properties.VariableNames, 'timeOfWeekMs')))
    timeformat='timeOfWeekMs';
else
    timeformat='timeOfWeek';
end
Pos1Time= T1.(timeformat);
Pos2Time= T2.(timeformat);
%Transform to a NED-system with the first measurement in T1 as origin
[x1 y1 z1]=geodetic2ned(Pos1NED(:,1), Pos1NED(:,2), Pos1NED(:,3),Pos1NED(1,1), Pos1NED(1,2), Pos1NED(1,3),wgs84Ellipsoid);
[x2 y2 z2]=geodetic2ned(Pos2NED(:,1), Pos2NED(:,2), Pos2NED(:,3),Pos1NED(1,1), Pos1NED(1,2), Pos1NED(1,3),wgs84Ellipsoid);

%Plot them out
hold on
plot3(x1,y1,z1, 'b*')
plot3(x2,y2,z2,'ro')
%Mark the origin
plot3(x1(1),y1(1),z1(1), 'kO', 'MarkerSize', 12, 'LineWidth', 4)
plot3(x2(1),y2(1),z2(1), 'mO','MarkerSize', 12, 'LineWidth', 4)
plot3(x1(end),y1(end),z1(end), 'gO', 'MarkerSize', 12, 'LineWidth', 4)
plot3(x2(end),y2(end),z2(end), 'gO', 'MarkerSize', 12, 'LineWidth', 4)
xlabel('GPS Position estimates with a fixed distance (160cm)')

view(2)
hold off
%New plot with euklidian distance, observe that observation times are not
%synchronized, so the difference is somewhat time-approximate
figure
M=length(Pos1Time);
N=length(Pos2Time);
max_i=min(M,N);
%Calculate the distance between the position estimates over time
delta_p=Pos1NED(1:max_i,:)-Pos2NED(1:max_i,:);
delta_pnorm=vecnorm(Pos1NED(1:max_i,:)-Pos2NED(1:max_i,:),2,2);
delta_pnormH=vecnorm(Pos1NED(1:max_i,1:2)-Pos2NED(1:max_i,1:2),2,2);
subplot(121)
plot3(delta_p(:,1), delta_p(:,2), delta_p(:,3), 'go');
xlabel('Reciever distance over time in 3D')
subplot(122)
plot(delta_pnorm)
xlabel('Euclidian distance between recievers (true val. 160 cm)')

%Plot the histogram drift over time
figure
subplot(121)
hist(delta_pnorm,30)
xlabel('relative drift over time')
subplot(122)
hist(delta_pnormH,30)
xlabel('relative horizontal drift over time')


