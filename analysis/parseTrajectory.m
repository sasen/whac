function [reachOns, hitOns] = parseTrajectory(g, pl)
% function [reachOns, hitOns] = parseTrajectory(g, pl)
% Find onsets of a player's hits & reaches, using pos, speed, & accel thresholds.
% NOTE: Set thesholds in this function!
% g: loaded game
% pl: player number (1 or 2)
%-----
% reachOns: list of reach onsets
% hitOns: list of hit onsets

%% Thresholds
posThresh = 0.5;    % inches
spdThresh = 40;     % trackerframes/inches
accThresh = 0.019;  % inches/trackerframes^2


%% Create interpolated timecourse of this player's 3d tracker data
s = min(g.t); e = max(g.t);
t = [s:e];
if pl == 1
  xyz =  [g.p1x(t); g.p1y(t); g.p1z(t)];
elseif pl == 2
  xyz =  [g.p2x(t); g.p2y(t); g.p2z(t)];
else
  error('%s: %d is not a valid player number (1 or 2).',mfilename,pl);
end
xyzin = inv(g.in2px(1:3,1:3)) * xyz;  %% convert to inches

% Candidate hit points based on acceleration peaks
[acc,accPks] = accelPeaks(xyzin, 3, accThresh, 1);

% Stillness & hit indicators
[still, hitting] = stillness(xyzin, spdThresh, posThresh);

% Get hit onsets by comparing accel peaks & hit-indicator
hitOns = crosscheckHits(hitting, accPks);

% Find reaches: Retrospectively compare hit onsets to stillness
reachOns = reachFinder(hitOns, still);
