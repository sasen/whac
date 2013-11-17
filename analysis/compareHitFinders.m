g = LoadGame('finaltest','null',3,1);
s = min(g.t); e = max(g.t);

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
hitInd = sort(hitpointsInd);

% zaccv = diff(diff(xyzin(3,:)));
% [pkv,locv]=findpeaks(zaccv,'MINPEAKHEIGHT',0.019); %%HEREHERE find hiton and hitoff separately
zacc = 1000*diff(abs(diff(xyzin(3,:))));
[pk,loc]=findpeaks(-zacc,'MINPEAKHEIGHT',19);
locT = loc + 2;

figure(); 
subplot(4,1,1),plot(xyzin(3,:),'k.--'); hold on;
axis tight;
ylabel('z position')
for l=locT
  subplot(4,1,1),plot(l,xyzin(3,l),'b*','MarkerSize',15);
end
for h=hitInd
  subplot(4,1,1),plot(h,xyzin(3,h),'g.','MarkerSize',15);
end
ylim([0 3]);

subplot(4,1,2),plot(zacc,'c.-');  hold on;
axis tight;
ylabel('z accel')
for l=loc
  subplot(4,1,2),plot(l,zacc(l),'b*','MarkerSize',15);
end

subplot(4,1,3),plot(S,'r.-'); hold on;
axis tight;
for h=hitInd
  subplot(4,1,3),plot(h,S(h),'g.','MarkerSize',15);
end

binarize