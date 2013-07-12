function [xPosOut1, yPosOut1, zPosOut1, xPosOut2, yPosOut2,zPosOut2] = TransformTrackerData(data,calcorners,ScrRes,fitval)
%function [xPos1, yPos1, zPos1, xPos2, yPos2, zPos2, xPos3, yPos3, zPos3, xPos4, yPos4, zPos4] = TransformTrackerData(data,calcorners,ScrRes,fitval)

% z = data(3,:)
% x = data(4,:)
% y = data(5,:)

xPos(1,:) = ScrRes(1)*data(4,:)/(calcorners(2,3,1)-calcorners(2,1,1)); % 18.5"
yPos(1,:) = ScrRes(2)*data(5,:)/(calcorners(3,2,2)-calcorners(1,2,2));  % 13+12/16"
zPos(1,:) = data(3,:);

xPos(2,:) = ScrRes(1)*((data(4,:)-nanmean(calcorners(:,1,1)))/(nanmean(calcorners(:,3,1))-nanmean(calcorners(:,1,1))));
yPos(2,:) = ScrRes(2)*((data(5,:)-nanmean(calcorners(1,:,2)))/(nanmean(calcorners(3,:,2))-nanmean(calcorners(1,:,2))));
zPos(2,:) = data(3,:);

% table ranges:
% calcorners(1,1) = left/top
% calcorners(1,2) = top
% calcorners(1,3) = right/top
% calcorners(2,1) = left

% calcorners(2,3) = right
% calcorners(3,1) = left/bottom
% calcorners(3,2) = bottom
% calcorners(3,3) = right/bottom

% plot(nanmean(calcorners(:,:,1)),nanmean(calcorners(:,:,2)),'r')
data(5,:) = data(5,:)+(-1*fitval(1)*data(4,:));
calcorners(:,:,2) = calcorners(:,:,2)+(-1*fitval(1,1)*calcorners(:,:,1));

% plot(nanmean(calcorners(:,:,2),2),nanmean(calcorners(:,:,1),2),'r')

% fitval = polyfit(nanmean(calcorners(:,:,2),2),nanmean(calcorners(:,:,1),2),1);

data(4,:) = data(4,:)+(-1*fitval(2,1)*data(5,:));
calcorners(:,:,1) = calcorners(:,:,1)+(-1*fitval(2,1)*calcorners(:,:,2));

% data(3,:) = data(3,:) - (-0.0024*(data(4,:).^2));
% data(3,:) = data(3,:) - (-0.0022*(data(5,:).^2)-0.01*data(5,:));
% data(4,:) = data(4,:) - (-0.0012*(data(5,:).^3)+0.0057*(data(5,:).^2)+0.09*data(5,:));

data(4,:) = ScrRes(1)*((data(4,:)-nanmean(calcorners(:,1,1)))/(nanmean(calcorners(:,3,1))-nanmean(calcorners(:,1,1))));
data(5,:) = ScrRes(2)*((data(5,:)-nanmean(calcorners(1,:,2)))/(nanmean(calcorners(3,:,2))-nanmean(calcorners(1,:,2))));

% % % xPos1 = data(4,1)-round(0.01*ScrRes(1)); % transform slightly because this sensor is a bit different (maybe because of the stick used in the whac-a-mole experiment)
% % % yPos1 = data(5,1)+round(0.03*ScrRes(2));
% % % zPos1 = data(3,1);
xPos(3,:) = data(4,:);
yPos(3,:) = data(5,:);
zPos(3,:) = data(3,:);
xPos(4,:) = data(4,:)-round(0.01*ScrRes(1)); % transform slightly because this sensor is a bit different (maybe because of the stick used in the whac-a-mole experiment)
yPos(4,:) = data(5,:)+round(0.03*ScrRes(2));
zPos(4,:) = data(3,:);

xPosOut1 = xPos(3,1);
xPosOut2 = xPos(3,2);
yPosOut1 = yPos(3,1);
yPosOut2 = yPos(3,2);
zPosOut1 = zPos(3,1);
zPosOut2 = zPos(3,2);


% if ( size(data,2) > 1 )
%     xPos2 = data(4,2)-round(0.01*ScrRes(1));
%     yPos2 = data(5,2)+round(0.03*ScrRes(2)); 
%     zPos2 = data(3,2);
% else
%     xPos2 = [];
%     yPos2 = [];
%     zPos2 = [];
% end
% if ( size(data,2) > 2 )
%     xPos3 = data(4,3);
%     yPos3 = data(5,3);
%     zPos3 = data(3,3);
% else
%     xPos3 = [];
%     yPos3 = [];
%     zPos3 = [];
% end
% if ( size(data,2) > 3 )
%     xPos4 = data(4,4);
%     yPos4 = data(5,4);
%     zPos4 = data(3,4);
% else
%     xPos4 = [];
%     yPos4 = [];
%     zPos4 = [];
% end
