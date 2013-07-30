function [Angle] = AngleError(tStart,tEnd,xyz,t)
%AngleError Summary of this function goes here
%   Detailed explanation goes here

tOn  = (find(abs(t-tStart*240)<1,1,'first'))
tEnd = (find(abs(t-tEnd*240)<1,1,'first'))

velocity=NaN(1,tEnd-tOn+1);
for i=0:tEnd-tOn
    xPos1         = xyz(1,tOn+i);
    yPos1         = xyz(2,tOn+i);
    xPos2         = xyz(1,tOn+i-1);
    yPos2         = xyz(2,tOn+i-1);
    tDiff         = (t(tOn+i)-t(tOn+i-1));
    velocity(i+1) = (sqrt((xPos2-xPos1)^2+(yPos2-yPos1)^2))/tDiff;
    zPos(i+1)     = xyz(3,tOn+i);
end
velocity
[maxZ,tMaxZ]   = max(xyz(3,tOn:tEnd))
velocity       = velocity(tMaxZ:end)
[maxVelo,tMax] = max(velocity)

% xPosVertex  = xyz(1,tOn);
% yPosVertex  = xyz(2,tOn);
% xPosFinal   = xyz(1,tEnd);
% yPosFinal   = xyz(2,tEnd);
% xPosMaxVelo = xyz(1,tMax+tOn);
% yPosMaxVelo = xyz(2,tMax+tOn);

vertex  = xyz(1:2,tOn); 
finalpt = xyz(1:2,tEnd)-vertex;
maxVpt = xyz(1:2,tMax+tOn) - vertex;

% xPOS=[xPosFinal,xPosVertex,xPosMaxVelo];
% yPOS=[yPosFinal,yPosVertex,yPosMaxVelo];



CosTheta = dot(finalpt,maxVpt)/(norm(finalpt)*norm(maxVpt));
Angle = acos(CosTheta)*180/pi;

fvec = [vertex finalpt+vertex];
maxV = maxVpt+vertex;

figure
plot(fvec(1,:),fvec(2,:),'g-'); hold on
plot(xyz(1,tOn:tEnd),xyz(2,tOn:tEnd),'r.')
plot(maxV(1),maxV(2),'k.');
title(['Angle (deg)' Angle ' Max Z ' maxZ ' @' tMaxZ])
figure
plot3(xyz(1,tOn:tEnd),xyz(2,tOn:tEnd),xyz(3,tOn:tEnd),'b.-')
end