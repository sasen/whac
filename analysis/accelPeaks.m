function [accel_ddT, peakloc_T] = accelPeaks(pos3D,dim,thresh,useAbsSpeed)
%function [accel_ddT, peakloc_T] = accelPeaks(pos3D,dim,thresh,useAbsSpeed)
% accelPeaks: Get acceleration & find height-thresholded peaks for hit detection
% pos3d: 3xN xyz position timecourse array (interpolated > 2nd order)
% dim: which dimension's acceleration (1/2/3 ~ x/y/z)
% thresh: scalar sent to findpeaks's MINPEAKHEIGHT
% useAbsSpeed: (boolean) use speed instead of velocity
%-----
% accel_ddt: 1x(N-2) acceleration trajectory
% peakloc_T: indices of peaks, shifted by 2 (to plot against position)

%% Processing inputs
if nargin ~= 4
  help mfilename
  error('%s: wrong number of inputs (%d)!',mfilename,nargin);
end 

pos1D = pos3D(dim,:);
firstD = diff(pos1D);

if useAbsSpeed == 1
  firstD = abs(firstD);
  accelsign = -1;
elseif useAbsSpeed == 0
  accelsign = 1;
else
  help mfilename
  error('%s: useAbsSpeed must be 0 or 1 (%d)!',mfilename,useAbsSpeed);
end

accel_ddT = diff(firstD);
[~,loc] = findpeaks(accelsign*accel_ddT, 'MINPEAKHEIGHT', thresh);
peakloc_T = loc + 2;
