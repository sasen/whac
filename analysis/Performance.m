%function [D,Dex,perf] = Performance(s1,s2,ExpNum)
% Performance, load all trials and get percent of targets hit
% s1 (string) = playerID1
% s1 (string) = playerID2
% ExpNum (integer) = 3 is Splitgame, 4 = Distractors

s1 = 'jlp'; s2 = 'ss'; ExpNum = 3; 

[D, Db] = LoadExpt(s1,s2,ExpNum);
[~, maxTrials] = size(Db);

for t=1:maxTrials  % load each trial
  for p = [1 2]  %  each player
    totalTargets(p,t) = sum(Db{p,t}(3,:) <= 2);
    hitTargets(p,t) = sum(Db{p,t}(7,:) > 0);
  end % for each player
end  % for each trial
perf = hitTargets./totalTargets