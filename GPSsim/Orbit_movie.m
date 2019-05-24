start_time=[2008 07 01 11 0 0];

almanac_data=Get_almanac_data(start_time);

[M N]=size(almanac_data);

t=almanac_data(4):60:almanac_data(4)+(11*60*60+58*60);




Rec_pos_ecef=g2r('N',59,'E',18,0);

a=6378137;
b=6356752.3142;
[X,Y,Z]=ellipsoid(0,0,0,a,a,b,30);

fig=figure(1);
axis('equal')
set(fig,'DoubleBuffer','on');
set(gca,'xlim',[-5e7 5e7],'ylim',[-5e7 5e7],'zlim',[-5e7 5e7],...
    'NextPlot','replace','Visible','off')
title('Satelllite Trajectories in ECI coordinates')
xlabel('x-axis [m]')
ylabel('y-axis [m]')
zlabel('z-axis [m]')
grid on
mov = avifile('sat_trajectory.avi');


hold on

for  n=1:length(t)
    tic
    clf
    hold on
    surfl(X,Y,Z);
    for k=1:N


        [pos_ECEF pos]=Sat_pos(almanac_data(:,k),t(n));

        [Range Angle]=RangeandAngle(pos_ECEF,Rec_pos_ecef);

        if Angle>10*pi/180
            h=plot3(pos(1),pos(2),pos(3),'r.','MarkerSize',20);
            grid on
            axis([-3e7 3e7 -3e7 3e7 -3e7 3e7])
            set(h,'EraseMode','xor');
            
            view(3)
        else
            h=plot3(pos(1),pos(2),pos(3),'k.','MarkerSize',20);
            grid on
            axis([-3e7 3e7 -3e7 3e7 -3e7 3e7])
            set(h,'EraseMode','xor');
            view(3)
        end
    end
    F = getframe(gca);
    mov = addframe(mov,F);
    toc
end




axis('equal')
grid on





    


mov = close(mov);
 