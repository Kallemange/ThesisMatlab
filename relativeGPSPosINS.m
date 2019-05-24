function relativeGPSPosINS1(T1, T2, CS, fixed, dist, dir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INS Position measurements, arguments:
% Log1, Log2, coordinate system, isfixed (1/0), distance
% Calculations performed:
% Set first and last valid measurement
% Find the valid indices
% If the CS is LLA transform to carthesian
% Shift position to origin
% Calculate the distances between position 1 and 2 over time
% Plotting the resp. positions over time per axes, as well as the 
% Euclidean distance and histogram over time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Decide for first measurement (i.e. which one started last)
if (T1.timeOfWeek(1)< T2.timeOfWeek(1))
    origin=[T2.(strcat(CS,'0'))(1) T2.(strcat(CS,'1'))(1) T2.(strcat(CS,'2'))(1)];
    t0=T2.timeOfWeek(1);
else
    origin=[T1.(strcat(CS,'0'))(1) T1.(strcat(CS,'1'))(1) T1.(strcat(CS,'2'))(1)];
    t0=T1.timeOfWeek(1);
end

%Decide last measurement (which one ended first)
if (T1.timeOfWeek(end)<T2.timeOfWeek(end))
    t_end=T1.timeOfWeek(end);
else
    t_end=T2.timeOfWeek(end);
end

%Find the valid indices
t_idx1=find(T1.timeOfWeek>=t0&T1.timeOfWeek<=t_end);
t_idx2=find(T2.timeOfWeek>=t0&T2.timeOfWeek<=t_end);


%If the CS is LLA transform to carthesian
%Shift position to origin
if CS=='lla'
    P1shift=zeros(size(T1,1),3);
    P2shift=zeros(size(T2,1),3);
    [P1shift(:,1), P1shift(:,2), P1shift(:,3)]=geodetic2ned(T1.(strcat(CS,'0')), T1.(strcat(CS,'1')), T1.(strcat(CS,'2')),...
                                               origin(1), origin(2), origin(3),wgs84Ellipsoid);
    [P2shift(:,1), P2shift(:,2), P2shift(:,3)]=geodetic2ned(T2.(strcat(CS,'0')), T2.(strcat(CS,'1')), T2.(strcat(CS,'2')),...
                                               origin(1), origin(2), origin(3),wgs84Ellipsoid);
else
    P1shift=[T1.(strcat(CS,'0')) T1.(strcat(CS,'1')) T1.(strcat(CS,'2'))]-origin;
    P2shift=[T2.(strcat(CS,'0')) T2.(strcat(CS,'1')) T2.(strcat(CS,'2'))]-origin;
    
end


%Calculate the distances between position 1 and 2 over time
[distances distNED]=interpol(T1,T2,origin, t0, t_idx1, t_idx2, CS);

%Plotting the resp. positions over time per axes, as well as the 
%Euclidean distance over time
%{
figure
hold on
plot3(P1shift(:,1), P1shift(:,2),P1shift(:,3), 'b-*')
plot3(0, 0, 0, 'kO', 'MarkerSize', 12, 'LineWidth', 4)
plot3(P2shift(:,1), P2shift(:,2), P2shift(:,3), 'r-o')
view(3)
if (fixed==1)
    xlabel(['GPS Position estimates while stationary, distance: ' num2str(dist),'m'])
    myTitle=strcat('Distance per axes, with fixed distance ', num2str(dist), 'm');
elseif (fixed==0)
   xlabel('GPS Position estimates while moving, fixed distance')
   myTitle='';
end
hold off


figure
sgtitle(myTitle)
subplot(411)
hold on
plot(T1.timeOfWeek(t_idx1)-t0,  P1shift(t_idx1,1))
plot(T2.timeOfWeek(t_idx2)-t0, P2shift(t_idx2,1))
xlabel("Drift in direction N")
ax1 = gca;
subplot(312)
hold on
plot(T1.timeOfWeek(t_idx1)-t0,  P1shift(t_idx1,2))
plot(T2.timeOfWeek(t_idx2)-t0, P2shift(t_idx2,2))
xlabel("Drift in direction E")
ax2 = gca;
subplot(313)
hold on
plot(T1.timeOfWeek(t_idx1)-t0,  P1shift(t_idx1,3))
plot(T2.timeOfWeek(t_idx2)-t0, P2shift(t_idx2,3))
xlabel("Drift in direction D")
ax3 = gca;
linkaxes([ax1 ax2 ax3]);
figure
subplot(211)
plot(distances(:,1), distances(:,2))
xlabel("Euclidean distance vs time");
subplot(212)
hist(distances(:,2),20);
xlabel('Histogram over |distance|')
%}
%Histogram over individual drift
labelVec = ['N-direction'; 'E-direction'; 'D-direction'];
numVec   = ['0', '1', '2'];
figure
sgtitle(strcat('Histogram drift individual estimates, true distance ', 32,num2str(dist),'m in ', 32,labelVec(dir,:)))
for i=1:3
    subplot(4,1,i)
    NEDX=(strcat('ned', numVec(i)));
    histogram(T1.(NEDX)-mean(T1.(NEDX)),'Normalization','probability', 'DisplayStyle', 'stairs');
    hold on
    histogram(T2.(NEDX)-mean(T1.(NEDX)),'Normalization','probability', 'DisplayStyle', 'stairs');
    legend('1', '2')
    xlabel(strcat(labelVec(i,:), ' mean 1:=0[m], \sigma^2_1= ',num2str(round(var(T1.(NEDX)),2)), ...
        ', mean 2= ', num2str(round(mean(T2.(NEDX)-mean(T1.(NEDX))),2)), '[m]', ...
            ', \sigma^2_2= ', num2str(round(var(T2.(NEDX)),2))))
end

%Histogram over relative distance in each direction
for i=1:3
subplot(414)
hold on
histogram(distNED(:,i),'Normalization','probability', 'DisplayStyle', 'stairs');
end
legend('N-direction', 'E-direction', 'D-direction')
xlabel(strcat('Relative distance in N-E-D directions, mean: ', ...
    num2str(round(mean(distNED(:,1)),2)), ', ', ...
    num2str(round(mean(distNED(:,2)),2)), ', ', ...
    num2str(round(mean(distNED(:,3)),2)), '[m], ', ...
    ' \sigma^2: ', ...
    num2str(round(var(distNED(:,1)),2)), ', ', ...
    num2str(round(var(distNED(:,2)),2)), ', ', ...
    num2str(round(var(distNED(:,3)),2))))

