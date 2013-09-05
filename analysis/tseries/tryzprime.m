in2px=z.in2px(1:3,1:3);
[vel1,grad1] = inchVel(k.TrackList{1},k.TrackList{3},in2px);
[vel2,grad2] = inchVel(k.TrackList{2},k.TrackList{3},in2px);

zprime1 = vel1(3,:);
zprime2 = vel2(3,:);

plotccor(zprime1,zprime2,'z velocity')
%plotccor(abs(zprime1),abs(zprime2),'z speed')
%plotccor(diff(zprime1),diff(zprime2),'z acceleration')
%plotccor(diff(abs(zprime1)),diff(abs(zprime2)),'|z| accel')
title('jkc vs sasen trial 19')