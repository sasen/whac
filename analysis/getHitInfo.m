function [hOns,hMole,hXYZ,moleXY,diffX] = getHitInfo(g)
% function [hOns,hMole,hXYZ,moleXY,diffX] = getHitInfo(g)
% Given a game, extract information about each players's hits
% g = loaded game struct
%-------
% hOns: cell(1,2) players' hit Onsets (in interp'd frames)
% hMole: cell(1,2) players' hit moles (in col# of mole{pl})
% hXYZ: cell(1,2) players' xy (in px) and z (inch) of hOns
% moleXY: cell(1,2) xy (in px) of hMole
% diffX: cell(1,2) X position error (mole center - tracker X, in px)

if strcmp('null',g.pname2)
  players = [1];
elseif strcmp('null',g.pname1)
  players = [2];
else
  players = [1 2];
end

for pl = players
  [~, ~, ~, xyz{pl}] = interpolatePlayer(g,pl);  
  [~, hitOns] = parseTrajectory(g,pl);

  if g.ExpNum == 1
    mole = g.mole{1};
  else%if g.ExpNum == 3
    mole = g.mole{pl};
    if (g.SwitchSides==1 && pl==1) || (g.SwitchSides==-1 && pl==2)
      xyz{pl}(1,:) = g.ScrRes(1)/2 - xyz{pl}(1,:);
      xyz{pl}(2,:) = g.ScrRes(2) - xyz{pl}(2,:);
    elseif (g.SwitchSides==1 && pl==2) || (g.SwitchSides==-1 && pl==1)
      xyz{pl}(1,:) = xyz{pl}(1,:) - g.ScrRes(1)/2;
    end  %% deal with switchsides
  end

  hitMole = hit2mole(hitOns, mole, xyz{pl}, min(g.t));
  
  %% restrict to hits that were identifiable
  foundHits = find(isfinite(hitMole));
  hOns{pl} = hitOns(foundHits);
  hMole{pl} = hitMole(foundHits)';

  hXYZ{pl} = xyz{pl}(:,hOns{pl});    %% x,y (pixel) & z (inches)
  moleXY{pl} = mole(4:5,hMole{pl});
  diffX{pl} = moleXY{pl}(1,:) - hXYZ{pl}(1,:);  
%  subplot(numel(players),1,pl), hist(diffX{pl})
end
