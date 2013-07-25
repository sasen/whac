function [] = Performance(s1,s2,ExpNum)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if ExpNum==3
    gameType='RunSplitgame';
elseif ExpNum==4
    gameType='RunDistractors';
end

for t=1:21
    load(['/Users/eshayer/whac-a-mole/whac/analysis/Results/' gameType '/' s1 '_' s2 '/' s1 '_' s2 '_t' num2str(t) '_e' num2str(ExpNum) '.mat']);
    xPos
end

end