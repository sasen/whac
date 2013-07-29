s1 = 'jlp'; s2 = 'ss'; ExpNum = 3; tr=21;
[D,Db] = LoadExpt(s1,s2,ExpNum);
pl=2;

if ExpNum==1
    mole = Db{tr};
else
    mole = Db{pl,tr};
end
xyz = D{tr}.TrackList{pl};
t = D{tr}.TrackList{3};

OrigIntervals=intervalFinder(mole);
numIVs = size(OrigIntervals,1);
reaches = cell(1,numIVs);
for i = 1:numIVs
    iv = OrigIntervals(i,:);
    reaches{i} = IntervalSplitter(iv(1), iv(2),mole,xyz,t);
end

for i=1:numIVs
    r = reaches{i};
    if ~isempty(r)
      for j=1:size(r,1)
        %%Convert Time bounds into TrackList index bounds
	iLo = find(t >= 240*r(j,1),1,'first');
	iHi = find(t <= 240*r(j,2),1,'last');
	Xs = xyz(1,iLo:iHi);
	Ys = xyz(2,iLo:iHi);      
        [DevData{i}(j,1) DevData{i}(j,2) ]=PathDeviation(Xs,Ys);
      end
    end
end