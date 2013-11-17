movethresh = 40;
xb = (erf(dinv(1,:)-movethresh) + 1)/2;
yb = (erf(dinv(2,:)-movethresh) + 1)/2;
zb = (erf(dinv(3,:)-movethresh) + 1)/2;
zpos = xyzin(3,2:end) < 0.5;

a = xb & yb & zb;
hit = a & zpos;
mins = min(xyzin');

% figure;
% subplot(4,1,1),hold on;
% plot(t,xyzin(1,:),'r.-'); 
% plot(t(2:end),xb+mins(1),'r-')
% axis tight
% subplot(4,1,2),hold on;
% plot(t,xyzin(2,:),'g.-')
% plot(t(2:end),yb+mins(2),'g-')
% axis tight
% subplot(4,1,3),hold on;
% plot(t,xyzin(3,:),'b.-');
% plot(t(2:end),zb+.1,'b-');
subplot(4,1,1), hold on;
plot(t(2:end),a,'k-','LineWidth',2);
plot(t(2:end),hit-.1,'c-','LineWidth',2);
ylim([-.1 2.5])

% Get hit starts by comparing zacc & hit
hitOns = crosscheckHits(hit,loc);
for oo=hitOns
  subplot(4,1,1),plot(oo,xyzin(3,oo),'mo','MarkerSize',15);
end

% x/y/z-hi: erf with 10x thresh => ORed together (or added and erfed)
xhi = (erf(dinv(1,:)-movethresh*10) + 1)/2;
yhi = (erf(dinv(2,:)-movethresh*10) + 1)/2;
zhi = (erf(dinv(3,:)-movethresh*10) + 1)/2;

still=(xhi | yhi | zhi);
% * use THIS to conservatively find reaches. 
% compare to "hit" (a & zpos), and look backwards in time.
subplot(4,1,4),plot(t(2:end),still,'m'); hold on;
for oo=hitOns
  subplot(4,1,4),plot(oo,0,'mo','MarkerSize',15);
end
ylim([-.1 1.1])
