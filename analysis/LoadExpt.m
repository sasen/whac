function [D,Db] = LoadExpt(s1,s2,ExpNum)
% Load all trials and flatten experiment (mole presentation) info
% s1 (string) = playerID1
% s1 (string) = playerID2
% ExpNum (integer) = 3 is Splitgame, 4 = Distractors
% D (cell(1,21)) of loaded trial data structs
% Db (cell(2,21)) of player-trial flattened mole info

dirbase = ['../../WAM/'];  % for compatibility with git & dropbox users
pairname = [s1 '_' s2];
if ExpNum==1
    gameType='RunFullscreen';
    matdir = [dirbase gameType '/HonestConfederate/' pairname '/'];
    maxTrials=39;
elseif ExpNum==1.01
    gameType='RunFullscreen';
    matdir = [dirbase gameType '/NaberSubjVsSubj/' pairname '/'];
    maxTrials=1;
elseif ExpNum==2
    gameType='RunMirrored';
    matdir=[dirbase gameType '/' pairname '/'];
    maxTrials=21;   % not set in stone
elseif ExpNum==3
    gameType='RunSplitgame';
    matdir=[dirbase gameType '/' pairname '/'];
    maxTrials=21;
elseif ExpNum==4
    gameType='RunDistractors';
    matdir=[dirbase gameType '/' pairname '/'];
    maxTrials=21;
end
assert(exist(matdir,'dir')==7, 'LoadExpt: Cannot find directory %s.',matdir);

% Db: each cell is a matrix of flattened mole info variables
% splitscreens have 2 expts; fullscreen/mirrored will have empty 2nd row
Db = cell(2,maxTrials);  

for t=1:maxTrials  % load each trial
  filename = [matdir pairname '_t' num2str(t) '_e' num2str(ExpNum) '.mat'];
  D{t}=load(filename);
  duration = D{t}.TrialLength;

  %% remove NaNs from tracker data
  iLogic=isfinite(D{t}.TrackList{3});   % logical indices of not-NaN data
  D{t}.TrackList{3} = D{t}.TrackList{3}(iLogic);
  D{t}.TrackList{1} = D{t}.TrackList{1}(:,iLogic);
  D{t}.TrackList{2} = D{t}.TrackList{2}(:,iLogic);

  %% Handle gametypes differently. Split makes 2x each variable.
  if (ExpNum < 2)  %% this is for versions of fullscreen
    [times, sortIndex] = sort(D{t}.TrialList(:)/1000);  % sort flattened onset times in s
    appearedIJs = sortIndex(find(times<duration));  % indices of all appeared dots, sorted in time
    
    Db{1,t}(1,:) = appearedIJs;  % original indices (flattened)
    Db{1,t}(2,:) = D{t}.TrialList(appearedIJs)/1000;    % onset times in s
    Db{1,t}(3,:) = D{t}.MoleTypeList(appearedIJs); % mole color
    Db{1,t}(4,:) = D{t}.LocationListX(appearedIJs); % mole x position
    Db{1,t}(5,:) = D{t}.LocationListY(appearedIJs); % mole y position
    Db{1,t}(6,:) = D{t}.HitList_p(appearedIJs); % which player hit (0=none, 1=p1, 2=p2)
    Db{1,t}(7,:) = D{t}.HitList_t(appearedIJs); % successful hit time in UNITS
  else
    for p = [1 2]  %  each player
      [times, sortIndex] = sort(D{t}.TrialList{p}(:)/1000);  % sort flattened onset times in s
      appearedIJs = sortIndex(find(times<duration));  % indices of all appeared dots, sorted in time
      
      Db{p,t}(1,:) = appearedIJs;  % original indices (flattened)
      Db{p,t}(2,:) = D{t}.TrialList{p}(appearedIJs)/1000;    % onset times in s
      Db{p,t}(3,:) = D{t}.MoleTypeList{p}(appearedIJs); % mole color
      Db{p,t}(4,:) = D{t}.LocationListX{p}(appearedIJs); % mole x position
      Db{p,t}(5,:) = D{t}.LocationListY{p}(appearedIJs); % mole y position
      Db{p,t}(6,:) = D{t}.HitList_p{p}(appearedIJs); % which player hit (0=none, 1=p1, 2=p2)
      Db{p,t}(7,:) = D{t}.HitList_t{p}(appearedIJs); % successful hit time in UNITS
    end % for each player
  end % if expnum
end  % for each trial
