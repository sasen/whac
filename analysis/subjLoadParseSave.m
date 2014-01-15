function [] = subjLoadParseSave(subj)
%function [] = subjLoadParseSave(subj)
% Load all conditions for a subject, decipher hits,
%     and save to MAT-files. (Splitgame studies)
% Input: subj (struct) of a single subject, from generateSubjInfo
% Output: Two files in ./saved_data/
%  (1) subj.name + '_data.mat': EPair, ESolo, EDist (cell of gamefile structs)
%  (2) subj.name + '_parsed.mat': Outputs of getHitInfo.m (cell arrays)
%      Rows: TrlNum
%      Columns: { Subj (Pair), Opponent (Pair), Solo, Dist }


%% Ensure existence of directory for saving our work
pwdname = pwd;
assert(strcmp(pwdname(end-7:end),'analysis'),'%s: Run in whac/analysis/, not\n%s.',mfilename,pwdname);
matdirname = 'saved_data';
mkdir(matdirname);  % harmless if it exists already.

%% Load existing data
subjfilename = fullfile(pwdname,matdirname,[subj.name '_data.mat']);
loadfilemodded = 0;   % flag for whether we need to save this data afterward

if exist(subjfilename,'file')
  load(subjfilename,'-mat');
end

if ~exist('EPair','var')
  loadfilemodded = 1;
  disp(['Loading pair condition for ',subj.name]);
  opp_pnum = ~(subj.pair_pnum-1)+1;  %% opponent's player number
  switch subj.pair_pnum
   case 1
    [EPair,~] = LoadExpt(subj.name,subj.opponent,3,'all');
   case 2
    [EPair,~] = LoadExpt(subj.opponent,subj.name,3,'all');
  end
end

if ~exist('ESolo','var')
  loadfilemodded = 1;
  disp(['Loading solo condition for ',subj.name]);
  switch subj.solo_pnum
   case 1
    [ESolo,~] = LoadExpt(subj.name,'null',3,'all');
   case 2
    [ESolo,~] = LoadExpt('null',subj.name,3,'all');
  end
end

if ~exist('EDist','var')
  loadfilemodded = 1;
  disp(['Loading dist condition for ',subj.name]);
  [EDist,~] = LoadExpt(subj.name,'null',4,'all');
end

if loadfilemodded
  disp(['Saving ' subjfilename]);
  save(subjfilename,'subj','opp_pnum','trl','E*','-mat');
end


%%------- Get Hit Info for each Condition

disp(['Getting pair hit info for ',subj.name]);
for trl = 1:length(EPair)
  [hOns,hMole,hXYZ,moleXY,diffX] = getHitInfo(EPair{trl});
  %-- Column 1 is for the subject's paired condition
  hitOnsets{trl,1} = hOns{subj.pair_pnum};
  hitMoles{trl,1} = hMole{subj.pair_pnum};
  hitXYZs{trl,1} = hXYZ{subj.pair_pnum};
  moleXYs{trl,1} = moleXY{subj.pair_pnum};
  hitXErr{trl,1} = diffX{subj.pair_pnum};
  %-- Column 2 is for the opponent in paired
  hitOnsets{trl,2} = hOns{opp_pnum};
  hitMoles{trl,2} = hMole{opp_pnum};
  hitXYZs{trl,2} = hXYZ{opp_pnum};
  moleXYs{trl,2} = moleXY{opp_pnum};
  hitXErr{trl,2} = diffX{opp_pnum};
end

disp(['Getting solo hit info for ',subj.name]);
for trl = 1:length(ESolo)
  [hOns,hMole,hXYZ,moleXY,diffX] = getHitInfo(ESolo{trl});
  %-- Column 3 is for Solo Split Condition
  hitOnsets{trl,3} = hOns{subj.solo_pnum};
  hitMoles{trl,3} = hMole{subj.solo_pnum};
  hitXYZs{trl,3} = hXYZ{subj.solo_pnum};
  moleXYs{trl,3} = moleXY{subj.solo_pnum};
  hitXErr{trl,3} = diffX{subj.solo_pnum};
end

disp(['Getting dist hit info for ',subj.name]);
for trl = 1:length(EDist)
  [hOns,hMole,hXYZ,moleXY,diffX] = getHitInfo(EDist{trl});
  %-- Column 4 is for Baseline condition
  hitOnsets{trl,4} = hOns{1};
  hitMoles{trl,4} = hMole{1};
  hitXYZs{trl,4} = hXYZ{1};
  moleXYs{trl,4} = moleXY{1};
  hitXErr{trl,4} = diffX{1};
end

%% Save hit info
parsfilename = fullfile(pwdname,matdirname,[subj.name '_parsed.mat']);
save(parsfilename,'subj','opp_pnum','trl','h*','mole*','-mat');

