function perc_hit_shown = getHitPercent(mole,pl)
% function perc_hit_shown = getHitPercent(mole,pl)
% Gets percent of target moles hit, by player pl (1 or 2),
%   in the game with mole-info mole (7 x # moles).
% perc_hit_shown = [numHit/numShown numHit numShown]

  tgtIdx = find(mole(3,:) < 2.5);  % green = 1, yellow = 2, distractors = 3+
  numShown = length(tgtIdx);
  numHit = sum(mole(6,tgtIdx)==pl);
  perc_hit_shown = [numHit/numShown numHit numShown];
end