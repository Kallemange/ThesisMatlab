function plot_global_estimate(x1, x2, g1, g2)
figure
pE=[g1.ecef_0_(1) g1.ecef_1_(1) g1.ecef_2_(1)];
pL=[g1.lla_0_(1) g1.lla_1_(1) g1.lla_2_(1)];
for i=1:3
    
    subplot(3,1,i)
    hold on
    plot(x1.tVec(2:end)-x1.tVec(1),x1.xVec(:,i)-pE(i), '*', 'MarkerSize', 2)
    plot(g1.ToWms/1000-x1.tVec(1), g1.("ecef_"+num2str(i-1)+"_")-pE(i))
    plot(x2.tVec-x1.tVec(1), x2.xVec(:,i)-pE(i), '*','MarkerSize', 2);
    plot(g2.ToWms/1000-x1.tVec(1), g2.("ecef_"+num2str(i-1)+"_")-pE(i))
    legend("rec1", "gps1", "rec2", "gps2")
    xlabel("Time since startup")
end
sgtitle("Position difference in ECEF-coordinates")

figure
for i=1:3    
    subplot(3,1,i)
    hold on
    plot(x1.tVec(2:end)-x1.tVec(1),x1.llaVec(:,i)-g1.("lla_"+num2str(i-1)+"_")(1));
    plot(x2.tVec-x1.tVec(1),x2.llaVec(:,i)-g1.("lla_"+num2str(i-1)+"_")(1));
    legend("rec1", "rec2")
    xlabel("Time since startup")
end
sgtitle("Position difference in lla-coordinates")

