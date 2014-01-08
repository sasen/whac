function [] = analyze_xHitErr(subj)
% function [] = analyze_xHitErr(subj)
% Tally/Plot subj's hists of hit xError over all games, by condition
% Input: subj (struct) of a single subject, from generateSubjInfo
% Should probably make accumulating the hit info for each subject a separate thing
% Failed on 723 solo hit info

opp_pnum = ~(subj.pair_pnum-1)+1;  %% opponent's player number
if ~exist('EPair','var')
  switch subj.pair_pnum
   case 1
    [EPair,~] = LoadExpt(subj.name,subj.opponent,3,'all');
   case 2
    [EPair,~] = LoadExpt(subj.opponent,subj.name,3,'all');
  end
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
end  %% accumulate EPair

if ~exist('ESolo','var')
  switch subj.solo_pnum
   case 1
    [ESolo,~] = LoadExpt(subj.name,'null',3,'all');
   case 2
    [ESolo,~] = LoadExpt('null',subj.name,3,'all');
  end
  for trl = 1:length(ESolo)
    [hOns,hMole,hXYZ,moleXY,diffX] = getHitInfo(ESolo{trl});
    %-- Column 3 is for Solo Split Condition
    hitOnsets{trl,3} = hOns{subj.solo_pnum};
    hitMoles{trl,3} = hMole{subj.solo_pnum};
    hitXYZs{trl,3} = hXYZ{subj.solo_pnum};
    moleXYs{trl,3} = moleXY{subj.solo_pnum};
    hitXErr{trl,3} = diffX{subj.solo_pnum};
  end
end  %% accumulate ESolo

if ~exist('EDist','var')
  [EDist,~] = LoadExpt(subj.name,'null',4,'all');
  for trl = 1:length(EDist)
    [hOns,hMole,hXYZ,moleXY,diffX] = getHitInfo(EDist{trl});
    %-- Column 4 is for Baseline condition
    hitOnsets{trl,4} = hOns{1};
    hitMoles{trl,4} = hMole{1};
    hitXYZs{trl,4} = hXYZ{1};
    moleXYs{trl,4} = moleXY{1};
    hitXErr{trl,4} = diffX{1};
  end
end  %% accumulate EDist
%%-------- Done Loading & Accumulating Conditions

%% Analyze & Plot
clear counts summary  %% refresh these variables

edges = [-inf,linspace(-80,80,41),inf];
figure();
players = [1 2 1 1];  %% HEREHEREHERE is this true???
side1 = [10:15];
side2 = [4:9 16:21];
subplotLookup = [1 0 2; 3 0 4];  %% row = sens, col = gameCond, val = plotnum
for gameCond=[4 1 3]
  if gameCond==2
    blocks = {side2; side1};
  else
    blocks = {side1; side2};
  end
  for sens=1:2  % sensor 1 ~ near computer // 2 ~ near door
    xErrs = [hitXErr{blocks{sens},gameCond}];  % big array of all xerrs at sens in gameCond
    counts(:,gameCond,sens) = histc(xErrs, edges);
    summary(:,gameCond,sens) = [mean(xErrs) std(xErrs)]';

    %% Put histogram in the right subplot
    if gameCond == 4 %% copy distractor-free hist upside down to all other conds
      for sp_num = nonzeros(subplotLookup(sens,:))'
	subplot(2,2,sp_num);
	bhandle = bar([-100 edges(2:end-1) 100],-counts(:,4,sens),'histc');
	set(bhandle, 'FaceColor', 'r');
      end
    else
      plotnum = subplotLookup(sens,gameCond);
      subplot(2,2,plotnum), hold on;
      bar([-100 edges(2:end-1) 100],counts(:,gameCond,sens),'histc');
      plot(0,0,'y+','MarkerSize',15,'LineWidth',2);
      axis tight;
    end  % if gameCond

  end  % for sens
end  % for gameCond


subplot(2,2,1)
title('Paired Condition (vs. Baseline)')
ylabel('First Sensor')
subplot(2,2,2), title('Solo Condition (vs. Baseline)')
subplot(2,2,3), ylabel('Second Sensor')

suptitle(['Hit xError Histograms for Subj. ' subj.name])

summary
hitsPerCond = sum(counts)
