function crosscheckedHitOnsets = crosscheckHits(hitBinary,loc)

hitOn = find(diff(hitBinary)==1);


for oo=1:length(hitOn)
  onset = hitOn(oo);
  accPeak = loc(find(abs(loc-onset)<25,1,'last'));
  if isempty(accPeak)
    accPeak = onset;
    loc = sort([loc onset]);
  end
  startTimes(oo,:) = [onset accPeak];
end
crosscheckedHitOnsets = unique(startTimes(:,2));