g = LoadGame('de3','789',1,21);

%px2in = inv(g.in2px(1:3,1:3));
t = [min(g.t):max(g.t)];
xyz1 =  [g.p1x(t); g.p1y(t); g.p1z(t)];
xyz2 =  [g.p2x(t); g.p2y(t); g.p2z(t)];

xyz1 = diag(1./range(xyz1')) * xyz1;

d1 = abs(diff(xyz1')');
%d2 = diff(xyz2')';

figure(); hold on;
plot(t(2:end),d1);
legend('x','y','z');
axis tight
