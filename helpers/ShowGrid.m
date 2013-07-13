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
Screen('Flip',win,[],1);