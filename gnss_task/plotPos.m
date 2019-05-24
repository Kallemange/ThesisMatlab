function plotPos(x1, x2, trueP, r_ab, tau)
keyboard
figure(1)
plot(x1(:,1),x1(:,2), '*');
hold on
plot(trueP(1,:), trueP(2,:))
%%

subplot(131)
plot(x1(1+tau:end,1)-x2(:,1), x1(1+tau:end,2)-x2(:,2), '*' )
xlabel(sprintf('Distance x_1(t=%s,...)-x_2(t=1,...) (should=0)', num2str(1+tau)))
subplot(132)
plot(r_ab(1, :), r_ab(2,:), '*' )
xlabel('estimated r_{ab} x_1-x_2 (not=0)')
subplot(133)
plot(r_ab(1,:)-x2(:,1)',r_ab(2,:)-x2(:,2)', '*')
xlabel('r_{ab}-x_1 (should=0)')
