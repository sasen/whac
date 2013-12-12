% s1 = 'jlp'; s2 = 'ss'; ExpNum = 3;
% [EPair,~] = LoadExpt(s1,s2,ExpNum,'all');

% for trl = 1:length(EPair)
%   [hOns,hMole,hXYZ,moleXY,diffX] = getHitInfo(EPair{trl});
%   for pl = 1:2
%     hitOnsets{trl,pl} = hOns{pl};
%     hitMoles{trl,pl} = hMole{pl};
%     hitXYZs{trl,pl} = hXYZ{pl};
%     moleXYs{trl,pl} = moleXY{pl};
%     hitXErr{trl,pl} = diffX{pl};
%   end
% end

edges = [-inf,linspace(-100,100,61),inf];
figure();
%%% HEREHEREHERE think about sideswitching
for pl=1:2
  xErrs = [hitXErr{:,pl}];
  counts(:,pl) = histc(xErrs, edges);
  subplot(2,1,pl),bar([-120 edges(2:end-1) 120],counts(:,pl),'histc');
  [pl mean(xErrs) median(xErrs) std(xErrs) skewness(xErrs,0) kurtosis(xErrs,0)]
end
