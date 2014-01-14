function reachOnsets = reachFinder(hitOnsets,anded)
%function reachOnsets = reachFinder(hitOnsets,anded)
% Note: hits that are before stimulus presentation starts ought to be removed before calling this function

if length(hitOnsets)==0
  reachOnsets = [];
  return
end

for oo=1:length(hitOnsets)
  hOn = hitOnsets(oo)-1; %% -1 to index into anded (which is diffed)
  inHit = anded(hOn);
  backwards = anded(1:hOn-1);
  if inHit
    preHit = find(backwards==0,1,'last');
    if isempty(preHit)
      preHit = 1;   %% game start; impossible, not a real reach!
    end
    backwards = backwards(1:preHit);
  end
    lastLow = find(backwards==1,1,'last')+1;  %% +1 because =1 is too far
    reachOnsets(oo) = lastLow+1;  %% +1 to remove effects of diff
end
reachOnsets = reshape(reachOnsets,numel(reachOnsets),1); % column vector