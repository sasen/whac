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

figure; hold on;
plot(t/240,xyz(3,:),'k.--');
xlabel('time (s)');
ylabel('z position');

% lo=0; hi=30;  % bounds in s
% mIdx = find((mole(2,:) >lo) & (mole(2,:) < hi));  % select moles in bounds
% for m=mIdx
%   mOn = mole(2,m);
%   if mole(7,m)
%     mOff=mole(7,m);
%   else
%     mOff=mOn+1.25;
%   end
%   type = mole(3,m);
%   plot([mOn;mOff], [type;type]/20, 'LineWidth',2, 'Color',clr(type,:));
%   switch mole(6,m)
%    case 1
%     plot(mole(7,m),type/20,'k^','MarkerSize',10);
%    case 2
%     plot(mole(7,m),type/20,'kv','MarkerSize',10);
%   end
% end

for i=1:numIVs
  r = reaches{i}
  if ~isempty(r)
    for riv = r'
      plot(riv, [0 0], 'k.-','LineWidth',3);
    end
  end
end