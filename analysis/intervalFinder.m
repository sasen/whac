function intervals = intervalFinder(mole,lo,hi)
% intervalFinder: find intervals where rewarding targets are displayed
% intervals = intervalFinder(mole,lo,hi)
% mole = 7x30ish matrix (aka Db from LoadExpt)
% lo = (real) time (s) to start search. OPTIONAL, default=0
% hi = (real) time (s) to stop search. OPTIONAL, default=60
% intervals = Zx2 matrix for Z identified intervals.
%   column 1 is the start time (s) of the interval, col 2 is the end.

%% Testing as a script
% s1 = 'jlp'; s2 = 'ss'; ExpNum = 3; tr=21;
% % s1 = '35'; s2 = 'sasen'; ExpNum = 1; tr=39;
% [D,Db] = LoadExpt(s1,s2,ExpNum);
% pl=2;
% if ExpNum==1
%   mole = Db{tr};
% else
%   mole = Db{pl,tr};
% end

%% Test plots
% clr = D{tr}.TargetColors/255;
% figure; hold on;

switch nargin
 case 1
  lo=0; hi=60;  % bounds in s
 case 2
  hi = 60;
end

mIdx = find((mole(2,:) >lo) & (mole(2,:) < hi));  % select moles in bounds
mType = mole(3,mIdx);

intervals = [];
intOn = hi; intOff = lo;   % initialize interval huggers
for m=mIdx   % go through moles in order of onset time
  mOn = mole(2,m);
  if mole(7,m)
    mOff=mole(7,m);
  else
    mOff=mOn+1.25;
  end
  type = mole(3,m);

  % get interval onset for rewarding targets
  if (type <=2)
    if (mOn > intOff)   % interval gap
      intervals(end+1,:) = [intOn intOff];   % store completed interval
      intOn = hi; intOff = lo;   % reinitialize interval huggers
    end
    intOn  = min(intOn,mOn);
    intOff = max(intOff,mOff);
  end

%   plot([mOn;mOff], [type;type]/20, 'LineWidth',2, 'Color',clr(type,:));
%   switch mole(6,m)
%    case 1
%     plot(mole(7,m),type/20,'kv','MarkerSize',10);
%    case 2
%     plot(mole(7,m),type/20,'k^','MarkerSize',10);     
%   end

end
intervals(end+1,:) = [intOn intOff];   % store completed interval
intervals = intervals(2:end,:);   % 1st row is always [hi lo] (init values)

% axis([lo hi -0.05 0.35]);
% for intv=intervals'
%   plot(intv', [0;0], 'k-','LineWidth',4);
% end