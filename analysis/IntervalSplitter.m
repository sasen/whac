function [ reachIntervals ] = IntervalSplitter(lo, hi, mole, xyz,t)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

mIdx = find((mole(2,:) >= lo) & (mole(2,:) <= hi));  % select moles in bounds
mHit = mole(7,mIdx);
mHit = sort(mHit(mHit>0));

reachIntervals = [];
for m=1:length(mHit)-1
    if mHit(m)
        reachIntervals = [reachIntervals; mHit(m) mHit(m+1)];
    end 
end

end