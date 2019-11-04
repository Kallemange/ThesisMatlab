function [P,B, T]=gridSearchAllT(raw, eph)
tShift=@(T, h) (T(1):h:T(2));
figure
idxVec=[];
tShiftVec=[];
timeVec=1:100:length(raw);
t1=tShift([-1 1], 0.1);
P=[];
B=[];
for i=timeVec
    [~,~, t_min1]=gridSearch(eph,raw(i),t1);
    t2=tShift(t_min1, 0.01);
    [p, b, ~, ~, idxVec]=gridSearch(eph,raw(i),t2);
    P(end+1,:)=p(idxVec,:);
    B(end+1)=b(idxVec);
    tShiftVec(end+1)=t2(idxVec);
end
T=[raw(timeVec).ToW]-raw(1).ToW;
plot(T,tShiftVec)
title("Optimal time shift per entire observation series")
xlabel("Time since startup")
ylabel("Optimal time shift")