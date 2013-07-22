function [x, y, z] = TransformSensorData(sdata,T_SB,in2px)
% [xS yS zS 1]' = in2px * T_SB*[xB yB zB 1]';

PinB = [sdata(4); sdata(5); sdata(3); 1]
PpxS = in2px * T_SB * PinB;
x = PpxS(1);
y = PpxS(2);
z = PpxS(3);
