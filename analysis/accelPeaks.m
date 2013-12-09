function [accel_ddT, peakloc_T] = accelPeaks(pos3D,dim,thresh,scaleBy,useAbsSpeed)

% HEREHEREHERE
if nargin <= 5
  pos1D = pos3D(dim,:);
  if nargin <= 4
    useAbsSpeed = 1;
  else
    assert((useAbsSpeed==0) || (useAbsSpeed==1),'%s: useAbsSpeed must be logical scalar.',mfilename)
    help mfilename
  end %% 4 or less
else
  help mfilename
  error('%s: %d is too many inputs!',mfilename,nargin);
end 

switch nargin
  case 5

    
 case 2
 case 3


end


%% QUESTION: can we find hiton & hitoff separately?

% zaccv = diff(diff(xyzin(3,:)));
% [pkv,locv]=findpeaks(zaccv,'MINPEAKHEIGHT',0.019); 

accel_ddT = 1000*diff(abs(diff(pos1D)));
[~,loc] = findpeaks(-accel_ddT,'MINPEAKHEIGHT',19);
peakloc_T = loc + 2;
