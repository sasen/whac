function [reachOns, hitOns] = parseTrajectory(g, pl)
% function [reachOns, hitOns] = parseTrajectory(g, pl)
% Find onsets of a player's hits & reaches, using pos, speed, & accel thresholds.
% NOTE: Reset thesholds in this function!
% g: loaded game
% pl: player number (1 or 2)
%-----
% reachOns: list of reach onsets
% hitOns: list of hit onsets

%% Thresholds
posThresh = 0.5;    % inches
spdThresh = 40;     % trackerframes/inches
accThresh = 0.019;  % inches/trackerframes^2
tframeHz  = 240;    % trackerframes/second

% Get this player's interpolated 3d timecourse
[xyzin, s, e] = interpolatePlayer(g, pl);

% Candidate hit points based on acceleration peaks
[~, accPks] = accelPeaks(xyzin, 3, accThresh, 1);

% Stillness & hit indicators
[still, hitting] = stillness(xyzin, spdThresh, posThresh);

% Get hit onsets by comparing accel peaks & hit-indicator
hitOns = crosscheckHits(hitting, accPks);

firstOn = g.mole{pl}(2,1)*tframeHz;     % 1st mole onset time in trackerframes
hitOns = hitOns(find(hitOns>firstOn));  % remove "hits" prior to stim presentation

% Find reaches: Retrospectively compare hit onsets to stillness
reachOns = reachFinder(hitOns, still);
