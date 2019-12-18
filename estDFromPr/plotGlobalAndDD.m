function plotGlobalAndDD(x1, x2, t1,t2, t, r_ab, baseline, dir, sim, bias, pL)
spheroid=wgs84Ellipsoid; %Spheroid model wgs84 for transformations
%Transform reading from ECEF-NED frame using the coordinates of the first
%reading of gps1 as reference
[xS, yS, zS]=ecef2ned(x1.xVec(:,1),x1.xVec(:,2),x1.xVec(:,3),pL(1),pL(2),pL(3),spheroid);
x1NED=[xS,yS,zS];
[xS, yS, zS]=ecef2ned(x2.xVec(:,1),x2.xVec(:,2),x2.xVec(:,3),pL(1),pL(2),pL(3),spheroid);
x2NED=[xS, yS, zS];

if strcmp(dir, "N")
    MSE_global=round(calcRMSE((x1NED(t1,:)-x2NED(t2,:))', [baseline,0,0]'),1);
    %MSE_DD=round(mean(vecnorm(abs(r_ab)-[baseline 0 0]')),1);
    [a, b, c]=ned2ecef(0, 0, 0, pL(1), pL(2), pL(3), wgs84Ellipsoid);
    r1=[a b c]';
    [a b c]=ned2ecef(baseline,0, 0, pL(1), pL(2), pL(3), wgs84Ellipsoid);
    r2=[a, b, c]';
    %MSE_DD=round(calcRMSE(r_ab, [baseline 0 0]'),1);
    MSE_DD=round(calcRMSE(r_ab, [r1-r2]),1);
elseif strcmp(dir, "E")
    MSE_global=round(calcRMSE((x1.xVec(t1,:)-x2.xVec(t2,:))', [0 baseline 0]'),1);
    %MSE_DD=round(mean(vecnorm(abs(r_ab)-[baseline 0 0]')),1);
    [a, b, c]=ned2ecef(0, 0, 0, pL(1), pL(2), pL(3), wgs84Ellipsoid);
    r1=[a b c]';
    [a b c]=ned2ecef(0, baseline, 0, pL(1), pL(2), pL(3), wgs84Ellipsoid);
    r2=[a, b, c]';
    MSE_DD=round(calcRMSE(r_ab, [r1-r2]),1);
    %MSE_global=round(mean(vecnorm(abs(x1.xVec(t1,:)-x2.xVec(t2,:))-[0 baseline 0],2,2)),1);
    %MSE_DD=round(mean(vecnorm(abs(r_ab)-[0 baseline 0]')),1);
end

fig=figure;
ax1=subplot(211);

plot(x1.tVec(t1)-x1.tVec(t1(1)), vecnorm(x1.xVec(t1,:)-x2.xVec(t2,:),2,2))
hold on
plot(x1.tVec(t1)-x1.tVec(t1(1)), ones(1,length(t1))*baseline)
title("Relative global fix", 'fontSize', 16)
xlabel("mean: "+ num2str(round(mean(vecnorm(x1.xVec(t1,:)-x2.xVec(t2,:),2,2)),1))+...
       ", RMS: "+ num2str(MSE_global), 'fontSize', 16)
ax2=subplot(212);
plot(t-t(1),vecnorm(r_ab))
hold on
plot(t-t(1), ones(1,length(r_ab))*baseline)
title("DD-relative position",'fontSize', 16)
xlabel("mean: "+ num2str(round(mean(vecnorm(r_ab)),1))+...
       ", RMS: "+num2str(MSE_DD),'fontSize', 16)
linkaxes([ax1 ax2])
if strcmp(sim, "sim")
    %sgtitle("Norm of difference in position for simulated data using bias "+num2str(bias),'fontSize', 18)
else
    sgtitle("Norm of difference in position for observation data", 'fontSize', 18)
end
if strcmp(sim, "sim")
    saveas(fig, "Images/RMS/"+dir+sim+num2str(bias), 'epsc')
    saveas(fig, "Images/RMS/"+dir+sim+num2str(bias), 'fig')
else
    saveas(fig, "Images/RMS/"+dir+sim, 'epsc')
    saveas(fig, "Images/RMS/"+dir+sim, 'fig')
end
end

function RMSE=calcRMSE(R, D)
RMSE=sqrt(mean(vecnorm((abs(R)-abs(D)).^2)));
%E=abs(R)-abs(D);
%SE=vecnorm(E.^2);
%MSE=mean(SE);
%RMSE=sqrt(MSE);
end