% ReachScore: compute penalty function for windowed tracker data. 

s1 = 'jlp'; s2 = 'ss'; ExpNum = 3; tr=21;
% s1 = '35'; s2 = 'sasen'; ExpNum = 1; tr=39;

[D,Db] = LoadExpt(s1,s2,ExpNum);
pl=2;
if ExpNum==1
  mole = Db{tr};
else
  mole = Db{pl,tr};
end
maxT=500;
dt=20;

xyz = D{tr}.TrackList{pl}(:,1:maxT);
trackt = D{tr}.TrackList{3}(:,1:maxT)/240;
tWins = reshape(trackt,dt,maxT/dt);
zWins = reshape(xyz(3,:),dt,maxT/dt);
atT(1,:) = tWins(end,:);
atT(2,:) = mean(zWins);
atT = atT';

% for a=1:maxT/dt
%   atT(2,a) = tWins(:,a)
% end

% deltaT=0.1;
% dt = [deltaT:deltaT:trackt(end)];
% twin
% tWin=1; trt=0;
% for t=dt
%   t
%   while trt < t - deltaT
%     trt 
%   end
% end

%lo=3; hi=5;  % bounds in s
% mIdx = find((mole(2,:) >lo) & (mole(2,:) < hi));  % select moles in bounds
% mHit = mole(7,mIdx);
% mType = mole(3,mIdx);
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
%      plot(mole(7,m),type/20, 'k^');
%    case 2
%      plot(mole(7,m),type/20, 'kv');
%   end
% end
