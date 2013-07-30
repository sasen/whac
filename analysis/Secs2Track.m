function idx = Secs2Track(secs,tracktime)
for k=1:length(secs)
  idx(k) = find(abs(tracktime-secs(k)*240)<1,1,'first');
end