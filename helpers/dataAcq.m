function effHz = dataAcq(loaded)
%dataAcq  Tracker data acquisition analytics.
%    matfilename: loaded whac-a-mole results .mat file
%    effHz: effective recording frequency
trackedHz =  size(loaded.TrackList{1},2)/loaded.TrialLength;
goodT = find(isfinite(loaded.TrackList{1}(1,:)));
gooddiff = diff(goodT);

dt = 1/trackedHz;
effHz = 1/(mean(gooddiff)*dt);

figure;
plot(goodT,[0 gooddiff],'r*')
title([loaded.ppname ' recorded at ' num2str(effHz) 'Hz'])
end