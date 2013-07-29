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

for i=1:size(reaches,1)
    for j=1:size(reaches{i},2)
        DevData{i}(j,:)=PathDeviation(reaches{i}(j,1),reaches{i}(j,2));
    end
end