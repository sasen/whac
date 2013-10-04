%% Calculate the mean percent of targets hit in splitscreen games.
%% Assumes all3conditions.mat has been loaded (from LoadSplit.m)

trlStart = 4; trlEnd = 21;

%goodSubjIdx = [1:length(DistSubjects{1})];
goodSubjIdx = find(~ismember(DistSubjects{1},{'finaltest'}));
goodSubjOrder = DistSubjects{1}(goodSubjIdx);  % cannonical subject order

fh = figure(); hold on;
cMap = colormap;
colorList = round(linspace(1,size(cMap,1),length(goodSubjOrder)));
meanHit = [];

for sName = goodSubjOrder
  sNum = find(strcmp(goodSubjOrder,sName));  % consistent subj num for colorList

  [sD, plD] = findSubject(sName,DistSubjects);
  byGameD = [];
  for tr = trlStart:trlEnd
    mole = DistCond{sD,tr}.mole{plD};
    byGameD(tr,:) = getHitPercent(mole,plD);
  end
  meanHit(sNum,1) = mean(byGameD(trlStart:trlEnd,1));
%  plot(byGameD(:,1),'.-','LineWidth',3,'color',cMap(colorList(sNum),:));

  [sS, plS] = findSubject(sName,SoloSubjects);
  byGameS = [];
  for tr = trlStart:trlEnd
    mole = SoloCond{sS,tr}.mole{plS};
    byGameS(tr,:) = getHitPercent(mole,plS);
  end
  meanHit(sNum,2) = mean(byGameS(trlStart:trlEnd,1));
%  plot(byGameS(:,1),'.-','LineWidth',3,'color',cMap(colorList(sNum),:));

  [sP, plP] = findSubject(sName,PairedSubjects);
  byGameP = [];
  for tr = trlStart:trlEnd
    mole = PairedCond{sP,tr}.mole{plP};
    byGameP(tr,:) = getHitPercent(mole,plP);
  end
  meanHit(sNum,3) = mean(byGameP(trlStart:trlEnd,1));
  plot(byGameP(:,1),'.-','LineWidth',3,'color',cMap(colorList(sNum),:));

end

legend(goodSubjOrder);
meanHit
goodSubjOrder'
