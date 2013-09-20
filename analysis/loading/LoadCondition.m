function [Cond, pairList] = LoadCondition(condition)
% function [Cond, pairList] = LoadCondition(condition)
% condition (str) = eg 'RunSplitgamePaired'
% Cond (cell()) = (numPairs x maxTrlNum) array of structs
%   - each struct is a trial's TrackList, mole, and pnames.
% pairList (cell(3)) = {1} p1 names, {2} is p2 names, {3} p1_p2 names.

dataDir='../../WAM/';  %% must have symlink to Dropbox results folder
condDirName=[dataDir condition '/'];
pairList = getPairsInDir(condDirName);
numPairs = length(pairList{3});

if strcmp(condition,'RunDistractors')
  ExpNum = 4;
elseif strcmp(condition(1:12),'RunSplitgame')
  ExpNum = 3;
end

for i = 1:numPairs
  disp([condition ' ' num2str(i) ' of ' num2str(numPairs)]);
  Cond(i,:) = LoadExpt(pairList{1}{i},pairList{2}{i},ExpNum,'less');
end
