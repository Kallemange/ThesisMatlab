function plot_earth(pos)


a=6378137;
b=6356752.3142;
[X,Y,Z]=ELLIPSOID(0,0,0,a,a,b,30);



surfl(X,Y,Z);
hold on;
plot3(pos(1),pos(2),pos(3),'k.','MarkerSize',25);
