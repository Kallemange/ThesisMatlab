function satsMovement(x, posRec, posRecECEF)
%F�r data 0706 datetime �r UTC+2h (kl. 15->kl 17 p� in-the-sky)


%Transformera positionerna i ECEF till positioner i NED till elev-azim
close all
ax=polaraxes;
ax.ThetaDir='clockwise';
ax.ThetaZeroLocation='top';
ax.RDir='reverse';
rticks(ax, [0:10:90])
hold on
%satLegend=string(num2str(x.satID([x.satID<=32])));
satLegend=string(num2str(x.satID));
for i=1:length(x.satPos.elAz)
    xs=x.satPos.elAz{i};   
    if(~isempty(xs)&&str2num(satLegend(i))<=32)
        text(deg2rad(xs(1,2)),xs(1,3),satLegend(i))
        if(any(xs(:,3))<0)
            keyboard
        end

    else
        xs=zeros(1,4);
    end
        if x.satID(i)<=32
            polarplot(deg2rad(xs(:,2)), xs(:,3), '*');
        end

        hold on
end
polarplot(0,90) %To get it all in 0-90 values instead of max elevation
legend((satLegend([x.satID<=32])))
[~, t0_ToW, t0]=UTC_in_sec2GPStime(x.tVec(1));
[~, ~, tend]=UTC_in_sec2GPStime(x.tVec(end));

t0title=t0(1)+"Y " +t0(2) +"M " +t0(3) +"D "+ t0(4) +"H " +t0(5) +"M " +t0(6)+ "S ";
tendtitle=tend(1)+"Y " +tend(2) +"M " +tend(3) +"D "+ tend(4) +"H " +tend(5) +"M " +tend(6)+ "S ";
sgtitle({strcat("satellites movement over the sky, starting at: ",t0title),...
    strcat("ending at: ", tendtitle)})
hold off
%[satIDVec' azVec' elVec']
figure(2)
sgtitle({strcat("satellites movement over the sky, starting at: ",t0title),...
    strcat("ending at: ", tendtitle)})

legend2=[];
for i=1:length(x.satPos.elAz)
     xs=x.satPos.elAz{i};
     subplot(3,1,1)
     if(~isempty(xs))
        %c=datenum(t(:,4:end), 'HH:MM:SS');  % convert date into a number to plot it
        plot((xs(:,1)-xs(1))/60, xs(:,3))              % plot the data,
        hold on;
        subplot(3,1,2)
        plot((xs(:,1)-xs(1))/60, xs(:,2))
        hold on
        legend2(end+1)=x.satID(i);
    end
end
subplot(3,1,1)
ylabel('elevation[deg]')
xlabel('time[min]')
legend(string(num2str(legend2')), 'AutoUpdate','off')
noLines=(x.tVec(end)-x.tVec(1))/600;
lineAtEach10min(t0, noLines, [0 90])
subplot(3,1,2)
ylabel('azimuth[deg] from north')
xlabel('time[min]')
legend(string(num2str(legend2')), 'AutoUpdate','off')
lineAtEach10min(t0, noLines, [0 360])
subplot(3,1,3)
hold on
dist_min=2e7;
dist_max=2.5e7;
for i=1:length(x.satPos.pos)
    
    xs=x.satPos.pos{i};
    if(~isempty(xs))
        distance_sat_rec=vecnorm(xs(:,2:4)-posRecECEF, 2,2);
        if min(distance_sat_rec)<dist_min
            dist_min=min(distance_sat_rec);
        end
        if max(distance_sat_rec)>dist_max
            dist_max=max(distance_sat_rec);
        end
        plot((xs(:,1)-t0_ToW)/60, distance_sat_rec);
    end
        
end
lineAtEach10min(t0, noLines, [dist_min-1000 dist_max+1000])
legend(string(num2str(legend2')), 'AutoUpdate','off');
ylabel('Distance [m]')
hold off

figure(3)
hDOP=[];
vDOP=[];
for i=1:length(x.Hvec)
    hDOP(end+1)=sqrt(x.Hvec{i}(1,1)+x.Hvec{i}(2,2));
    vDOP(end+1)=sqrt(x.Hvec{i}(3,3));
end
subplot(2,1,1)
plot((x.tVec(1:length(hDOP))-x.tVec(1))/60,hDOP);
lineAtEach10min(t0, noLines, [0 max(hDOP)])
xlabel("hDOP over time")
subplot(2,1,2)
plot(((x.tVec(1:length(vDOP))-x.tVec(1)))/60,vDOP);
lineAtEach10min(t0, noLines, [0 max(vDOP)])
xlabel("vDOP over time")

