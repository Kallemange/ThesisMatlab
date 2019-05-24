start_time=[2017 07 01 11 0 0];

%almanac_data=Get_almanac_data(start_time);

[M N]=size(almanac_data);

t=0:100:(11*60*60+58*60);

pos=zeros(3,length(t));
pos_ECEF=zeros(3,length(t));

Rec_pos_ecef=g2r('N',59,'E',18,0);

h=figure(1);
clf
hold on
axis('equal')

for k=1:N
    
    for  n=1:length(t)
        [pos_ECEF(:,n) pos(:,n)]=Sat_pos(almanac_data(:,k),t(n));
    end
    plot3(pos(1,:),pos(2,:),pos(3,:),'b')


    [Range Angle]=RangeandAngle(pos(:,1),Rec_pos_ecef);

    if Angle>10*pi/180
        plot3(pos(1,1),pos(2,1),pos(3,1),'r.','MarkerSize',20)
        disp('ID:')
        almanac_data(1,k)
        disp('Angle above horizont')
        Angle*180/pi
    else
        plot3(pos(1,1),pos(2,1),pos(3,1),'k.','MarkerSize',20)
    end
end

a=6378137;
b=6356752.3142;
[X,Y,Z]=ellipsoid(0,0,0,a,a,b,30);
surfl(X,Y,Z);

plot3(Rec_pos_ecef(1),Rec_pos_ecef(2),Rec_pos_ecef(3),'g.','Markersize',40)

axis('equal')
grid on
view(3)
title('Satelllite Trajectories in ECI coordinates')
xlabel('x-axis [m]')
ylabel('y-axis [m]')
zlabel('z-axis [m]')




 