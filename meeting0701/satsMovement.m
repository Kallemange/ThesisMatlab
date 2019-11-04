function satsMovement(x, posRecECEF, week, eph)
%För data 0706 datetime är UTC+2h (kl. 15->kl 17 på in-the-sky)


%Transformera positionerna i ECEF till positioner i NED till elev-azim
figure
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
            polarplot(deg2rad(xs(:,2)), xs(:,3), '.');
        end

        hold on
end
polarplot(0,90) %To get it all in 0-90 values instead of max elevation
legend((satLegend([x.satID<=32])))
t0_ToW=x.tVec(1);
t0=datetime(x.tVec(1)+315964800+604800*week,'ConvertFrom','posixtime');
%[~, ~, tend]=UTC_in_sec2GPStime(x.tVec(end));
tend=datetime(x.tVec(end)+315964800+604800*week,'ConvertFrom','posixtime');

t0title=t0.Year+"Y " +t0.Month +"M " +t0.Day +"D "+ t0.Hour +"H " +t0.Minute+"M " +t0.Second+ "S ";
tendtitle=tend.Year+"Y " +tend.Month +"M " +tend.Day +"D "+ tend.Hour+"H " +tend.Minute+"M " +tend.Second+ "S ";
sgtitle({strcat("satellites movement over the sky, starting at: ",t0title),...
    strcat("ending at: ", tendtitle)})
hold off
%[satIDVec' azVec' elVec']
fig2=figure;
sgtitle({strcat("satellites movement over the sky, starting at: ",t0title),...
    strcat("ending at: ", tendtitle)})
fig3=figure;
sgtitle({strcat("satellites movement over the sky, starting at: ",t0title),...
    strcat("ending at: ", tendtitle)})
legend2=[];
for i=1:length(x.satPos.elAz)
     xs=x.satPos.elAz{i};
     figure(fig2);
     if(~isempty(xs))
        plot((xs(:,1)-xs(1))/60, xs(:,3))              % plot the data,
        hold on;
        figure(fig3);
        plot((xs(:,1)-xs(1))/60, xs(:,2))
        hold on
        legend2(end+1)=x.satID(i);
    end
end
figure(fig2);
ylabel('elevation[deg]')
xlabel('time[min]')
legend(string(num2str(legend2')), 'AutoUpdate','off')
noLines=(x.tVec(end)-x.tVec(1))/600;
lineAtEach10min(t0, noLines, [0 90])
figure(fig3);
ylabel('azimuth[deg] from north')
xlabel('time[min]')
legend(string(num2str(legend2')), 'AutoUpdate','off')
lineAtEach10min(t0, noLines, [0 360])
fig4=figure;
sgtitle({strcat("satellites movement over the sky, starting at: ",t0title),...
    strcat("ending at: ", tendtitle)})
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

fig5=figure;
hold on
L=6*3600;
t=x.tVec(1):x.tVec(1)+L;
Xs.pos=zeros(L,3);
Xs=repmat(Xs,1, length(eph));
for i=1:length(t)
    for j=1:length(eph)
        [x, y, z]=get_satellite_position(eph(j), t(i));
        Xs(j).pos(i,:)=[x,y,z];
    end
end
legVec=[];
for j=1:length(eph)
    [~, el]=ecef2elaz(Xs(j).pos,posRecECEF);
    idx=el>0;
    plot((t(idx)-t(1))/600,el(idx), 'LineWidth', 3);
    legVec(end+1)=eph(j).sat;
end
lineAtEach10min(t0, noLines, [0 90])
sgtitle({strcat("Satellites elevation, starting at: ",t0title),...
    strcat("ending at: ", tendtitle)})
legend(string(num2str(legVec')))
ylabel("Elevation [deg]")
xlabel("Time [s]")
