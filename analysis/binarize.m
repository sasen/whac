movethresh = 40;
tt = [2:length(t)];
xb = (erf(dinv(1,:)-movethresh) + 1)/2;
yb = (erf(dinv(2,:)-movethresh) + 1)/2;
zb = (erf(dinv(3,:)-movethresh) + 1)/2;
zpos = xyzin(3,2:end) < 0.5;

a = xb & yb & zb;
hit = a & zpos;
mins = min(xyzin');

subplot(4,1,1),hold on;
plot(xyzin(1,:),'r.-'); 
plot(tt,xb+mins(1),'r-')
axis tight
subplot(4,1,2),hold on;
plot(xyzin(2,:),'g.-')
plot(tt,yb+mins(2),'g-')
axis tight
subplot(4,1,3),hold on;
plot(xyzin(3,:),'b.-');
plot(tt,zb+.1,'b-');
subplot(4,1,4), hold on;
%plot(tt,zb+.1,'b-');
plot(tt,a,'k-','LineWidth',2);
plot(tt,hit-.1,'c-','LineWidth',2);
ylim([-.1 2.5])

% Get hit starts by comparing zacc & hit
hitOns = crosscheckHits(hit,locT);
for oo=hitOns
  subplot(4,1,1),plot(oo,xyzin(3,oo),'mo','MarkerSize',15);
end



figure;
subplot(3,1,1)
plot(xyzin(1,:),'r.-'); 
axis tight
ylabel('\fontsize{14}position (inches)');
ylim([12 18])
title('\fontsize{16}Position (x) ');

subplot(3,1,2), hold on;
plot(tt,dinv(1,:),'r.-');
line([1 7200],[40 40])
ylim([0 800])
ylabel('\fontsize{14}inv-speed (frames/inch)');
legend('1/speed(x)','threshold','Location','NorthWest')
title('\fontsize{16}Inverse Speed (x) ');

subplot(3,1,3),
plot(tt,xb,'r-')
ylim([-.1 1.1])
ylabel('\fontsize{14}x stillness');
title('\fontsize{16}Binarized Stillness (x): Based on threshold above ');
subzoom(3,1,1400,2000);

figure;
subplot(3,1,1)
plot(xyzin(2,:),'g.-'); 
axis tight
ylabel('\fontsize{14}position (inches)');
ylim([2 13])
title('\fontsize{16}Position (y) ');

subplot(3,1,2), hold on;
plot(tt,dinv(2,:),'g.-');
line([1 7200],[40 40])
ylim([0 800])
ylabel('\fontsize{14}inv-speed (frames/inch)');
legend('1/speed(y)','threshold','Location','NorthWest')
title('\fontsize{16}Inverse Speed (y) ');

subplot(3,1,3),
plot(tt,yb,'g-')
ylim([-.1 1.1])
ylabel('\fontsize{14}y stillness');
title('\fontsize{16}Binarized Stillness (y): Based on threshold above ');
subzoom(3,1,1400,2000);

figure;
subplot(3,1,1)
plot(xyzin(3,:),'b.-'); 
axis tight
ylabel('\fontsize{14}position (inches)');
ylim([-.1 3])
title('\fontsize{16}Position (z) ');

subplot(3,1,2), hold on;
plot(tt,dinv(3,:),'b.-');
line([1 7200],[40 40])
ylim([0 800])
ylabel('\fontsize{14}inv-speed (frames/inch)');
legend('1/speed(z)','threshold','Location','North')
title('\fontsize{16}Inverse Speed (z) ');

subplot(3,1,3),
plot(tt,zb,'b-')
ylim([-.1 1.1])
ylabel('\fontsize{14}z stillness');
title('\fontsize{16}Binarized Stillness (z): Based on threshold above ');
subzoom(3,1,1400,2000);

figure; 
subplot(3,1,1),hold on
plot(tt,dinv(1,:),'r.-')
plot(tt,dinv(2,:),'g.-')
plot(tt,dinv(3,:),'b.-')
line([0 7200],[40 40])
title('\fontsize{16}Inverse Speeds ');
legend('x','y','z','threshold')
ylabel('\fontsize{14}inv-speed (frames/inch)');
ylim([0 1500])

subplot(3,1,2),hold on
plot(tt,xb+.3,'r.-')
plot(tt,yb+.2,'g.-')
plot(tt,zb+.1,'b.-')
title('\fontsize{16}Stillness Components (Shifted for display) ');
legend('x','y','z')

subplot(3,1,3); hold on
plot(tt,a,'k.-')
plot(tt,hit-.1,'m.-')
legend('AND = x & y & z','HIT = AND < 0.5')
title('\fontsize{16}Stillness Indicators (Shifted for display) ');
xlabel('\fontsize{14}time (trackerframes)');

subzoom(3,1,600,1600)


% % x/y/z-hi: erf with 10x thresh => ORed together (or added and erfed)
% xhi = (erf(dinv(1,:)-movethresh*10) + 1)/2;
% yhi = (erf(dinv(2,:)-movethresh*10) + 1)/2;
% zhi = (erf(dinv(3,:)-movethresh*10) + 1)/2;

% still=(xhi | yhi | zhi);
% % maybe use THIS to conservatively find reaches?

% FIND REACHES
% Compare hit onsets to a, and look backwards in time.
reachOns = reachFinder(hitOns,a);

% subplot(4,1,4),plot(tt,a,'k.-'); hold on;
% plot(xyzin(3,:),'b.-');
% for oo=1:length(hitOns)
%   rOn = reachOns(oo);
%   hOn = hitOns(oo);
%   plot([rOn:hOn],xyzin(3,rOn:hOn),'g.');
%   plot(hOn,xyzin(3,hOn),'m*','MarkerSize',15);
% end
% ylim([-.1 2.5])
