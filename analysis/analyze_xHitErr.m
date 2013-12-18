if ~exist('EPair','var')
  s1 = '337'; s2 = 'sasen'; ExpNum = 3;
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
end  %% accumulate EPair

if ~exist('ESolo','var')
  [ESolo,~] = LoadExpt(s1,'null',3,'all');
  for trl = 1:length(ESolo)
    [hOns,hMole,hXYZ,moleXY,diffX] = getHitInfo(ESolo{trl});
    hitOnsets{trl,3} = hOns{1};
    hitMoles{trl,3} = hMole{1};
    hitXYZs{trl,3} = hXYZ{1};
    moleXYs{trl,3} = moleXY{1};
    hitXErr{trl,3} = diffX{1};
  end
end  %% accumulate ESolo

if ~exist('EDist','var')
  [EDist,~] = LoadExpt(s1,'null',4,'all');
  for trl = 1:length(EDist)
    [hOns,hMole,hXYZ,moleXY,diffX] = getHitInfo(EDist{trl});
    hitOnsets{trl,4} = hOns{1};
    hitMoles{trl,4} = hMole{1};
    hitXYZs{trl,4} = hXYZ{1};
    moleXYs{trl,4} = moleXY{1};
    hitXErr{trl,4} = diffX{1};
  end
end  %% accumulate EDist
%%-------- Done Loading & Accumulating Conditions
%% Analyze & Plot

edges = [-inf,linspace(-80,80,41),inf];
figure();
players = [1 2 1 1];
side1 = [10:15];
side2 = [4:9 16:21];
for pl=1:4
  if pl==2
    blocks = {side2; side1};
  else
    blocks = {side1; side2};
  end
  for sens=1:2  % sensor 1 ~ near computer // 2 ~ near door
    plotnum = pl + 4*(sens-1);
    titlestring = ['player ' num2str(players(pl)) ', sensor ' num2str(sens)];
    xErrs = [hitXErr{blocks{sens},pl}];
    counts(:,pl,sens) = histc(xErrs, edges);
    subplot(2,4,plotnum),bar([-100 edges(2:end-1) 100],counts(:,pl,sens),'histc');
    title(titlestring);
    axis tight; hold on;
    plot(0,0,'y+','MarkerSize',15,'LineWidth',2);
    summary(:,pl,sens) = [mean(xErrs) std(xErrs)]';
  end
end
summary
hitsPerCond = sum(counts)
