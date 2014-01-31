sInfo = generateSubjInfo;

%% Ensure existence of directory for saving figures
pwdname = pwd;
assert(strcmp(pwdname(end-7:end),'analysis'),'%s: Run in whac/analysis/, not\n%s.',mfilename,pwdname);
figdirname = 'saved_figures';
mkdir(figdirname);  % harmless if it exists already.

graphname = '_xHitErrHist';  % Affects subdirectory & file names
subdirname = [datestr(now,'yyyy-mm-dd_HHMM') graphname];
mkdir(figdirname, subdirname);
figext = '.fig';


for sNum = 1:length(generateSubjInfo)
  subj = sInfo(sNum)
  subjfilename = fullfile(pwdname,figdirname,subdirname,[subj.name graphname figext]);

  [hitXErrs{sNum}, stats{sNum}, hitCounts{sNum}] = analyze_xHitErr(subj);
  saveas(gcf, subjfilename, 'fig');
end

save('xErr_summary.mat','-mat');