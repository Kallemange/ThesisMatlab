%x1=estGlobalPos(raw1, eph)
x2=estGlobalPos(raw2, eph)
%%
figure
idx=find(sum(allSatPos,2)~=0)
for i=1:10
    for j=1:3
        subplot(3,1,j)
        hold on
        plot(allSatPos(idx(i), (j-1)+1:3:end)-allSatPos(idx(i), j))
        
    end
end
%%
[x1 t1]=estGlobalPos(raw1, eph, 100, 1);
[x2 t2]=estGlobalPos(raw2, eph, 100, 1);

for i=1:3
    subplot(3,1,i)
plot(t1-t1(1), x1(:,i)-x1(1,i))
hold on
plot(t2-t1(1), x2(:,i)-x1(1,i))
xlabel(strcat('mean: ', 32, num2str(mean(x1(:,i)-x1(1,i))), 32, num2str(mean(x2(:,i)-x1(1,i)))))
end