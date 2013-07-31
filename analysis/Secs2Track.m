function trIdx = Secs2Track(secs,tracktime)

secSize = size(secs);
s = reshape(secs,prod(secSize),1);
maxt = tracktime(end)/240;
assert(all(s<=maxt),'Secs2Track: secs out of range!\n');  % errorcheck

for k=1:prod(secSize)
  idx(k) = find(abs(tracktime-secs(k)*240)<1,1,'first');
end
trIdx = reshape(idx,secSize);