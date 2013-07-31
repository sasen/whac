function [reachIVs, ignored] = FindReaches(targIVs, hits)
% FindReaches For a whole trial, via hitpts & target intervals (all in track idx).
% [reachIVs, ignored] = FindReaches(targIVs, hits)
% ignored is the number of hits that we ignored.

%targIVs = targInts; hits = hitIdx;

reachIVs = [];
for i=1:length(targIVs)
  iv = targIVs(i,:);
  hitSeq = hits((hits > iv(1) & (hits < iv(2)+20)));  %% 20-idx lag acceptable

  %% partition sequences into intervals
  numHits = length(hitSeq);
  if numHits > 1  %% ignore first hit of each sequence
    for h = 1:numHits-1
      reachIVs = [reachIVs; hitSeq(h) hitSeq(h+1)];
    end
  end
end
ignored = length(hits) - length(reachIVs);

% figure; hold on;
% plot(hits,ones(size(hits)),'ro','MarkerSize',10);
% for iv = targIVs'
%   plot(iv,[1;1],'+--','MarkerSize',10,'LineWidth',2);
% end


