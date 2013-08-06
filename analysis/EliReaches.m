function [reaches, AErr, Devs, D, Db] = EliReaches(s1,s2,ExpNum,pl)
%s1='jlp'; s2='ss'; ExpNum=3; pl=1;
[D,Db] = LoadExpt(s1,s2,ExpNum);

AErr = cell(1,21);
Devs = cell(1,21);
for tr=1:21
    mole = Db{pl,tr};
    xyz  = D{tr}.TrackList{pl};
    t    = D{tr}.TrackList{3};

    %% hits from raw tracker data (in track idx)
    hitIdx = TrackdataHits(xyz,t);  

    %% target present intervals
    moleInts = intervalFinder(mole);    % in seconds
    if moleInts(end) > 30
      moleInts(end) = t(end)/240-1;     % clip last one to end of trial
    end
    tInts = [];
    for k=1:prod(size(moleInts))
      found = find(abs(t-moleInts(k)*240)<1,1,'first');
      if isempty(found)
        found = find(abs(t-moleInts(k)*240)<2,1,'first');
	if isempty(found)
	  s1
	  tr
	  moleInts(k)
	  tInts(k) = 1;
	else
	  tInts(k) = found(1);
	end
      else
	tInts(k) = found;
      end
    end
    targInts = reshape(tInts,size(moleInts));    
%    targInts = Secs2Track(moleInts(1:end-1,:),t)  % in track idx

    %% get all reach intervals in the trial
    % combine target intervals and hit indices
    reaches{tr} = FindReaches(targInts,hitIdx);

    AErr{tr} = 180*ones(length(reaches{tr}),4);
    for i=1:length(reaches{tr})
        riv = reaches{tr}(i,:);   % reach interval
        AErr{tr}(i,:) = AngleError(riv(1),riv(2),xyz,t);
	Xs = xyz(1,riv(1):riv(2));
        Ys = xyz(2,riv(1):riv(2));
        [dev, len, tIdx] = PathDeviation(Xs,Ys);
        Devs{tr}(i,:) = [dev, len, riv + tIdx, Xs(1), Ys(1)];
    end

end

% meanDev=mean(FullDev(:,1));
% stdDev=std(FullDev(:,1));

% figure
% hist(FullDev(:,1),20)
% if ExpNum==4
%     title(['Target-less game, mean=' num2str(meanDev) ', StdDev=' num2str(stdDev)])
% end
% if ExpNum==3
%     if strcmp(s1,'null') || strcmp(s2,'null')
%         title(['Split-game solo, mean=' num2str(meanDev) ', StdDev=' num2str(stdDev)])
%     else
%         title(['Split-game paired, mean=' num2str(meanDev) ', StdDev=' num2str(stdDev)])
% end
%end