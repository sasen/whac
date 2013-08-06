function [valDevX,len,maxI] = PathDeviation(Xs,Ys)
%PathDeviation, Find the deviation taken from a straight-line path to a target
%   Random reach begin and end points are chosen, as well as a point that
%   is between the start and finish for both X and Y. The slope is found,
%   and used to find the linear deviation. The closest point on the
%   straight-line path is found (IntX/Y). When used with multiple points,
%   the integral will be found through a Riemann sum.

% TrackList = fake(1);
% % tLo = 1/240; tHi=6/240;
% %%Convert Time bounds into TrackList index bounds
% iLo = find(TrackList{3} >= 240*tLo,1,'first');
% iHi = find(TrackList{3} <= 240*tHi,1,'last');
% Xs = TrackList{1}(1,iLo:iHi);
% Ys = TrackList{1}(2,iLo:iHi);

deltaX = Xs(end)-Xs(1);
deltaY = Ys(end)-Ys(1);
endpt = [deltaX; deltaY];
len = norm(endpt,2);
theta = asin(deltaX/len);
R = [cos(theta)   -sin(theta);  sin(theta)   cos(theta)];
Rotated = R*[Xs-Xs(1); Ys-Ys(1)];
vert = R*endpt;

Devs = abs(Rotated(1,:));
[valDevX,maxI] = max(Devs);

maxDevX = min(valDevX,Rotated(1,maxI));
maxDevY = Rotated(2,maxI);
perp = [0 maxDevX; maxDevY maxDevY];
unrot = R'*perp + [Xs(1) Xs(1); Ys(1) Ys(1)];

figure; hold on;
%subplot(1,2,1),plot([0; endpt(1)],[0; endpt(2)],'bo-');
subplot(1,2,1),plot([Xs(1) Xs(end)], [Ys(1) Ys(end)],'r.-');hold on;
subplot(1,2,1),plot(Xs,Ys,'b.-');
subplot(1,2,1),plot(unrot(1,:),unrot(2,:),'k-','LineWidth',2);
ylabel('\fontsize{14}Vertical Position (px)')
xlabel('\fontsize{14}Horizontal Position (px)')
title('\fontsize{16}Original Reach')
grid on; axis equal;
subplot(1,2,2),plot([0; vert(1)],[0; vert(2)],'ro-'); hold on;
subplot(1,2,2),plot(Rotated(1,:), Rotated(2,:),'b*--');
subplot(1,2,2),plot(perp(1,:),perp(2,:),'k-','LineWidth',2);
grid on; axis equal;
xlabel('\fontsize{14}Horizontal Position (px)')
title('\fontsize{16}Straightened Reach')