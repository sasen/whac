function [T_SB, in2px] = findrot(sensNum,playerID)
% FINDROT   Find 3D rotation matrix from Whac-a-mole Calibration
%    R = findrot(sensNum,playerID)
%    sensNum: sensor number (1 or 2)
%    playerID (string): matches the ID used for experiments
%    R = 3x3 rotation matrix 
% Loads two 9-point calibration xyz matrices (base & stick), computes 3D
% rotation using least-squares.

%playerID = 'all'; sensNum = 2;

%% PinS: Points in Surface Frame (inches)
% -- hand-measured from screen calibration dots. [0,0,0] is same as pixel [0 0].
PinS = [ 0     0      0
	 0     6.772  0
	 0     13.622 0
	 9.134 -0.118 0
	 9.134  6.654 0
	 9.134 13.583 0
	18.189 -0.236 0
	18.189  6.575 0
	18.189 13.504 0];
% -- add 2nd layer of points with stick height in inches
PinS = [PinS; PinS + [zeros(9,2) ones(9,1)*8.0625]]';   % now 3x18

%% PinB: Points in B-field Frame ("inches") -- untransformed tracker data
base = load(['calmats/' playerID '_sensor' num2str(sensNum) 'base'],'calcorners');
stick = load(['calmats/' playerID '_sensor' num2str(sensNum) 'stick'],'calcorners');
PinB = [reshape(base.calcorners,9,3) ; reshape(stick.calcorners,9,3)]';  % now 3x18
PinB_SO = PinB(:,1);  % vector in B frame to S frame Origin (inches)

for i=1:3
   B0(i,:) = PinB(i,:) - PinB_SO(i);
end

% %% find rotation matrix from frame B to frame S
% % -- least squares, equivalent to B0/PinS
% cvx_begin
%    variables R_BS(3,3);
%    minimize norm( R_BS*PinS - B0 , 2)
% cvx_end
R_BS = B0/PinS;

R_SB = inv(R_BS);  % ideally, this would be R_BS', but it's not a perfect rot matrix
T_BS = [R_BS PinB_SO; 0 0 0 1];
T_SB = [R_SB -R_SB*PinB_SO; 0 0 0 1];  % inv(T_BS)

in2px = diag([1024/18.189 768/13.622 1 1]);
%Sest = in2px * T_SB*[PinB; ones(1,18)];
