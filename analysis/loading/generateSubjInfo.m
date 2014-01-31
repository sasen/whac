function subjInfo = generateSubjInfo()
% function subjInfo = generateSubjInfo()
% Create a struct array of [splitgame] subject info for analysis
% Inputs: [none]
% Outputs: subjInfo (struct array, length = # subjects )
% -- .name (str) subject's name
% -- .opponent (str) opponent's name in pair condition
% -- .solo_pnum (1 or 2) player # in solo condition
% -- .pair_pnum (1 or 2) player # in pair condition
% Hardcoded: 
%  -- NAMES OF SUBJECTS TO SKIP
%  -- LOCATION OF RESULTS DIRECTORIES

%% Get subject names from each condition
Ss = getPairsInDir('Results/RunDistractors');
Ss = Ss{1}';  %% Base player name: Always p1 in this condition
SoloSs = getPairsInDir('Results/RunSplitgameSolo');
PairSs = getPairsInDir('Results/RunSplitgamePaired');


subjInfo = struct([]);
for sNum = 1:length(Ss)
  sName = char(Ss(sNum));

  %% Skip these subjects
  %% -- Add more subjects to skip here.
  %% -- Please provide the reason in a comment!
  switch sName
   case {'finaltest', ... % sasen's testing data
	 'ko1',       ... % need to handle switching/restart
	 'ndn'        ... % need to handle switching failure
	}
    continue;
  end
  
  %% Find subject's player number for each condition
  soloPnum = NaN; pairPnum = NaN; opponentName='';
  [~, soloPnum] = find(strcmp(sName,[SoloSs{1}' SoloSs{2}']));
  [pairNum, pairPnum] = find(strcmp(sName,[PairSs{1}' PairSs{2}']));
  opponentName = PairSs{~(pairPnum-1)+1}(pairNum);

  %% Error-check 
  assert(numel(soloPnum)==1,'%s: Found %d solo condition matches for subject %s.',mfilename,numel(soloPnum),sName);
  assert(numel(pairPnum)==1,'%s: Found %d pair condition matches for subject %s.',mfilename,numel(pairPnum),sName);
  assert(ismember(soloPnum,[1 2]),'%s: improper solo player # for subject %s.',mfilename,sName);
  assert(ismember(pairPnum,[1 2]),'%s: improper pair player # for subject %s.',mfilename,sName);

  %% Save in subject struct
  subjInfo(end+1).name = char(sName);
  subjInfo(end).opponent = char(opponentName);
  subjInfo(end).solo_pnum = soloPnum;
  subjInfo(end).pair_pnum = pairPnum;

end    % for sNum
