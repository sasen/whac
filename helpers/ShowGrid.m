function win = ShowGrid(ScrRes)
% Show a calibration grid
% ScrRes = screen resolution
[win,wrect]=Screen('OpenWindow',0, [0 0 0 0], [0 0 ScrRes]);

hEnds = [0:32:ScrRes(1)];
vEnds = [0:32:ScrRes(2)];
h = meshgrid(hEnds,vEnds);
v = meshgrid(vEnds,hEnds)';
rectList = CenterSq(h,v,4);
Screen('FrameOval',win,[255 255 255],rectList);

%% Half and Quarter Lines
red = [255;0;0]; blu = [0;0;225];
x=ScrRes(1); x12 = ScrRes(1)/2; x14=ScrRes(1)/4; x34=x-x14;
y=ScrRes(2); y12 = ScrRes(2)/2; y14=ScrRes(2)/4; y34=y-y14;
xs = [  0   x x12 x12   0   x   0   x x14 x14 x34 x34];
ys = [y12 y12   0   y y14 y14 y34 y34   0   y   0   y];
cs = [red red red red blu blu blu blu blu blu blu blu];
Screen('DrawLines',win,[xs;ys],[],cs);

Screen('Flip',win,[],1);