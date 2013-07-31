function AngInfo = AngleError(tOn,tEnd,xyz,t)
%AngleError Summary of this function goes here
%   Detailed explanation goes here
%tOn = 1567; tEnd=1983;
%xyz = D{4}.TrackList{1}; t=D{4}.TrackList{3};

% ignore if we never raised above z-threshold
if max(xyz(3,tOn:tEnd)) < 0.5
  AngInfo = [NaN tOn tEnd NaN];
  return
end

velocity=[];
zVelo=[];
for i=0:tEnd-tOn
    xPos1         = xyz(1,tOn+i);
    yPos1         = xyz(2,tOn+i);
    zPos1         = xyz(3,tOn+i);
    xPos2         = xyz(1,tOn+i-1);
    yPos2         = xyz(2,tOn+i-1);
    zPos2         = xyz(3,tOn+i-1);
    tDiff         = (t(tOn+i)-t(tOn+i-1));
    velocity(i+1) = (sqrt((xPos2-xPos1)^2+(yPos2-yPos1)^2))/tDiff;
    zVelo(i+1)    = (zPos2-zPos1)/tDiff;
end
iLogic         = zVelo>0;  
velIdx = find(iLogic) + tOn-1;
% [~, iSt] = max(xyz(3,tOn:tEnd).*iLogic);   %% start at the top (max z in that interval)
% iSt = iSt + tOn-1;
ups = find(~iLogic,3,'first') +tOn-1;  %% start at first pull up
if numel(ups)==0
  iSt=tOn;
else
  iSt = ups(end);
end
iEnd = tEnd;
iRange = [zeros(1,iSt-tOn) ones(1,iEnd-iSt+1)]; % max must be after iSt
[~,iMax] = max(velocity.*iLogic.*iRange);
iMax = iMax + tOn-1;

vertex  = xyz(1:2,iSt); 
finalpt = xyz(1:2,iEnd) - vertex;
maxVpt  = xyz(1:2,iMax) - vertex;
CosTheta = dot(finalpt,maxVpt)/(norm(finalpt)*norm(maxVpt));
theta = acos(CosTheta)*180/pi;
Angle = min(theta,180-theta);  % symmetric past 180

AngInfo = [Angle, iSt, iEnd, iMax];

% fvec = [vertex finalpt+vertex; [0 0]];

% figure; hold on;
% %- reach start-to-end straightline in green
% plot3(fvec(1,:),fvec(2,:),[xyz(3,iSt) xyz(3,iEnd)],'g-');
% plot3(fvec(1,:),fvec(2,:),fvec(3,:),'g-');
% %-  full trajectory in blue
% plot3(xyz(1,tOn:tEnd),xyz(2,tOn:tEnd),zeros(1,tEnd-tOn+1),'b.-')
% plot3(xyz(1,tOn:tEnd),xyz(2,tOn:tEnd),xyz(3,tOn:tEnd),'b.-')
% %-  z decreasing trajectory in red
% plot3(xyz(1,velIdx),xyz(2,velIdx),zeros(size(velIdx)),'r.');
% plot3(xyz(1,velIdx),xyz(2,velIdx),xyz(3,velIdx),'r.');
% %- start to max-velocity point in black
% plot3([xyz(1,iSt) xyz(1,iMax)],[xyz(2,iSt) xyz(2,iMax)],[0,0],'k.-');
% plot3([xyz(1,iSt) xyz(1,iMax)],[xyz(2,iSt) xyz(2,iMax)],[xyz(3,iSt) xyz(3,iMax)],'k.-');
% %- start point green star
% plot3(xyz(1,iSt),xyz(2,iSt),0,'g*','MarkerSize',10)
% plot3(xyz(1,iSt),xyz(2,iSt),xyz(3,iSt),'g*','MarkerSize',10)
% %- end point black circle
% plot3(xyz(1,iEnd),xyz(2,iEnd),0,'ko','MarkerSize',10)
% plot3(xyz(1,iEnd),xyz(2,iEnd),xyz(3,iEnd),'ko','MarkerSize',10)
% %- labels
% title('Blue[tOn:tEnd] Red[zVelo>0] Gr=iSt Bk=iMax BlackRing=iEnd');
% xlabel(['Angle (deg):' num2str(Angle)])

end