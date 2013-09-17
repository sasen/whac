function trIdx = Secs2Track(secs,tracktime)

secSize = size(secs);
s = reshape(secs,prod(secSize),1);
maxt = tracktime(end)/240;
assert(all(s<=maxt),'Secs2Track: secs out of range!\n');  % errorcheck

for k=1:prod(secSize)
  try1 = find(abs(tracktime-secs(k)*240)<1,1,'first');
  if numel(try1) > 0
    idx(k) = try1;
  else
    tol = 2;
    tryN = [];
    while numel(tryN) < 1
      tryN = find(abs(tracktime-secs(k)*240)<tol,1,'first');
      tol = tol+1;
    end
    idx(k) = tryN;
    tol
    tryN
  end

end
trIdx = reshape(idx,secSize);