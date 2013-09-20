function h = MakeInterpolants(h)
% function h = MakeInterpolants(h)
% Provides linear interpolation on TrackList
% The saved-trial-matfile object h receives...
% h.t: vector of timestamps, replacing h.TrackList{3}
% h.p1x, h.p1y, h.p1x [and the same for p2]:
%   griddedInterpolants, replacing h.TrackList{1:2}

%% if t(a) == t(a+1), t(a+1) := NaN
t = h.TrackList{3};
repeats = find(diff(t)==0);
t(repeats+1) = NaN;

%% finite t
ti = find(isfinite(t));
t = t(ti);

%% interpolants
h.p1x = griddedInterpolant(t,h.TrackList{1}(1,ti));
h.p1y = griddedInterpolant(t,h.TrackList{1}(2,ti));
h.p1z = griddedInterpolant(t,h.TrackList{1}(3,ti));
h.p2x = griddedInterpolant(t,h.TrackList{2}(1,ti));
h.p2y = griddedInterpolant(t,h.TrackList{2}(2,ti));
h.p2z = griddedInterpolant(t,h.TrackList{2}(3,ti));
h.t = t;