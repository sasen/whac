s1 = 'jlp'; s2 = 'ss'; ExpNum = 3;
[EPair,~] = LoadExpt(s1,s2,ExpNum,'all');

for trl = 1:length(EPair)
  [hOns,hMole,hXYZ,moleXY,diffX] = getHitInfo(EPair{trl});
  for pl = 1:2
    hitOnsets{trl,pl} = hOns{pl};
    hitMoles{trl,pl} = hMole{pl};
    hitXYZs{trl,pl} = hXYZ{pl};
    moleXYs{trl,pl} = moleXY{pl};
    hitXErr{trl,pl} = diffX{pl};
  end
end

[ESolo,~] = LoadExpt(s1,'null',3,'all');
for trl = 1:length(ESolo)
  [hOns,hMole,hXYZ,moleXY,diffX] = getHitInfo(ESolo{trl});
  hitOnsets{trl,3} = hOns{1};
  hitMoles{trl,3} = hMole{1};
  hitXYZs{trl,3} = hXYZ{1};
  moleXYs{trl,3} = moleXY{1};
  hitXErr{trl,3} = diffX{1};
end

[EDist,~] = LoadExpt(s1,'null',4,'all');
for trl = 1:length(EDist)
  [hOns,hMole,hXYZ,moleXY,diffX] = getHitInfo(EDist{trl});
  hitOnsets{trl,4} = hOns{1};
  hitMoles{trl,4} = hMole{1};
  hitXYZs{trl,4} = hXYZ{1};
  moleXYs{trl,4} = moleXY{1};
  hitXErr{trl,4} = diffX{1};
end

edges = [-inf,linspace(-100,100,61),inf];
figure();
%%% HEREHEREHERE think about sideswitching
for pl=1:4
  xErrs = [hitXErr{:,pl}];
  counts(:,pl) = histc(xErrs, edges);
  subplot(2,2,pl),bar([-120 edges(2:end-1) 120],counts(:,pl),'histc');
  [pl mean(xErrs) median(xErrs) std(xErrs) skewness(xErrs,0) kurtosis(xErrs,0)]
  title(['x error: player ' num2str(pl)]);
end

scorePerCond = [sum(EPair{end}.ScorePlayers') sum(ESolo{end}.ScorePlayers(1,:)) sum(EDist{end}.ScorePlayers(1,:))];
hitsPerCond = sum(counts);
