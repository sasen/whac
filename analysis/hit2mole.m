function hitMole = hit2mole(hOns,mole,xyzpx,sframe)
% function hitMole = hit2mole(hOns,mole,xyzpx,g,sframe)
% Go from hit onset times to mole number, based on xy distance
% hOns: list of hit onsets from crosscheckHits (interpolated frames)
% mole: mole info for moles presented to this player
% xyzpx: player's interpolated tracker data, with xy in pixels (z in inches)
% sframe: starting trackerframe (usually min(g.t) )
%--
% hitMole: corresponding column of mole that was hit

durMult = 1.25; % search ahead this many TargetPresTime lengths (extra 312ms)
fps = 240;   %% frames per second
tgtDur = 1.25;  %% target duration in s (or, g.TargetPresTime/1000)
trange = durMult*tgtDur*fps - sframe + 1;
maxz = max(0,min(xyzpx(3,:))) + .25;  %% max height (in inches) of a hit


mOns = mole(2,:)'*fps - sframe + 1;
for hitnum = 1:length(hOns)
  h = hOns(hitnum);   % hit's frame
  hxy = xyzpx(1:2,h);  % hit's xy in pixels
  if xyzpx(3,h) > maxz
    hitMole(hitnum) = NaN;
    continue;
  end
  poss = find(mOns < h & mOns > (h-trange));  %% possible moleIDs
  mposs = mole(:,poss);   %% possible moles' info
  moledist = inf(max(poss),1);
  for mmm = 1:length(poss)
    moledist(poss(mmm)) = norm(hxy - mposs(4:5,mmm));
  end
  [thisdist,thismole] = min(moledist);
  hitMole(hitnum) = thismole;
end

