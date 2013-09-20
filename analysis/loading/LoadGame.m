function G = LoadGame(s1,s2,ExpNum,t)
% Load a single game/trial, cleanup tracker data & mole info
% function G = LoadGame(s1,s2,ExpNum,t)
%   s1, s2 (string) = playerID1 & playerID2
%   ExpNum (num) = experiment number
%   t (num) = trial number
%   G: loaded game data struct, with these modifications
%   -- no nans in TrackList 
%   -- p1x, p1y, p1z, p2x, p2y, p2z: griddedInterpolants of TrackList{1:2}
%   -- mole: 2x1 cell of flattened mole info (fullscreen games only need mole{1})


G=load(GameFName(s1,s2,ExpNum,t));

[mole,xyzt] = FlattenMoleInfo(G);
G.TrackList = xyzt;
G.mole = mole;

G = MakeInterpolants(G);