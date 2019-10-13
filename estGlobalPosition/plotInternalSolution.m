function plotInternalSolution(x1, x2, dist, dir, saveToFile)
%Function to provide plots of global positional fixes from the internal
%solution of the receivers. Plots are showing:
%1) Histogram of Global position wrt the mean position of receiver 1 in NED-frame 
%2) Radial distance over time between receivers
%3) Distance in NED over time between receivers
%IN
%x1, table:        Table containing data from gps/ins log for receiver 1
%x2, table:        Table containing data from gps/ins log for receiver 2
%dist, string:     True distance between receivers
%dir,  string:     Direction of distance receivers (N/E/D)
%saveToFile, bool: Save figure to file (true for save)
%saveToFile 
%OUT
%N/A

wgs84 = wgs84Ellipsoid;
%Transform the position to NED-coordinates wrt the first position of rec1
[x y z]=ecef2ned(x1.ecef_0_, x1.ecef_1_, x1.ecef_2_,x1.lla_0_(1), x1.lla_1_(1), x1.lla_2_(1), wgs84);
rec1.pos=[x y z];
rec1.t=x1.ToWms;
[x y z]=ecef2ned(x2.ecef_0_, x2.ecef_1_, x2.ecef_2_,x1.lla_0_(1), x1.lla_1_(1), x1.lla_2_(1), wgs84);
rec2.pos=[x y z];
rec2.t=x2.ToWms;

%p0=rec1.pos(1,:);
labelVec = ['N-direction'; 'E-direction'; 'D-direction'];
numVec   = ['0', '1', '2'];
fig=figure;
sgtitle(strcat("Histogram drift individual estimates, true distance ", num2str(dist),"m in ", dir,"-direction"))
for i=1:3
    subplot(4,1,i)
    histogram(rec1.pos(:,i)-mean(rec1.pos(:,i)),'Normalization','probability', 'DisplayStyle', 'stairs');
    hold on
    histogram(rec2.pos(:,i)-mean(rec1.pos(:,i)),'Normalization','probability', 'DisplayStyle', 'stairs');
    legend('1', '2')
    %Mean and variance of estimates, mean2 in relation to mean1
    var1=var(rec1.pos(:,i));
    var2=var(rec2.pos(:,i));
    mu1=mean(rec1.pos(:,1));
    mu2=mean(rec2.pos(:,i)-mu1);
    xlabel(strcat(labelVec(i,:), ' mean 1:=0[m], \sigma^2_1= ',num2str(round(var1,2)), ...
                                 ', mean 2= ', num2str(round(mu2,2)), '[m]', ...
                                ', \sigma^2_2= ', num2str(round(var2,2))))
end

distNED=interpol(rec1, rec2);

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

if saveToFile
    figname=strcat("GPShist",num2str(dist),"m",dir);
    saveas(fig, strcat('Figures/',figname), 'epsc')
end

end

function [rNED]=interpol(x1,x2)
%IN
%x1, table:     receiver1 data
%x2, table:     receiver2 data
%OUT
%rNED, double[n, 3]: distance between receivers in NED-directions

%Interpolates position for receiver2 such that distance is calculated at
%same time for both receivers using time of receiver 1 as reference.

%Find first valid measurement for both receivers
if x1.t(1)<=x2.t(1)
    t0=x2.t(1);
else
    t0=x1.ToWms(1);
end
%Find last valid measurement for both reveicers
if x1.t(end)<=x2.t(end)
    t_end=x1.t(end);
else
    t_end=x2.t(end);
end
%Both vectors for indices when receivers are active
t1_start=find(x1.t>=t0, 1, 'first');
t1_end=find(x1.t<=t_end, 1, 'last');
t2=find(x2.t>=t0);
t2=find(x2.t(t2)<=t_end);
t1=t1_start:t1_end;

%For all valid indices of x1, interpolate the values of x2
j=1;
rNED=[];
for i=t1
    t_curr=x1.t(i);
    while (x2.t(j)<t_curr&& x2.t(j)<t_end)
        j=j+1;
    end
    if x2.t(j)==t_curr
       rNED(end+1,:)=x1.pos(i,:)-x2.pos(j,:);
    elseif (x2.t(j)>t_curr&&j>1)
        %This is interpolation part, find the interval length, and the
        %corresponding weights based on proximity (in time) to measurement
        interval=x2.t(j)-x2.t(j-1);
        w=1-[x2.t(j)-t_curr, t_curr-x2.t(j-1)]/interval;
        r_interpolated=x1.pos(i,:)-[w(1)*x2.pos(j,:)+ w(2)*x2.pos(j-1,:)];
        rNED(end+1,:)=r_interpolated;
    end
    
end

end