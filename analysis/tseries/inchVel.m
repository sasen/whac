function [vel,l2vel] = inchVel(xyz,t,in2px)
% function [vel,l2vel] = inchVel(xyz,t,in2px)
%  xyz=h.TrackList{1};
%  t=h.TrackList{3};
%  in2px=h.in2px(1:3,1:3);

dels = diff(t);
xyzin = inv(in2px) * xyz;

for dd=1:3
  vel(dd,:)=diff(xyzin(dd,:))./dels;
end

for ii = 1:length(dels)
  l2vel(ii) = norm(vel(:,ii));
end