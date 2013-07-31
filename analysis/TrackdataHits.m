function hitInd = TrackdataHits(xyz, t)
% TrackdataHits: Returns hit timepoints (in tracker indices) for
%    a whole trial, for one player.
% xyz = tracker data for a player (3 x #dataframes)
% t = tracker time, in 240ths of a second (1 x #dataframes)
% hitInd = sorted hit indices
%
% xyz=D{4}.TrackList{1};
% t=D{4}.TrackList{3};

%calculate the speed of motion
S=sqrt(diff(xyz(1,:)).^2+diff(xyz(2,:)).^2+diff(xyz(3,:)).^2)./diff(t);
nback=10;
multmxback=zeros(length(S),length(S));
for iback=1:nback
  multmxback(iback*length(S)+1:length(S)+1:end)=1;
end
hitpointsInd=find(xyz(3,2:end)<0.5 & S<1 & ~((xyz(3,2:end)<0.5 & S<1)*multmxback));
hitInd = sort(hitpointsInd);