function reachOnsets = reachFinder(hitOnsets,anded)

for oo=1:length(hitOnsets)
  onset = hitOnsets(oo);
  inHit = anded(onset);
  backwards = anded(1:onset-1);
  if inHit
    preHit = find(backwards==0,1,'last');
    backwards = backwards(1:preHit);
  end
    reachOnsets(oo) = find(backwards==1,1,'last');
end
