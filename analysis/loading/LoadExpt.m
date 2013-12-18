function [E,Eb] = LoadExpt(s1,s2,ExpNum,varargin)
% Load all trials and flatten experiment (mole presentation) info
% function [E,Eb] = LoadExpt(s1,s2,ExpNum,varargin)
%   s1, s2 (string) = playerID1 & playerID2
%   ExpNum (num) = experiment number
%   varargin = OPTIONAL arguments (eg variable names) to 'load'
%   E: 1 x numTrl cell of loaded trial data structs, with
%   -- no nans in TrackList 
%   -- griddedInterpolants of TrackList{1:2} called p1x, p1y, ..., p2z.
%   -- mole: 2x1 cell of flattened mole info (fullscreen games only need mole{1})
%   Eb: 2 x numTrl cell of flattened mole info (optional output! E has mole)

[~,nMats] = GameFName(s1,s2,ExpNum,1);  % look at first one to get some info

Eb = cell(2,nMats);   % optional output
for t=1:nMats  % load each trial
  try
    g=load(GameFName(s1,s2,ExpNum,t));
  catch ME
    if t < 21  % handling one restarted subj (too many trials)
      rethrow(ME);
    end
    break
  end

  if length(varargin) > 0
    if strcmp(varargin{1},'all')
      E{t} = g;
    elseif strcmp(varargin{1},'less')
      E{t}=load(GameFName(s1,s2,ExpNum,t),'TrackList','pname1','pname2');
    else
      E{t}=load(GameFName(s1,s2,ExpNum,t),varargin{:});
    end
  else
    E{t} = g;
  end

  mole=cell(2,1);
  [mole,xyzt] = FlattenMoleInfo(g);
  E{t}.TrackList = xyzt;
  E{t}.mole = mole;
  Eb(:,t) = mole;  % optional output for backwards compatibility
  E{t} = MakeInterpolants(E{t});
end  % for each trial
