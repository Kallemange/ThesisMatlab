function [f1,f2, f3, f4]=plot_global_estimate(x1, x2, g1, g2, sets, eph1, eph2)
%Plot the position of the receivers based on the internal solution of the
%device, as well as the solution calculated through observation data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot1
%Global estimate in NED for receiver 1 and 2, own solution (rec1 & rec2)
%Global estimate in NED for receiver 1 and 2, internal solution (gps1 and gps2)

%Plot2
%Global estimate in ECEF for receiver 1 and 2, own solution (rec1 & rec2)
%Global estimate in ECEF for receiver 1 and 2, internal solution (gps1 and gps2)

%Plot3
%Difference in adjusted observation rec-sv and estimated distance rec-sv
%for rec1 and rec2. (Rec. position given as first reading gps1 and gps2)

%Plot4
%Difference in adjusted observation rec-sv and estimated distance rec-sv
%for rec1 and rec2. (Rec. position given current estimate)

%Plot5
%Histogram over difference in position from internal solution, position for
%rec2 interpolated around time for rec1
%Define reference position in ECEF and LLA-coordinates as the first reading
%of receiver 1

%Plot6
%Number of used satellites for receiver 1 and 2 per epoch

%Plot 8
%DOP Plots for the receivers

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
isGPS=any(string(g1.Properties.VariableNames)=="ecef_0_");
if isGPS
    pE=[g1.ecef_0_(1) g1.ecef_1_(1) g1.ecef_2_(1)];
    pL=[g1.lla_0_(1) g1.lla_1_(1) g1.lla_2_(1)];
else
    pL=[g1.lla0(1) g1.lla1(1) g1.lla2(1)];
    pE=lla2ecef(pL);
end

spheroid=wgs84Ellipsoid; %Spheroid model wgs84 for transformations
%Transform reading from ECEF-NED frame using the coordinates of the first
%reading of gps1 as reference
[xS, yS, zS]=ecef2ned(x1.xVec(:,1),x1.xVec(:,2),x1.xVec(:,3),pL(1),pL(2),pL(3),spheroid);
x1NED=[xS,yS,zS];
[xS, yS, zS]=ecef2ned(x2.xVec(:,1),x2.xVec(:,2),x2.xVec(:,3),pL(1),pL(2),pL(3),spheroid);
x2NED=[xS, yS, zS];
if isGPS
    [xS, yS, zS]=ecef2ned(g1.ecef_0_,g1.ecef_1_,g1.ecef_2_,pL(1),pL(2),pL(3),spheroid);
    g1NED=[xS,yS,zS];
    [xS, yS, zS]=ecef2ned(g2.ecef_0_,g2.ecef_1_,g2.ecef_2_,pL(1),pL(2),pL(3),spheroid);
    g2NED=[xS,yS,zS];
    g1ECEF=[g1.ecef_0_,g1.ecef_1_,g1.ecef_2_];
    g2ECEF=[g2.ecef_0_,g2.ecef_1_,g2.ecef_2_];
else
    g1NED=[g1.ned0 g1.ned1 g1.ned2]-[g1.ned0(1) g1.ned1(1) g1.ned2(1)];
    g2NED=[g2.ned0 g2.ned1 g2.ned2]-[g2.ned0(1) g2.ned1(1) g2.ned2(1)];
    g1ECEF=lla2ecef([g1.lla0 g1.lla1 g1.lla2], 'wgs84');
    g2ECEF=lla2ecef([g2.lla0 g2.lla1 g2.lla2], 'wgs84');
