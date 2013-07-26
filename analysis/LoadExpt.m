function [D,Db] = LoadExpt(s1,s2,ExpNum)
% Performance, load all trials and get percent of targets hit
% s1 (string) = playerID1
% s1 (string) = playerID2
% ExpNum (integer) = 3 is Splitgame, 4 = Distractors
% D (cell(1,21)) of loaded trial data structs
% Db (cell(2,21)) of player-trial flattened mole info

if ExpNum==3
    gameType='RunSplitgame';
    maxTrials=21;
elseif ExpNum==4
    gameType='RunDistractors';
    maxTrials=21;
end

Db = cell(2,maxTrials);  % each cell is a matrix of flattened mole info variables

for t=1:maxTrials  % load each trial
    D{t}=load(['Results/' gameType '/' s1 '_' s2 '/' s1 '_' s2 '_t' num2str(t) '_e' num2str(ExpNum) '.mat']);
        for p = [1 2]  %  each player
	  [times, sortIndex] = sort(D{t}.TrialList{p}(:)/1000);  % sort flattened onset times in s
	  appearedIJs = sortIndex(find(times<30));  % indices of all appeared dots, sorted in time

	  Db{p,t}(1,:) = appearedIJs;  % original indices (flattened)
	  Db{p,t}(2,:) = D{t}.TrialList{p}(appearedIJs)/1000;    % onset times in s
	  Db{p,t}(3,:) = D{t}.MoleTypeList{p}(appearedIJs); % mole color
	  Db{p,t}(4,:) = D{t}.LocationListX{p}(appearedIJs); % mole x position
	  Db{p,t}(5,:) = D{t}.LocationListY{p}(appearedIJs); % mole y position
	  Db{p,t}(6,:) = D{t}.HitList_p{p}(appearedIJs); % which player hit (0=none, 1=p1, 2=p2)
	  Db{p,t}(7,:) = D{t}.HitList_t{p}(appearedIJs); % successful hit time in UNITS
        end % for each player
end  % for each trial
