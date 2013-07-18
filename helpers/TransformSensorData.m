function [x, y, z] = TransformSensorData(sdata,calcorners,ScrRes,fitval)
sdata(5) = sdata(5)+(-1*fitval(1,1)*sdata(4));
calcorners(:,:,2) = calcorners(:,:,2)+(-1*fitval(1,1)*calcorners(:,:,1));

sdata(4) = sdata(4)+(-1*fitval(2,1)*sdata(5));
calcorners(:,:,1) = calcorners(:,:,1)+(-1*fitval(2,1)*calcorners(:,:,2));

sdata(4) = ScrRes(1)*((sdata(4)-nanmean(calcorners(:,1,1)))/(nanmean(calcorners(:,3,1))-nanmean(calcorners(:,1,1))));
sdata(5) = ScrRes(2)*((sdata(5)-nanmean(calcorners(1,:,2)))/(nanmean(calcorners(3,:,2))-nanmean(calcorners(1,:,2))));

z = sdata(3);
x = sdata(4);
y = sdata(5);