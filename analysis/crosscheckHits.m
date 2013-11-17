function crosscheckedHitOnsets = crosscheckHits(hitBinary,accPeaks)

hitOn = find(diff(hitBinary)==1)+2;


for oo=1:length(hitOn)
  hOn = hitOn(oo);
  nearestPeak = accPeaks(find(abs(accPeaks-hOn)<25,1,'last'));
  if isempty(nearestPeak)
    nearestPeak = hOn;
    accPeaks = sort([accPeaks hOn]);
  end
  startTimes(oo,:) = [hOn nearestPeak];
end
crosscheckedHitOnsets = unique(startTimes(:,2));