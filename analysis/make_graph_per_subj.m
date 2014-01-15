sInfo = generateSubjInfo;

for sNum = 1:length(generateSubjInfo)
  subj = sInfo(sNum)
  subjLoadParseSave(subj);
  [hitXErrs{sNum}, stats{sNum}, hitCounts{sNum}] = analyze_xHitErr(subj);
end

save('xErr_summary.mat','-mat');