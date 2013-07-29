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
clr=D{tr}.TargetColors/255;

OrigIntervals=intervalFinder(mole);
numIVs = size(OrigIntervals,1);
reachcell = cell(1,numIVs);
for i = 1:numIVs
    iv = OrigIntervals(i,:);
    reachcell{i} = IntervalSplitter(iv(1), iv(2),mole,xyz,t);
end
reaches = cell2mat(reachcell');

for i=1:size(reaches,1)
  %%Convert Time bounds into TrackList index bounds
  iLo = find(t >= 240*reaches(i,1),1,'first');
  iHi = find(t <= 240*reaches(i,2),1,'last');
  Xs = xyz(1,iLo:iHi);
  Ys = xyz(2,iLo:iHi);      
  [dev, len, tIdx] = PathDeviation(Xs,Ys);
  DevData(i,:) = [dev, len, iLo + tIdx, Xs(1), Ys(1)];
end

figure; hold on;
plot(xyz(1,:),t/240,'b.--');
axis tight;
for d=DevData'
  plot(xyz(1,d(3)),t(d(3))/240, 'ro','MarkerSize',10)
end

figure; hold on;
plot(xyz(1,:),xyz(2,:),'b.--')
axis tight;
for d=DevData'
  plot(xyz(1,d(3)),xyz(2,d(3)),'r*','MarkerSize',8);
  plot(d(4),d(5),'go','MarkerSize',20);
end

% figure; hold on;
% plot(t/240,xyz(3,:),'k.--');
% xlabel('time (s)');
% ylabel('z position');
% for riv = reaches'
%   plot(riv, [0 0], 'o-','LineWidth',2);
% end
