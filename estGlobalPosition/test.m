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