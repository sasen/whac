g = LoadGame('m7r','ss',1,25);
[xyzin{1}, s, e, ~] = interpolatePlayer(g,1);
[xyzin{2}, ~,~,~] = interpolatePlayer(g,2);  % same start & end tframes
frames = [1:e+1-s];

for pl = 1:2
  [reachOns,hitOns] = parseTrajectory(g,pl);

  figure();
  for row=1:4
    subplot(4,1,row), hold on;
    plot(frames, xyzin{pl}(3,:),'b.-');
    for oo=1:length(hitOns)
      rOn = reachOns(oo);
      hOn = hitOns(oo);
      plot([rOn:hOn],xyzin{pl}(3,rOn:hOn),'g.-');
      plot(hOn,xyzin{pl}(3,hOn),'ks','MarkerSize',10,'MarkerFaceColor','k');
    end
    ylim([-.1 4]);
    xlim([1 1800] + (row-1)*1800);
  end
  subplot(4,1,1), legend('z position','REACH','HIT','Location','NorthWest')
  ylabel('\fontsize{16}z position (inches)');
  xlabel('\fontsize{16}time (tracker frames, 1/240 s) ');
  title(['\fontsize{20}Labelled Game (30 sec): Player ' num2str(pl)]);
end