function [trackInts,moleInts ] = IntervalSplitter(xyz,t,mole)
% function [ reachIntervals ] = IntervalSplitter(lo, hi, mole, xyz,t)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

lo=0;hi=30;
%mole=Db{1,4};
% xyz=D{4}.TrackList{1};
% t=D{4}.TrackList{3};

mIdx = find((mole(2,:) >= lo) & (mole(2,:) <= hi));  % select moles in bounds
mHit = mole(7,mIdx);
mHit = sort(mHit(mHit>0));

%calculate the speed of motion
S=sqrt(diff(xyz(1,:)).^2+diff(xyz(2,:)).^2+diff(xyz(3,:)).^2)./diff(t);
nback=10;
multmxback=zeros(length(S),length(S));
for iback=1:nback
  multmxback(iback*length(S)+1:length(S)+1:end)=1;
end
hitpointsInd=find(xyz(3,2:end)<0.5 & S<1 & ~((xyz(3,2:end)<0.5 & S<1)*multmxback));
%allHits = t(hitpointsInd);  
hitInd = sort(hitpointsInd);

%% mHits is the mole hits times (with zeros)! need to incorporate
%% hitInd is tracker indices of hits, based on z & velocity (maryam)

trackInts = [];
for m=1:length(hitInd)-1
  trackInts = [trackInts; hitInd(m) hitInd(m+1)];
end

moleInts = [];
for m=1:length(mHit)-1
  if mHit(m)
    moleInts = [moleInts; mHit(m) mHit(m+1)];
  end 
end

end
% 
% 
% 
% 
% for k=1:length(mHit)
%     hInd(k) = (find(abs(t-mHit(k)*240)<1,1,'first'));
% end
% 
% plot(t/240,xyz(3,:),'k.-'); hold on;
% plot(t(hInd)/240,xyz(3,hInd),'r*','MarkerSize',10)  % molehit
% plot(allHits/240,xyz(3,hitpointsInd),'b*','MarkerSize',10); % z-based
% 
% 
%     for m=mIdx
%         mOn = mole(2,m);
%         if mole(7,m)
%             mOff=mole(7,m);
%         else
%             mOff=mOn+1.25;
%         end
%         type = mole(3,m);
%         plot([mOn;mOff], [type;type]/20, 'LineWidth',2, 'Color',clr(type,:));
%         switch mole(6,m)
%             case 1
%                 plot(mole(7,m),type/20,'k^','MarkerSize',10);
%             case 2
%                 plot(mole(7,m),type/20,'kv','MarkerSize',10);     
%         end
%     end