k=g39;

in2px=k.in2px(1:3,1:3);
xyz1 = k.TrackList{1};
xyz2 = k.TrackList{2};
t = k.TrackList{3};
[vel1,grad1] = inchVel(xyz1,t,in2px);
[vel2,grad2] = inchVel(xyz2,t,in2px);

z1 = k.TrackList{1}(3,:);
z2 = k.TrackList{2}(3,:);
zprime1 = vel1(3,:);
zprime2 = vel2(3,:);

%plotccor(z1,z2,'z position')
plotccor(zprime1,zprime2,'z velocity')
%plotccor(abs(zprime1),abs(zprime2),'z speed')
%plotccor(diff(zprime1),diff(zprime2),'z acceleration')
%plotccor(diff(abs(zprime1)),diff(abs(zprime2)),'|z| accel')
title([k.pname1 ' vs ' k.pname2 ' trial ' num2str(k.TrlNum)])