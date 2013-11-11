g = LoadGame('finaltest','null',3,1);
% s = min(g.t); e = max(g.t);
s = 1820;
e = 2290;

t = [s:e];
xyz =  [g.p1x(t); g.p1y(t); g.p1z(t)];
xyzin = inv(g.in2px(1:3,1:3)) * xyz;  %% convert to inches
sumdin = sum(abs(diff(xyzin')'));
dinv = 1./abs(diff(xyzin')');
suminv = sum(1./abs(diff(xyzin')'));

S = sqrt(sum(diff(xyz').^2,2))'; %% xy in pix, z in inch, cartesian
sumsqin = sqrt(sum(diff(xyzin').^2,2))'; %% xyz in inch, cartesian

lenS = length(S);
nback=10;
multmxback = spdiags(ones(lenS,nback),1:nback,lenS,lenS);  % sparse accumulator
hitpointsInd=find(xyz(3,2:end)<0.5 & S<1 & ~((xyz(3,2:end)<0.5 & S<1)*multmxback));
hitInd = sort(hitpointsInd) + s

zacc = diff(diff(xyzin(3,:)));
[pk,loc]=findpeaks(zacc,'MINPEAKHEIGHT',0.01); %%HEREHERE find hiton and hitoff separately
%% hit on should have minheight & threshold (above neighbors) probabaly.
loc = loc + s

figure(); 
subplot(3,1,1),plot(t(2:end),sumdin,'c.-'); hold on;
subplot(3,1,1),plot(t(2:end), S/30, 'm.-');
subplot(3,1,1),plot(t(2:end), sumsqin, 'g.-');
subplot(3,1,1),plot(t(2:end),xyzin(3,2:end)/2,'r.--')
axis([s e 0 0.45]);
legend('sumdin','S/30','sumsqin','z/2');

subplot(3,1,2),plot(t(3:end),zacc,'r.-');
axis tight;
ylabel('z accel')
subplot(3,1,3),plot(t(2:end),suminv,'k.-');
axis([s e 0 2000]);
ylabel('sum of inverse-speed')