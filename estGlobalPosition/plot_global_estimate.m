function [f1, f2, f3]=plot_global_estimate(x1, x2, g1, g2, sets)
%Plot the position of the receivers based on the internal solution of the
%device, as well as the solution calculated through observation data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot1
%Global estimate for receiver 1 and 2, own solution (rec1 & rec2)
%Global estimate for receiver 1 and 2, internal solution (gps1 and gps2)
%Plot2
%Difference in adjusted observation rec-sv and estimated distance rec-sv
%for rec1 and rec2. (Rec. position given as first reading gps1 and gps2)

%Define reference position in ECEF and LLA-coordinates as the first reading
%of receiver 1
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
else
    g1NED=[g1.ned0 g1.ned1 g1.ned2]-[g1.ned0(1) g1.ned1(1) g1.ned2(1)];
    g2NED=[g2.ned0 g2.ned1 g2.ned2]-[g2.ned0(1) g2.ned1(1) g2.ned2(1)];
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
    if isGPS
        plot(g1.ToWms/1000-x1.tVec(1), g1NED(:,i))
        plot(g2.ToWms/1000-x1.tVec(1), g2NED(:,i))
    else
        plot(g1.timeOfWeek-x1.tVec(1), g1NED(:,i))
        plot(g2.timeOfWeek-x1.tVec(1), g2NED(:,i))
    end
    legend("rec1", "rec2", "gps1", "gps2")
    xlabel("Time since startup [s], mean: "...
            +"x_1:"+num2str(round(mean(x1NED(:,i)),1))+", " ...
            +"x_2:"+num2str(round(mean(x2NED(:,i)),1))+", " ...
            +"g_1:"+num2str(round(mean(g1NED(:,i)),1))+", " ...
            +"g_2:"+num2str(round(mean(g2NED(:,i)),1)));
    ylabel(dirVec(i))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Figure 2
f2=figure;
allsat=unique([x1.satID; x2.satID]);
distObsNorm(x2, allsat, "true")
distObsNorm(x1, allsat, "true")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f3=figure;
distObsNorm(x2, allsat, "est")
distObsNorm(x1, allsat, "est")

end

function distObsNorm(x, allsats, idx)
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
        
        else
            plot(0)
        end
            xlabel("satID: "+string(allsats(i)))    
    end
    end
