function VersionConvert(oldExp)
% Convert old expt to new. Obviously experiment length will still be different.
% function VersionConvert(oldExp)
% oldExp (int) = old experiment number in {1,2,3}

%% which expt we're converting
switch oldExp
  case 1
   oldDirname = '../../MATLAB/WAM-nongit/Results/NaberData/IG5';
   convDirname = '../../WAM/RunFullscreen/NaberSubjVsSubj';
  case 2
   convDirname = '../../WAM/RunFullscreen/NaberConfed';
  case 3
   convDirname = '../../WAM/RunFullscreen/NaberComputer';
  otherwise
   disp([mfilename ': Unknown experiment number ' num2str(oldExp) '.']);
end

%% get all matfiles
oDir = what(oldDirname);
gamefiles = oDir.mat;  % cell of matfile names
disp(['Converting expt ' num2str(oldExp) '; ' num2str(length(gamefiles)) ' files found.']);

for gg=1:length(gamefiles)
  fname = gamefiles(gg);
  old = load([oldDirname '/' cell2mat(fname)]);
  convPath = [convDirname '/' old.ppname];

  if ~exist(convPath)
    mkdir(convPath);   %% not checking that this worked. hope this isn't terrible.
  end

  %% create 3rd cell of TrackList for time
  stamped{3} = find(isfinite(old.TrackList{1}(1,:)));
  stamped{1} = old.TrackList{1}(:,stamped{3});
  stamped{2} = old.TrackList{2}(:,stamped{3});
  
  %% rename variables: ppname1 -> pname1
  old.pname1 = old.ppname1;
  old.pname2 = old.ppname2;
  
  %% the other thing to do is to deal with the Z coordinate
  %%%%%%%%%% NOT SURE IF THIS IS GOOD ENOUGH
  stamped{1}(3,:) = stamped{1}(3,:) - 9;
  stamped{2}(3,:) = stamped{2}(3,:) - 9;
  old.TrackList = stamped;
  
  %% convert experiment number. (old) N --> (new) 1.0N
  convExpNum = ['1.0' num2str(old.ExpNum)];
  old.ExpNum = str2double(convExpNum);
  
  save([convPath '/' old.ppname '_t' num2str(old.TrlNum) '_e' convExpNum '.mat'],'-struct','old');
end