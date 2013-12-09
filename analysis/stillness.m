function [still, hitting, xb, yb, zb, zpos, dinv] = stillness(pos3d, movethresh, zposthresh)
%function [still, hitting, xb, yb, zb, zpos, dinv] = stillness(pos3d, movethresh, zposthresh)
% Indicator functions for still timepoints, via inverse-speed and height.
% pos3d: 3xN xyz position timecourse array (interpolated)
% movethresh: inverse-speed threshold for all 3 dimensions
% zposthresh: height threshold for counting as a hit (in pos3d units)
%----
% still: anded x, y, and z stillness
% hitting: possible hit indicator
% (opt) xb / yb / zb: stillness indicator in x / y / z
% (opt) zpos: indicator that height is low enough to be a hit
% (opt) dinv: 3x(N-1) inverse speed timecourses

dinv = 1./abs(diff(pos3d')');
xb = binarize(dinv(1,:), movethresh);
yb = binarize(dinv(2,:), movethresh);
zb = binarize(dinv(3,:), movethresh);

zpos = pos3d(3,2:end) < zposthresh;
still = xb & yb & zb;
hitting = still & zpos;

