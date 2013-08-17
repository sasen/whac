function E = LoadExpt(s1,s2,ExpNum)
% Load all trials and flatten experiment (mole presentation) info
% function E = LoadExpt(s1,s2,ExpNum)
%   s1, s2 (string) = playerID1 & playerID2
%   ExpNum (num) = experiment number
%   E: 1 x numTrl cell of loaded trial data structs, with 2 modifications
%   -- no nans in TrackList 
%   -- mole: 2x1 cell of flattened mole info (fullscreen games only need mole{1})

for t=1:maxTrials  % load each trial
  E{t}=load(GameFName(s1,s2,ExpNum,t));

  mole=cell(2,1);
  [mole,xyzt] = FlattenMoleInfo(E{t});
  E{t}.TrackList = xyzt;
  E{t}.mole = mole;

end  % for each trial
