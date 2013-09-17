function [E,Eb] = LoadExpt(s1,s2,ExpNum)
% Load all trials and flatten experiment (mole presentation) info
% function [E,Eb] = LoadExpt(s1,s2,ExpNum)
%   s1, s2 (string) = playerID1 & playerID2
%   ExpNum (num) = experiment number
%   E: 1 x numTrl cell of loaded trial data structs, with 2 modifications
%   -- no nans in TrackList 
%   -- mole: 2x1 cell of flattened mole info (fullscreen games only need mole{1})
%   Eb: 2 x numTrl cell of flattened mole info (optional output! E has mole)

f1=load(GameFName(s1,s2,ExpNum,1));  % load first one to get some info

Eb = cell(2,f1.nMaxTrials);   % optional output
for t=1:f1.nMaxTrials  % load each trial
  E{t}=load(GameFName(s1,s2,ExpNum,t));

  mole=cell(2,1);
  [mole,xyzt] = FlattenMoleInfo(E{t});
  E{t}.TrackList = xyzt;
  E{t}.mole = mole;
  Eb(:,t) = mole;  % optional output for backwards compatibility
end  % for each trial