end
dirVec=["N", "E", "D"];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot1
f1=figure;
for i=1:3
    subplot(3,1,i)
    hold on
    plot(x1.tVec-x1.tVec(1),x1NED(:,i))
    plot(x2.tVec-x1.tVec(1), x2NED(:,i));
    leg1=["rec1", "rec2"];
    xlabelStr1="Time since startup [s], mean: "...
            +"x_1:"+num2str(round(mean(x1NED(:,i)),1))+", " ...
            +"x_2:"+num2str(round(mean(x2NED(:,i)),1))+", " ...
            +"\sigma_1:"+num2str(round(sqrt(var(x1NED(:,i))),1))+", "...
            +"\sigma_2:"+num2str(round(sqrt(var(x2NED(:,i))),1));
    if sets.plots.global.plotGPS
        leg1=["rec1", "rec2","gps1", "gps2"];            
        if isGPS
            plot(g1.ToWms/1000-x1.tVec(1), g1NED(:,i))
            plot(g2.ToWms/1000-x1.tVec(1), g2NED(:,i))
        else
            plot(g1.timeOfWeek-x1.tVec(1), g1NED(:,i))
            plot(g2.timeOfWeek-x1.tVec(1), g2NED(:,i))
        end
        xlabelStr1="Time since startup [s], mean: "...
            +"x_1:"+num2str(round(mean(x1NED(:,i)),1))+", " ...
            +"x_2:"+num2str(round(mean(x2NED(:,i)),1))+", " ...
            +"g_1:"+num2str(round(mean(g1NED(:,i)),1))+", " ...
            +"g_2:"+num2str(round(mean(g2NED(:,i)),1));
    end
    legend(leg1)
    xlabel(xlabelStr1)
    ylabel(dirVec(i))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot 2
f2=figure;
dirECEF=["x", "y", "z"];
for i=1:3
    subplot(3,1,i)
    hold on
    plot(x1.tVec-x1.tVec(1), x1.xVec(:,i)-pE(i))
    plot(x2.tVec-x1.tVec(1), x2.xVec(:,i)-pE(i));
    legendStr2=["rec1", "rec2"];
        xlabelStr="Time since startup [s], mean: "...
            +"x_1:"+num2str(round(mean(x1.xVec(:,i)-pE(i)),1))+", " ...
            +"x_2:"+num2str(round(mean(x2.xVec(:,i)-pE(i)),1));
    if sets.plots.global.plotGPS
        legendStr2=["rec1", "rec2", "gps1", "gps2"];
        xlabelStr="Time since startup [s], mean: "...
            +"x_1:"+num2str(round(mean(x1.xVec(:,i)-pE(i)),1))+", " ...
            +"x_2:"+num2str(round(mean(x2.xVec(:,i)-pE(i)),1))+", " ...
            +"g_1:"+num2str(round(mean(g1ECEF(:,i)-pE(i)),1))+", " ...
            +"g_2:"+num2str(round(mean(g2ECEF(:,i)-pE(i)),1));
        if isGPS
            plot(g1.ToWms/1000-x1.tVec(1), g1ECEF(:,i)-pE(i))
            plot(g2.ToWms/1000-x1.tVec(1), g2ECEF(:,i)-pE(i))
        else
            plot(g1.timeOfWeek-x1.tVec(1), g1ECEF(:,i)-pE(i))
            plot(g2.timeOfWeek-x1.tVec(1), g2ECEF(:,i)-pE(i))
        end
    end
    legend(legendStr2)
    xlabel(xlabelStr);
    ylabel(dirECEF(i))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot 3
