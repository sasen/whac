function TrackList = fake(n)
% fake: generate fake TrackList data
TrackList{1}(1,:) = [0.5 2 4 5 6];
TrackList{1}(3,:) = [0.1 0 0 0 0];
TrackList{3}      = [1 2 4 5 6];

switch n
  case 1
   TrackList{1}(2,:) = [0.5 1 2 4 8];
  case 2
   TrackList{1}(2,:) = [0.5 1 1.5 1.9 1.8275];
  case 3
   TrackList{1}(2,:) = [0.5 0.25 2 3 1];
end
