movethresh = 40;
tt = [2:length(t)];
xb = (erf(dinv(1,:)-movethresh) + 1)/2;
yb = (erf(dinv(2,:)-movethresh) + 1)/2;
zb = (erf(dinv(3,:)-movethresh) + 1)/2;
zpos = xyzin(3,2:end) < 0.5;

a = xb & yb & zb;
hit = a & zpos;
mins = min(xyzin');

% figure;
% subplot(4,1,1),hold on;
% plot(xyzin(1,:),'r.-'); 
% plot(tt,xb+mins(1),'r-')
% axis tight
% subplot(4,1,2),hold on;
% plot(xyzin(2,:),'g.-')
% plot(tt,yb+mins(2),'g-')
% axis tight
% subplot(4,1,3),hold on;
% plot(xyzin(3,:),'b.-');
% plot(tt,zb+.1,'b-');
subplot(4,1,1), hold on;
%plot(tt,zb+.1,'b-');
plot(tt,a,'k-','LineWidth',2);
plot(tt,hit-.1,'c-','LineWidth',2);
ylim([-.1 2.5])

% Get hit starts by comparing zacc & hit
hitOns = crosscheckHits(hit,locT);
for oo=hitOns
  subplot(4,1,1),plot(oo,xyzin(3,oo),'mo','MarkerSize',15);
end

% % x/y/z-hi: erf with 10x thresh => ORed together (or added and erfed)
% xhi = (erf(dinv(1,:)-movethresh*10) + 1)/2;
% yhi = (erf(dinv(2,:)-movethresh*10) + 1)/2;
% zhi = (erf(dinv(3,:)-movethresh*10) + 1)/2;

% still=(xhi | yhi | zhi);
% % maybe use THIS to conservatively find reaches?

% FIND REACHES
% Compare hit onsets to a, and look backwards in time.
reachOns = reachFinder(hitOns,a);

subplot(4,1,4),plot(tt,a,'k.-'); hold on;
plot(xyzin(3,:),'b.-');
for oo=1:length(hitOns)
  rOn = reachOns(oo);
  hOn = hitOns(oo);
  plot([rOn:hOn],xyzin(3,rOn:hOn),'g.');
  plot(hOn,xyzin(3,hOn),'m*','MarkerSize',15);
end
ylim([-.1 2.5])
