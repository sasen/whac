function [mole, xyzt] = FlattenMoleInfo(g)
% Flatten & collect mole presentation & hit info, and remove nans from tracker.
% function [mole, xyzt] = FlattenMoleInfo(g)
%    g = saved game mat data (struct)
%    mole = collected mole info
%      cell 1 = fullscreen, or p1's side if split
%      cell 2 = [], or p2's side
%    xyzt = tracker data ({p1xyz, p2xyz, t})
%
%  mole{1}(1,:) = appearedIJs;  % original indices (flattened)
%  mole{1}(2,:) = g.TrialList(appearedIJs)/1000;    % onset times in s
%  mole{1}(3,:) = g.MoleTypeList(appearedIJs); % mole color
%  mole{1}(4,:) = g.LocationListX(appearedIJs); % mole x position
%  mole{1}(5,:) = g.LocationListY(appearedIJs); % mole y position
%  mole{1}(6,:) = g.HitList_p(appearedIJs); % which player hit (0=none, 1=p1, 2=p2)
%  mole{1}(7,:) = g.HitList_t(appearedIJs); % successful hit time in s

%% remove NaNs from tracker data
iLogic=isfinite(g.TrackList{3});   % logical indices of not-NaN data
xyzt{3} = g.TrackList{3}(iLogic);
xyzt{1} = g.TrackList{1}(:,iLogic);
xyzt{2} = g.TrackList{2}(:,iLogic);

duration = g.TrialLength;
if ischar(g.ExpNum)
  g.ExpNum = str2double(g.ExpNum);
end
mole = cell(2,1);

if (g.ExpNum < 2)  %% this is for versions of RunFullscreen
  [times, sortIndex] = sort(g.TrialList(:)/1000);  % sort flattened onset times in s
  appearedIJs = sortIndex(find(times<duration));  % indices of all appeared dots, sorted in time
  
  mole{1}(1,:) = appearedIJs;  % original indices (flattened)
  mole{1}(2,:) = g.TrialList(appearedIJs)/1000;    % onset times in s
  mole{1}(3,:) = g.MoleTypeList(appearedIJs); % mole color
  mole{1}(4,:) = g.LocationListX(appearedIJs); % mole x position
  mole{1}(5,:) = g.LocationListY(appearedIJs); % mole y position
  mole{1}(6,:) = g.HitList_p(appearedIJs); % which player hit (0=none, 1=p1, 2=p2)
  mole{1}(7,:) = g.HitList_t(appearedIJs); % successful hit time in s
else  % versions of RunSplit make 2x each variable.
  for p = [1 2]  %  each player
    [times, sortIndex] = sort(g.TrialList{p}(:)/1000);  % sort flattened onset times in s
    appearedIJs = sortIndex(find(times<duration));  % indices of all appeared dots, sorted in time
    
    mole{p}(1,:) = appearedIJs;  % original indices (flattened)
    mole{p}(2,:) = g.TrialList{p}(appearedIJs)/1000;    % onset times in s
    mole{p}(3,:) = g.MoleTypeList{p}(appearedIJs); % mole color
    mole{p}(4,:) = g.LocationListX{p}(appearedIJs); % mole x position
    mole{p}(5,:) = g.LocationListY{p}(appearedIJs); % mole y position
    mole{p}(6,:) = g.HitList_p{p}(appearedIJs); % which player hit (0=none, 1=p1, 2=p2)
    mole{p}(7,:) = g.HitList_t{p}(appearedIJs); % successful hit time in s
  end % for each player
end % if expnum

