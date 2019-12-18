function plotInternalAndDD(r, t, g1, g2, dir)
%Plot the histogram/behavior over time for DD relative estimates and
%onboard solution in NED-frame
    [t1GPS, t2GPS]=matchRecTimeGPS(g1,g2);
    spheroid=wgs84Ellipsoid;
    p0=[g1.ecef_0_(1) g1.ecef_1_(1) g1.ecef_2_(1)];
    p0LLA=[g1.lla_0_(1) g1.lla_1_(1) g1.lla_2_(2)];
    t0=g1.ToWms(1)/1000;
    rec2ECEF=p0'+r;
    spheroid=wgs84Ellipsoid;
    [N,E,D]=ecef2ned(rec2ECEF(1,:)', rec2ECEF(2,:)', rec2ECEF(3,:)', p0LLA(1), p0LLA(2), p0LLA(3),spheroid);
    r_abNED=[N,E,D]';
    [N,E,D]=ecef2ned(g1.ecef_0_(t1GPS), g1.ecef_1_(t1GPS), g1.ecef_2_(t1GPS), p0LLA(1), p0LLA(2), p0LLA(3),spheroid);
    g1NED=[N, E, D];
    [N,E,D]=ecef2ned(g2.ecef_0_(t2GPS), g2.ecef_1_(t2GPS), g2.ecef_2_(t2GPS), p0LLA(1), p0LLA(2), p0LLA(3),spheroid);
    g2NED=[N,E,D];
    NEDStr=["N", "E", "D"];
    fig=figure;
    for i=1:3
        subplot(3,1,i)
        plot(t-t0,r_abNED(i,:))
        hold on
        plot(g1.ToWms(t1GPS)/1000-t0,   g2NED(:,i)-g1NED(:,i))    
        legend("DD", "onboard", 'fontSize', 10)
        ylabel("\Delta"+NEDStr(i), 'fontSize', 14)
        xlabel("Time since startup, [s]", 'fontSize', 14)
    end
    %sgtitle("Distance over time, DD estimate and onboard solution, "+ dir+"-direction")
    saveas(fig, strcat('Figures/InternalAndDD/', dir), 'epsc')
    saveas(fig, strcat('Figures/InternalAndDD/', dir), 'fig')
    fig2=figure;
    for i=1:3
        subplot(3,1,i)
        hold on
        histogram(r_abNED(i,:),'Normalization','pdf', 'DisplayStyle', 'stairs')        
        histogram(g2NED(:,i)-g1NED(:,i),'Normalization','pdf', 'DisplayStyle', 'stairs')    
        %histogram(g2NED(:,i)-g1NED(:,i),1000, 'DisplayStyle', 'stairs')
        %histogram(r_abNED(i,:),1000,'DisplayStyle', 'stairs')
        legend("DD", "onboard", 'fontSize', 10)
        xlabel("\Delta"+NEDStr(i), 'fontSize', 14)
        %xlabel("Time since startup, [s]", 'fontSize', 14)
    end
    %sgtitle("Histogram over distance, DD estimate and onboard solution, "+ dir+"-direction")
    saveas(fig2, strcat('Figures/InternalAndDD/', dir, 'hist'), 'epsc')
    saveas(fig2, strcat('Figures/InternalAndDD/', dir, 'hist'), 'fig')
end