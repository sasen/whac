%compareHitFinders
figure();

for row=1:4
  subplot(4,1,row), hold on;
%  plot([1:length(xyzin')]/240,xyzin(3,:),'b.-');
  plot([1:length(xyzin')],xyzin(3,:),'b.-');
  for oo=1:length(hitOns)
    rOn = reachOns(oo);
    hOn = hitOns(oo);
%     plot([rOn:hOn]/240,xyzin(3,rOn:hOn),'g.-');
%     plot(hOn/240,xyzin(3,hOn),'ks','MarkerSize',10,'MarkerFaceColor','k');
    plot([rOn:hOn],xyzin(3,rOn:hOn),'g.-');
    plot(hOn,xyzin(3,hOn),'ks','MarkerSize',10,'MarkerFaceColor','k');
  end
  ylim([-.1 3]);
%  xlim([1 1800]/240 + (row-1)*1800/240);
  xlim([1 1800] + (row-1)*1800);
end
subplot(4,1,1), legend('z position','REACH','HIT','Location','NorthWest')
ylabel('\fontsize{16}z position (inches)');
% xlabel('\fontsize{16}time (s) ');
xlabel('\fontsize{16}time (tracker frames, 1/240 s) ');
title('\fontsize{20}Labelled Game (30 sec)');

% figure();
% subplot(3,1,1),plot(xyzin(3,:),'b.-');  hold on;
% for oo=1:length(hitOns)
%   rOn = reachOns(oo);
%   hOn = hitOns(oo);
%   plot([rOn:hOn],xyzin(3,rOn:hOn),'g.-');
%   plot(hOn,xyzin(3,hOn),'m*','MarkerSize',15);
% end
% ylim([-.1 3]);
% legend('z position','REACH','HIT','Location','SouthWest')
% ylabel('\fontsize{14}z position (inches)');
% title('\fontsize{16} Reach Identification (2 sec snippet) ');

% subplot(3,1,2),plot(tt,a,'k.-'); hold on;
% ylim([-.1 1.1])
% for oo=1:length(reachOns)
%   rOn = reachOns(oo)-1;
%   hOn = hitOns(oo)-1;
%   plot([rOn:hOn],a([rOn:hOn]),'g.-');
% end
% legend('Stillness Indicator','REACH','Location','East')
% ylabel('\fontsize{14}Still=1 / Moving=0');
% title('\fontsize{16}Stillness Refines Hits, and Finds Reaches');

% subplot(3,1,3),plot(zacc/1000,'c.-');  hold on;
% title('\fontsize{16}z Acceleration Identifies (Some) Hits ');
% ylabel('\fontsize{14}(inch/frame/frame)');
% for l=loc
%   subplot(3,1,3),plot(l,zacc(l)/1000,'b*','MarkerSize',15);
% end
% axis tight
% subzoom(3,1,1400,2000)
% xlabel('\fontsize{14}time (tracker frames, 240 = 1s) ');
% legend('z acceleration','Proposed Hit')