g = LoadGame('finaltest','null',3,1);

%px2in = inv(g.in2px(1:3,1:3));
t = [min(g.t):max(g.t)];
xyz =  [g.p1x(t); g.p1y(t); g.p1z(t)];

xyzin = inv(g.in2px(1:3,1:3)) * xyz;
sumdin = sum(abs(diff(xyzin')'));
dinv = 1./abs(diff(xyzin')');
suminv = sum(1./abs(diff(xyzin')'));


% % normalized velocity
% xyznorm = diag(1./range(xyz')) * xyz;
% sumdnorm = sum(abs(diff(xyznorm')'));

S = sqrt(sum(diff(xyz').^2,2))';
sumsqin = sqrt(sum(diff(xyzin').^2,2))';

lenS = length(S);
nback=10;
multmxback = spdiags(ones(lenS,nback),1:nback,lenS,lenS);  % sparse accumulator
hitpointsInd=find(xyz(3,2:end)<0.5 & S<1 & ~((xyz(3,2:end)<0.5 & S<1)*multmxback));
hitInd = sort(hitpointsInd)

figure(); hold on;
plot(t(2:end),sumdin,'c.-')
plot(t(2:end), S/30, 'm.-');
plot(t(2:end), sumsqin, 'r.-');
legend('sumdin','S','sumsqin');
axis([1920 2190 0 0.45]);
plot(t(2:end),xyzin(3,2:end)/2,'b.--')

figure()
plot(t(2:end),suminv,'k.-')
