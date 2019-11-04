function compare_globalPos_gridSearch(x, T,B)
c = 299792458;  
figure
subplot(2,1,1)
plot(x.bVec/c)
hold on
plot(T,B/c)
title("Estimated clock bias over time from gridsearch and global position")
legend("Global Pos", "Gridsearch")
xlabel("Time since startup [s]")
ylabel("Estimated clock bias [s]")
