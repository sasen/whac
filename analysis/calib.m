% calib.m: intended for calibration analysis, especially in the z-direction.
% load some results file with a 3-element TrackList{}

t = TrackList{3}(isfinite(TrackList{3}));
x1 = TrackList{1}(1,:);
x1 = x1(isfinite(x1));
y1 = TrackList{1}(2,:);
y1 = y1(isfinite(y1));
z1 = TrackList{1}(3,:);
z1 = z1(isfinite(z1));

x2 = TrackList{2}(1,:);
x2 = x2(isfinite(x2));
y2 = TrackList{2}(2,:);
y2 = y2(isfinite(y2));
z2 = TrackList{2}(3,:);
z2 = z2(isfinite(z2));

figure(); hold on; grid on;
color_line(x1,y1,z1,'o');
color_line(x2,y2,z2,'x');
