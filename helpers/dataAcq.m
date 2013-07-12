function effHz = dataAcq(loaded)
%dataAcq  Tracker data acquisition analytics.
%  effHz = dataAcq(loaded)
%    loaded: loaded whac-a-mole results .mat file
%    effHz: effective recording frequency
%trackedHz =  min(240, size(loaded.TrackList{1},2)/loaded.TrialLength);
%trackedHz =  min(240, loaded.RecordHz);
dt = 1/240; %1/trackedHz;

p1track = loaded.TrackList{1};
[dims, maxT] = size(p1track);

if ( length(loaded.TrackList)==3 ) % [p1 p2 t]
    tElapsed = loaded.TrackList{3};
    gooddiff = diff(tElapsed(isfinite(tElapsed)));
    goodT = [0:length(gooddiff)];
elseif (dims==4)   % [x y z t]
    tElapsed = p1track(4,:);
    gooddiff = diff(tElapsed(isfinite(tElapsed)));
    goodT = [0:length(gooddiff)];
elseif (dims == 3)   % [x y z]
    goodT = find(isfinite(p1track(1,:)));
    gooddiff = diff(goodT);
end

effHz =1/(mean(gooddiff)*dt);
figure; plot(goodT,[0 gooddiff],'r.');
title([loaded.ppname ' recorded at ' num2str(effHz) 'Hz'])
