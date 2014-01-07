%% get subject names
Ss = getPairsInDir('Results/RunDistractors');
SoloSs = getPairsInDir('Results/RunSplitgameSolo');
PairSs = getPairsInDir('Results/RunSplitgamePaired');
Ss = Ss{1}'; %% base player name strings

%% Figure out which player the subject is for each condition
for sNum = 1:length(Ss)
  sName = Ss(sNum);
  if strcmp(sName,'finaltest')  %% sasen's testing data
    continue;
  elseif strcmp(sName,'ko1')  %% need to handle subject's switching issues
    continue;
  end
  sName %% HEREHEREHERE

end    % for sNum

% playername = '337';
% competitorname = 'sasen';

% if ~exist('EPair','var')
%   s1 = '337'; s2 = 'sasen'; ExpNum = 3;
%   [EPair,~] = LoadExpt(s1,s2,ExpNum,'all');
%   for trl = 1:length(EPair)
%     [hOns,hMole,hXYZ,moleXY,diffX] = getHitInfo(EPair{trl});
%     for pl = 1:2
%       hitOnsets{trl,pl} = hOns{pl};
%       hitMoles{trl,pl} = hMole{pl};
%       hitXYZs{trl,pl} = hXYZ{pl};
%       moleXYs{trl,pl} = moleXY{pl};
%       hitXErr{trl,pl} = diffX{pl};
%     end
%   end
% end  %% accumulate EPair

% if ~exist('ESolo','var')
%   [ESolo,~] = LoadExpt(s1,'null',3,'all');
%   for trl = 1:length(ESolo)
%     [hOns,hMole,hXYZ,moleXY,diffX] = getHitInfo(ESolo{trl});
%     hitOnsets{trl,3} = hOns{1};
%     hitMoles{trl,3} = hMole{1};
%     hitXYZs{trl,3} = hXYZ{1};
%     moleXYs{trl,3} = moleXY{1};
%     hitXErr{trl,3} = diffX{1};
%   end
% end  %% accumulate ESolo

% if ~exist('EDist','var')
%   [EDist,~] = LoadExpt(s1,'null',4,'all');
%   for trl = 1:length(EDist)
%     [hOns,hMole,hXYZ,moleXY,diffX] = getHitInfo(EDist{trl});
%     hitOnsets{trl,4} = hOns{1};
%     hitMoles{trl,4} = hMole{1};
%     hitXYZs{trl,4} = hXYZ{1};
%     moleXYs{trl,4} = moleXY{1};
%     hitXErr{trl,4} = diffX{1};
%   end
% end  %% accumulate EDist
% %%-------- Done Loading & Accumulating Conditions
% %% Analyze & Plot
% clear counts summary  %% refresh these variables

% edges = [-inf,linspace(-80,80,41),inf];
% figure();
% players = [1 2 1 1];
% side1 = [10:15];
% side2 = [4:9 16:21];
% subplotLookup = [1 0 2; 3 0 4];  %% row = sens, col = gameCond, val = plotnum
% for gameCond=[4 1 3]
%   if gameCond==2
%     blocks = {side2; side1};
%   else
%     blocks = {side1; side2};
%   end
%   for sens=1:2  % sensor 1 ~ near computer // 2 ~ near door
%     xErrs = [hitXErr{blocks{sens},gameCond}];  % big array of all xerrs at sens in gameCond
%     counts(:,gameCond,sens) = histc(xErrs, edges);
%     summary(:,gameCond,sens) = [mean(xErrs) std(xErrs)]';

%     %% Put histogram in the right subplot
%     if gameCond == 4 %% copy distractor-free hist upside down to all other conds
%       for sp_num = nonzeros(subplotLookup(sens,:))'
% 	subplot(2,2,sp_num);
% 	bhandle = bar([-100 edges(2:end-1) 100],-counts(:,4,sens),'histc');
% 	set(bhandle, 'FaceColor', 'r');
%       end
%     else
%       plotnum = subplotLookup(sens,gameCond);
%       subplot(2,2,plotnum), hold on;
%       bar([-100 edges(2:end-1) 100],counts(:,gameCond,sens),'histc');
%       plot(0,0,'y+','MarkerSize',15,'LineWidth',2);
%       axis tight;
%     end  % if gameCond

%   end  % for sens
% end  % for gameCond

% suptitle('Histograms of xError for all ')
% subplot(2,2,1),

% summary
% hitsPerCond = sum(counts)
