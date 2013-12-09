function [xyzin, s, e, xyz] = interpolatePlayer(g, pl)
% function [xyzin, s, e, xyz] = interpolatePlayer(g, pl)
% g = loaded game
% pl = player number (1 or 2)
%---
% xyzin = 3D position (inches) interpolated for each tracker frame
% s = lowest tracker frame number
% e = highest tracker frame number
% (opt) xyz = like xyzin, except x/y = pixels, z = inches

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