f3=figure;
allsat=unique([x1.satID; x2.satID]);
distObsNorm(x2, allsat, "true", "rec1")
distObsNorm(x1, allsat, "true", "rec2")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f4=figure;
distObsNorm(x2, allsat, "est", "rec1")
distObsNorm(x1, allsat, "est", "rec2")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Figure 5
% if any(strcmp(g1.Properties.VariableNames,"ToWms"))
%     [t1idx, t2idx]=findT0toEnd(g1.ToWms,g2.ToWms);
% else
%     [t1idx, t2idx]=findT0toEnd(g1.timeOfWeek,g2.timeOfWeek);
% end
% [g1_inter, g2_inter]=interpolGPS(g1,g2, t1idx, t2idx);
% [x, y, z]=ecef2ned(g1_inter(:,1), g1_inter(:,2), g1_inter(:,3), pL(1), pL(2), pL(3), spheroid);
% g1_inter=[x, y, z];
% [x, y, z]=ecef2ned(g2_inter(:,1), g2_inter(:,2), g2_inter(:,3), pL(1), pL(2), pL(3), spheroid);
% g2_inter=[x, y, z];
% diffPos=g2_inter-g1_inter;
% figure
% for i=1:3
%    hold on
%    histogram(diffPos(:,i),'Normalization','probability', 'DisplayStyle', 'stairs')
% end
% legend("N", "E", "D")
% mu1=string(round(mean(diffPos), 1));
% sigma2=string(round(var(diffPos), 1));
% xlabel("N, E, D direction mean: "+mu1(1)+", "+mu1(2)+", "+mu1(3)+" [m]"+...
%        ", variance: "+sigma2(1)+", "+sigma2(2)+", "+sigma2(3))
% sgtitle("Histogram over distances between receivers from internal solution in NED [m]")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Figure 6
%Number of visible satellites for the receivers over time
figure
sgtitle("Number visible satellites for rec_1 and rec_2") 
plot(x1.visSV(:,1)-x1.visSV(1),x1.visSV(:,2))
hold on
plot(x2.visSV(:,1)-x1.visSV(1),x2.visSV(:,2))
legend("rec_1", "rec_2")
xlabel("Time since startup [s]")
ylabel("#Visible sv")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 7
% Plot all sv's active at a given time
activeSatsPerEpoch(x1,eph1, "rec1")
activeSatsPerEpoch(x2,eph2, "rec2")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 8
% Plot the DOP Values
f8=figure;
f8=plotDOP(x1, f8, 1);
f8=plotDOP(x2, f8, 2);
figure(f8);
sgtitle("DOP-values for receiver 1 and 2 over time")
end

function activeSatsPerEpoch(x,eph, rec)
figure
hold on
legVec="";
for i=1:length(x.satPos.pos)
    if ~isempty(x.satPos.pos{i})
        plot(x.satPos.pos{i}(:,1)-x.tVec(1),i*ones(size(x.satPos.pos{i}(:,1))) , '.')
        legVec(end+1)=string(num2str(eph(i)));
    end
end
legVec(1)=[];
leg=legend(legVec);
sgtitle("All active satellites per epoch "+rec)
xlabel("Time since startup")
end

function [g1_out, g2_out]=interpolGPS(g1, g2, t1, t2)
g1_out=[];
g2_out=[];
k=1;
L=t2(2)-t2(1);

if any(strcmp(g1.Properties.VariableNames, "ToWms"))
    g1_.ToW     = g1.ToWms;
    g1_.x       = g1.ecef_0_;
    g1_.y       = g1.ecef_1_;
    g1_.z       = g1.ecef_2_;
    g2_.ToW     = g2.ToWms;
    g2_.x       = g2.ecef_0_;
    g2_.y       = g2.ecef_1_;
    g2_.z       = g2.ecef_2_;
elseif any(strcmp(g1.Properties.VariableNames, "timeOfWeek"))
    g1_.ToW     = g1.timeOfWeek;
    g1_.x       = g1.ned0;
    g1_.y       = g1.ned1;
    g1_.z       = g1.ned2;
    g2_.ToW     = g2.timeOfWeek;
    g2_.x       = g2.ned0;
    g2_.y       = g2.ned1;
    g2_.z       = g2.ned2;
