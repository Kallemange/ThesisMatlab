function [dNorm dNED]=interpol(T1,T2, origin, t0, t1, t2, CS)
%Interpolation of the positions to make sure that the difference in
%position is taken at the same time
%ARGS: Table1, Table1, valid time indexes1 and 2
if CS=='lla'
    [T1.ned0, T1.ned1, T1.ned2]=geodetic2ned(T1.(strcat(CS,'0')), T1.(strcat(CS,'1')), T1.(strcat(CS,'2')),...
                                               origin(1), origin(2), origin(3),wgs84Ellipsoid);
    [T2.ned0, T2.ned1, T2.ned2]=geodetic2ned(T2.(strcat(CS,'0')), T2.(strcat(CS,'1')), T2.(strcat(CS,'2')),...
                                               origin(1), origin(2), origin(3),wgs84Ellipsoid);
end

T1.timeOfWeek=T1.timeOfWeek-t0;
T2.timeOfWeek=T2.timeOfWeek-t0;
if (T1.timeOfWeek(1)==0)
    Tnew=make_equal_time(T1, T2, t1, t2);
    dNorm=table2array(T1(t1,1));
    dNED=[T1.ned0(t1) T1.ned1(t1) T1.ned2(t1)]-Tnew;
    dNorm=[dNorm vecnorm(dNED,2,2)];
    
    %d=[d vecnorm([P1shift(t1)-Tnew(:,1), P1shift(t1)-Tnew(:,2), P1shift(t1)-Tnew(:,3)],2,2)];
else
    dNorm=zeros(size(T2,1),1);
    Tnew=make_equal_time(T2,T1, t2, t1);
    dNorm=table2array(T2(t2,1));
    %d=[d vecnorm([T2.(strcat(CS, '0'))(t2)-Tnew(:,1), T2.(strcat(CS, '1'))(t2)-Tnew(:,2), T2.(strcat(CS, '2'))(t2)-Tnew(:,3)],2,2)];
    dNED=[T2.ned0(t2) T2.ned1(t2) T2.ned2(t2)]-Tnew;
    dNorm=[dNorm vecnorm(dNED,2,2)];
    %d=[d vecnorm([P2shift(t2)-Tnew(:,1), P2shift(t2)-Tnew(:,2), P2shift(t2)-Tnew(:,3)],2,2)];
end


end



function T=make_equal_time(Ts,Tl, t1, t2)
F=@(T_low, T_high,dt1, dt2) ((T_low*dt1+T_high*dt2)/(dt2+dt1));
T=zeros(size(t1,1),3);
for i=1:length(t1)
    t=Ts.timeOfWeek(t1(i));
    t_lower=find(Tl.timeOfWeek<Ts.timeOfWeek(i), 1, 'last');
    t_upper=find(Tl.timeOfWeek>Ts.timeOfWeek(i), 1, 'first');
    try
        T(i,:)=F([Tl.ned0(t_lower) Tl.ned1(t_lower) Tl.ned2(t_lower)], ...
             [Tl.ned0(t_upper) Tl.ned1(t_upper) Tl.ned2(t_upper)], ...
              t-Tl.timeOfWeek(t_lower),             ...
              Tl.timeOfWeek(t_upper)-t);
    catch ME
        keyboard
    end
end
end




