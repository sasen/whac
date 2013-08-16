function []= plotsection(tk,lo,hi,thisDelay)
% function []= plotsection(tk,lo,hi,thisDelay)
%    tk = a trial's tracker data (cell, 1x2 or 1x3, of [x;y] or [x;y;z] data)
%    lo = tracker index to start plotting (int)
%    hi = tracker index to stop plotting (int)
%    thisDelay = delay interval in seconds (float, min=0.001)

if nargin == 4
  DELAY = thisDelay;
else
  DELAY = 0.001;
  if nargin==0
    x1 = linspace(-pi*4, pi*4, 50);
    x2 = linspace(-pi*2, pi*6, 50);
    tk{1} = [ x1; cos(x1); cos(2*x1) ];
    tk{2} = [ x2; sin(x2); sin(3*x2) ];
  end
end

[d, L] = size(tk{1});

if nargin < 3
  lo=1;
  hi=L;
end

if d==2
  %birdsEye(x1,y1,x2,y2,del);
  birdsEye(tk{1}(1,lo:hi),tk{1}(2,lo:hi),tk{2}(1,lo:hi),tk{2}(2,lo:hi),DELAY);
elseif d==3
  %plotgame(x1,y1,z1,x2,y2,z2,del);
% doesn't work yet
%  plotgame(tk{1}(1,lo:hi),tk{1}(2,lo:hi),tk{1}(3,lo:hi),tk{2}(1,lo:hi),tk{2}(2,lo:hi),tk{2}(3,lo:hi),DELAY);
  birdsEye(tk{1}(1,lo:hi),tk{1}(2,lo:hi),tk{2}(1,lo:hi),tk{2}(2,lo:hi),DELAY);
end