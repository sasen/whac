function [hitXErr, summary, hitsPerCond] = analyze_xHitErr(subj)
%function [hitXErr, summary, hitsPerCond] = analyze_xHitErr(subj)
% Tally/Plot subj's hists of hit xError over all games, by condition
% Input: 
%   subj (struct) of a single subject, from generateSubjInfo
%   The file saved_data/{subj.name}_parsed.mat must exist.
% Output:
%   hitXErr (NumTrl x 4 cell) 
%   summary (2x4 array): mean & std of hitXErr, by condition & sensor
%   hitsPerCond (2x4 array): number of hits per condition & sensor

pwdname = pwd;
assert(strcmp(pwdname(end-7:end),'analysis'),'%s: Run in whac/analysis/, not\n%s.',mfilename,pwdname);
matdirname = 'saved_data';

%% Load existing computations
parsfilename = fullfile(pwdname,matdirname,[subj.name '_parsed.mat']);
if exist(parsfilename,'file')
  load(parsfilename,'-mat');
  subj
  hitXErr
else
  error('%s: Parsed trajectory file %s does not exist.\n',mfilename,parsfilename);
end

%% Analyze & Plot
clear counts summary  %% refresh these variables

edges = [-inf,linspace(-80,80,41),inf];
figure();
side1 = [10:15];  %% side1 doesn't really mean sensor1
side2 = [4:9 16:21];
subplotLookup = [1 0 2; 3 0 4];  %% row = sens, col = gameCond, val = plotnum
for gameCond=[4 1 3]
  if gameCond==2  %% this is a lie; assumes subj is p1
    blocks = {side2; side1};
  else
    blocks = {side1; side2};
  end
  for sens=1:2  % sensor 1 ~ first sensor they used // 2 ~ second sensor
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

hitsPerCond = sum(counts)
