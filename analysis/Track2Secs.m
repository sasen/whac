function secs = Track2Secs(idx,tracktime)
if idx==0
  secs = 0;
else
  secs = tracktime(idx)/240;
