function [D,perf] = Performance(s1,s2,ExpNum)
% Performance, load all trials and get percent of targets hit
% s1 (string) = playerID1
% s1 (string) = playerID2
% ExpNum (integer) = 


if ExpNum==3
    gameType='RunSplitgame';
elseif ExpNum==4
    gameType='RunDistractors';
end

for t=1:21
    D{t}=load(['Results/' gameType '/' s1 '_' s2 '/' s1 '_' s2 '_t' num2str(t) '_e' num2str(ExpNum) '.mat']);
        for p = [1 2]  % for each player
	  appearedIJs = find(D{t}.TrialList{p}/1000 < 30);  % indices of all appearing dots
	  targetIJs = find(D{t}.MoleTypeList{p}(appearedIJs) <= 2); ...
	  % indices of appearing target dots (green & yellow)
	  totalTargets(p,t) = sum(D{t}.MoleTypeList{p}(appearedIJs) <= 2);

	  hitIJs = find(D{t}.HitList_p{p});
	  hitTargets(p,t) = sum(D{t}.HitList_p{p}(targetIJs)/p);
        end % for each player
end  % for each trial
perf = hitTargets./totalTargets;