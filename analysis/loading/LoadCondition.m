function [Cond, pairList] = LoadCondition(condition,varargin)
% function [Cond, pairList] = LoadCondition(condition,varargin)
% condition (str) = eg 'RunSplitgamePaired'
% varargin = OPTIONAL arguments (eg varnames) to 'load', 
%     or 'all', or 'less' (default)
% Cond (cell()) = (numPairs x maxTrlNum) array of structs
%   - each struct is a trial's TrackList, mole, and pnames.
% pairList (cell(3)) = {1} p1 names, {2} is p2 names, {3} p1_p2 names.

if nargin == 0
  help(mfilename)
elseif nargin == 1
  varnames = {'less'};
else
  varnames = varargin;
end


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
  Cond(i,:) = LoadExpt(pairList{1}{i},pairList{2}{i},ExpNum,varnames{:});
end