end
g1_out=zeros(t1(2)-t1(1), 3);
g2_out=zeros(t1(2)-t1(1), 3);
idx_to_remove=[];
for i=t1(1):t1(2)
    t=g1_.ToW(i);
    g1_t    = [g1_.x(i) g1_.y(i) g1_.z(i)];
    while k<L
        if g2_.ToW(k+1)>t
            break
        else
            k=k+1;
        end
    end
    g2t_low         = g2_.ToW(k);
    g2t_high        = g2_.ToW(k+1);
    % Calculate the distance between observation in time, if both r2
    % low and high >threshold -> discard observation
    if (all(abs([g2t_low g2t_high]-t)>0.2))
        idx_to_remove(end+1)=i;
        continue
    end
    if (g2t_low==g2t_high)
        w                  = 0.5*[1 1];
    else
        w                  = [(	t-g2t_low) (g2t_high-t)]/(g2t_high-g2t_low);
    end
    if (sum(w)~=1||any(w<0))
        keyboard
    end
    g2_out(i,:) = sum([g2_.x(k:k+1) g2_.y(k:k+1) g2_.z(k:k+1)].* ...
                                 [w(2)*ones(1,3); w(1)*ones(1,3)]);
    g1_out(i,:) = g1_t;
end
g1_out(idx_to_remove,:)=[];
g2_out(idx_to_remove,:)=[];
end
function [t1idx, t2idx]=findT0toEnd(T1, T2)
t0          = max(T1(1),T2(1));
t_end       = min(T1(end),T2(end));
t1min       = find(T1>=t0, 1, 'first');
t1max       = find(T1<=t_end, 1, 'last');
t2min       = find(T2>=t0, 1, 'first');
t2max       = find(T2<=t_end, 1, 'last');
t1idx       = [t1min t1max];
t2idx       = [t2min t2max];

end
function distObsNorm(x, allsats, idx, recNo)
%Plot the distance between norm-obs where norm:= ||p_sv-p_rec|| and obs is
%pseudorange observation adjusted for sv and receiver clock bias
if strcmp(idx, "true")
    posidx=4;
elseif strcmp(idx, "est")
    posidx=5;
end

[~, imgNo]=intersect(allsats, x.satID);
obs=x.obsVec.obsAdj;
    if (length(allsats)<(floor(sqrt(length(allsats))))*ceil(sqrt((length(allsats)))))
        rows=floor(sqrt(length(allsats)));
        cols=ceil(sqrt((length(allsats))));
    else
        rows=ceil(sqrt((length(allsats))));
        cols=rows;
    end
    for i=1:length(obs)
        subplot(rows, cols,imgNo(i))
        if ~isempty(obs{i})
            hold on
            plot(obs{i}(:,1)-x.tVec(1),obs{i}(:,2)-x.satPos.elAz{i}(:,posidx))
            if recNo=="rec2"
                legend("rec1", "rec2")
            end
        else
            plot(0)
        end
            xlabel("satID: "+string(allsats(i)))    
    end
end

function fig=plotDOP(x, fig, idx)
    %Plot the DOP-values defined as:
    %HDOP=sqrt(H(1,1)^2+H(2,2)^2)
    %VDOP=sqrt(H(3,3)^2)
    %TDOP=sqrt(H(4,4)^2)
    %GDOP=sqrt(H(1,1)^2+H(2,2)^2+sqrt(H(3,3)^2+H(4,4)^2))
    DOP=[x.Hvec{:}];
    HDOP=sqrt(DOP(1,1:4:end).^2+DOP(2,2:4:end).^2);
    VDOP=DOP(3,3:4:end);
    TDOP=DOP(4,4:4:end);
    GDOP=sqrt(DOP(1,1:4:end).^2+DOP(2,2:4:end)+DOP(3,3:4:end).^2+DOP(4,4:4:end).^2);
    figure(fig)
    subplot(2,1,idx)
    hold on
    plot(x.tVec, HDOP, x.tVec,VDOP, x.tVec,TDOP,x.tVec,GDOP)
    leg=legend("HDOP", "VDOP", "TDOP", "GDOP");
    leg.Title.String="rec"+num2str(idx);
    xlabel("Time since startup, mean HDOP: "+num2str(round(mean(HDOP),2))+", VDOP:"+...
                                        num2str(round(mean(VDOP),2)))
end