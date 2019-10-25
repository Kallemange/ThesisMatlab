figure
subplot(2,1,1)

plot(x1.satPos.pos{1}(:,1)- x1.satPos.pos{1}(1,1), ones(size(x1.satPos.pos{1}(:,1))),'.')
title("visibility svID2")
xlabel("Time since startup")
subplot(2,1,2)
plot(x1.tVec-x1.tVec(1),   x1.xVec(:,1)-x1.xVec(1,1))
hold on
plot(x2.tVec-x1.tVec(1),   x2.xVec(:,1)-x1.xVec(1,1))
title("Positional fix difference in x coordinate (ECEF)")
xlabel("Time since startup")
ylabel("$\Delta$x$_{ECEF}$", 'Interpreter', 'Latex')
legend("rec_1", "rec_2")