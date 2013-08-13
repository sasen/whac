old = load('../../MATLAB/WAM-nongit/Results/NaberData/IG5/att_jcc_t1_e1.mat');
%new = load('Results/RunFullscreen/DeceptiveConfederate/907_cet/907_cet_t1_e1.mat');

% convert old expt to new. 
% obviously experiment length will still be different.

convDir = '../../WAM/RunFullscreen/NaberSubjVsSubj';
convDir = [convDir '/' old.ppname];

if ~exist(convDir)
  mkdir(convDir);   %% not checking that this worked. hope this isn't terrible.
end

%% create 3rd cell of TrackList for time
stamped{3} = find(isfinite(old.TrackList{1}(1,:)));
stamped{1} = old.TrackList{1}(:,stamped{3});
stamped{2} = old.TrackList{2}(:,stamped{3});

%% the other thing to do is to deal with the Z coordinate
stamped{1}(3,:) = stamped{1}(3,:) - 9;
stamped{2}(3,:) = stamped{2}(3,:) - 9;

   %% NOT FINISHED YET


%% save changes to the struct
old.TrackList = stamped;
convExpNum = ['1.0' num2str(old.ExpNum)];
old.ExpNum = convExpNum;

%% save converted file with other data
save([convDir '/' old.ppname '_t' num2str(old.TrlNum) '_e' convExpNum '.mat'],'-struct','old');

