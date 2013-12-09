%compareHitFinders

hold on;
  for oo=1:length(hitOns)
    rOn = reachOns(oo);
    hOn = hitOns(oo);
    plot([rOn:hOn]+s,xyzin(3,rOn:hOn),'g.-');
    plot(hOn+s,xyzin(3,hOn),'ks','MarkerSize',10,'MarkerFaceColor','k');
  end




