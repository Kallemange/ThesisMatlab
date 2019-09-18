
function calcAllData(x)
%meeting 0701
%Förväntat avstånd, baserat på position från INS:
posRec=lla2ecef([59.3530026, 18.0731326, 27.71], 'wgs84');
close all
figure(5)
h1=line(0,0);
h2=line(0,0);
h3=line(0,0);
h4=line(0,0);
for i=1:length(x.satID)
    %Difference (satellite->rec) with adjusted position of transmission
    if(~isempty(x.satPos.pos{i}))
        trueD=vecnorm(x.satPos.pos{i}(:,2:end)-posRec,2,2);
    else
        h1(end+1)=line(0,0);
        h2(end+1)=line(0,0);
        h3(end+1)=line(0,0);
        h4(end+1)=line(0,0);
        continue
    end
    %The unadjusted distance between (sat->rec)
    trueD_unadj=vecnorm(x.satPos.pos_unadj{i}(:,2:end)-posRec,2,2);
    
    %The unadjusted difference between (satellite->rec) and obs
    difference_unadj=trueD_unadj-x.obsVec.obs{i}(:,2);
    
    h1(end+1)=line(x.obsVec.obs{i}(:,1), difference_unadj);
    
    %The adjusted difference between trueD-obs wrt position of transmission
    difference_true_obs_unadj=trueD-x.obsVec.obs{i}(:,2);
    
    h2(end+1)=line(x.obsVec.obs{i}(:,1), difference_true_obs_unadj);

    %The adjusted difference between trueD-obs wrt receiver clock
    difference_true_obs_adj=trueD-x.obsVec.obsAdj{i}(:,2);
    
    h3(end+1)=line(x.obsVec.obsAdj{i}(:,1), difference_true_obs_adj);

    %The adjusted difference between (satellite->rec) and observation wrt
    %transmission time
    difference_true_obs_sat_unadj=trueD_unadj-x.obsVec.obsAdj{i}(:,2);
    h4(end+1)=line(x.obsVec.obsAdj{i}(:,1), difference_true_obs_sat_unadj);
    
end

sats=string(num2str(x.satID));
t0=x.obsVec.t(1);
for i=1:length(x.satID)
    
    if(h1(i).XData==0)
        sats(i)=[];
        continue
    else
        figure(1)
        hold on
        plot(h1(i).XData-t0,h1(i).YData)
        figure(2)
        hold on
        plot(h2(i).XData-t0, h2(i).YData)
        figure(3)
        hold on
        plot(h3(i).XData-t0, h3(i).YData)
        figure(4)
        hold on
        plot(h4(i).XData-t0, h3(i).YData)
    end
end

figure(1)
sgtitle('obs unadjusted, satellite position unadjusted')
legend(sats)
figure(2)
sgtitle('obs unadjusted, satellite position adjusted')
legend(sats)
figure(3)
sgtitle('obs adjusted, satellite position adjusted')
legend(sats)
figure(4)
sgtitle('obs adjusted, satellite position unadjusted')
legend(sats)

close(figure(5))
%%
figure(5)
sgtitle('Satellite trajectories in ECEF')
plot3(posRec(1), posRec(2), posRec(3), 'o')
hold on
for i=1:length(x.satID)
    X=x.satPos.pos{i};
    if(~isempty(X))
        plot3(X(:,2), X(:,3), X(:,4), '*');
    end
    
end
if sats(1)~="rec"
    sats=["rec"; sats];
end
legend(sats)
end
%Resultat:
%Skillnaden i satellitposition map sändtid <100 m, kan ej förklara ett
%konstant bias om >1000 m.
%(difference_true_obs_sat_unadj-difference_true_obsAdj)
%Stor skillnad i mottagarpositionens 