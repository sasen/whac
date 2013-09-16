close all
clear all

ShowFigs            = [];

% removed 'jh-kc' (11) and 'jz-jj' (10) and 'dr-ks' (25) because not enough trials
% what is up with cs/al --> they had really weird data because subject was drunk!!
% WHAT HAPPENED TO MR-SC --> one subject did not finish the questionnaire

% Subjects{1}         = {'mj','mt','os','dl','jw','ab','ff','db','mr','jp','jl','sc','fn','rr','bg','rl','br','jmj','ltt','rbb','hjh','kcw','nm','na','lvv','stt','yhh','att'}; % tk_aa and sb_mpl knew each other
% Subjects{2}         = {'cd','hs','bs','fb','ka','va','bp','jo','sc','jt','lm','pc','kb','lw','ra','td','dw','slj','aas','scc','amm','cg','ec','emm','ell','akk','jgg','jcc'};
Subjects{1}         = {'35','94s','233','eli','jkc','m7r'};
Subjects{2}         = {'sasen','eli','ss5','3u1','sasen','ss'};
maxTrialNums        = 39*ones(1,length(Subjects{1}));
SwitchedCondition   = [0 0 0 ones(1,6) zeros(1,6) ones(1,6) zeros(1,6) ones(1,6) zeros(1,6)];

screenSize = [35 46];  %%% SS: need to fix? (in cm)

CreateHitMaps = 0; % 0 is no hitmaps, 1 is hitmaps aligned to screen, 2 = hitmaps aligned to tracker (hand)
CreateData = 1;
if ( CreateData )
    CreateAllData;
else
    load('AllData.mat');
end

%% adjust score to remove effects of distractor targets (blue/purple)

for s = 1:length(Subjects{1})
    for t = 1:30
        Scores(:,t,s) = Scores(:,t,s)-nansum([1*(TargetType(t,:,1,s)==5) 1*(TargetType(t,:,2,s)==5)]);
        Scores(:,t,s) = Scores(:,t,s)+nansum([1*(TargetType(t,:,1,s)==6) 1*(TargetType(t,:,2,s)==6)]);
    end
end

%% convert pixels to centimeters

HitDist = (HitDist/768)*screenSize(1);
HitWidth = (HitWidth/1024)*screenSize(2);
HitHeight = HitHeight*zPixel;

%% Pool data

firstSubs   = 1:2:2*length(Subjects{1});
secondSubs  = 2:2:2*length(Subjects{1});

DataMatrixPerPlayer = NaN(28,2*length(Subjects{1}));
DataMatrixPerPlayer(1:8,firstSubs) = Questionnaire(:,:,1);
DataMatrixPerPlayer(1:8,secondSubs) = Questionnaire(:,:,2);

DataMatrixPerPlayerPerTrial = NaN(30,2*length(Subjects{1}),16);

DataMatrixPerPlayerVars         = {'Gender','Height','Age','Empathy','Esteem','Attraction','Risk','Dominance','Score Sum','Score Std','nHit reward','nHit punish','nHits','nMiss','Decision RT','Motor RT','Decision Distance','Decision Speed','Vert. Dist.','Hori. Dist.','V. Dist. Std','H. Dist. Std','Motor distance','Motor speed','RT','Distance','Speed','RT miss','RT hit+miss','nWon','Mimicry'};

DataMatrixPerPlayer(9,firstSubs)    = sum(squeeze(Scores(1,:,:)));
DataMatrixPerPlayer(9,secondSubs)   = sum(squeeze(Scores(2,:,:)));

DataMatrixPerPlayer(10,firstSubs)    = nanstd(squeeze(Scores(1,:,:)));
DataMatrixPerPlayer(10,secondSubs)   = nanstd(squeeze(Scores(2,:,:)));

for s = 1:length(Subjects{1})
    DataMatrixPerPlayer(11,firstSubs(s))   = nansum(nansum(1*(squeeze(TargetType(:,:,1,s))'==1)));
    DataMatrixPerPlayer(11,secondSubs(s))  = nansum(nansum(1*(squeeze(TargetType(:,:,2,s))'==1)));
    DataMatrixPerPlayer(12,firstSubs(s))   = nansum(nansum(1*(squeeze(TargetType(:,:,1,s))'==2)));
    DataMatrixPerPlayer(12,secondSubs(s))  = nansum(nansum(1*(squeeze(TargetType(:,:,2,s))'==2)));
    DataMatrixPerPlayer(13,firstSubs(s))   = nansum(nansum(1*(squeeze(TargetType(:,:,1,s))'==2|squeeze(TargetType(:,:,1,s))'==1)));
    DataMatrixPerPlayer(13,secondSubs(s))  = nansum(nansum(1*(squeeze(TargetType(:,:,2,s))'==2|squeeze(TargetType(:,:,2,s))'==1)));
    
    DataMatrixPerPlayer(14,firstSubs(s))   = nansum(nansum(1*isfinite(rtHitMiss(:,:,1,s))));
    DataMatrixPerPlayer(14,secondSubs(s))  = nansum(nansum(1*isfinite(rtHitMiss(:,:,2,s))));
    
    % median decision time
    tempData = DecisionTime(:,:,1,s);
    DataMatrixPerPlayer(15,firstSubs(s))   = nanmedian(tempData(:));
    tempData = DecisionTime(:,:,2,s);
    DataMatrixPerPlayer(15,secondSubs(s))  = nanmedian(tempData(:)); 
    
    % median movement time
    tempData = MoveTime(:,:,1,s);
    DataMatrixPerPlayer(16,firstSubs(s))   = nanmedian(tempData(:));
    tempData = MoveTime(:,:,2,s);
    DataMatrixPerPlayer(16,secondSubs(s))  = nanmedian(tempData(:)); 
    
    % movement distance during decision 
    tempData = (HitEucDistFromStart(:,:,1,s)-HitEucDistFromMoveOnset(:,:,1,s));
    DataMatrixPerPlayer(17,firstSubs(s))   = nanmedian(tempData(:));
    tempData = (HitEucDistFromStart(:,:,2,s)-HitEucDistFromMoveOnset(:,:,2,s));
    DataMatrixPerPlayer(17,secondSubs(s))  = nanmedian(tempData(:)); 
    
    % movement speed during decision (distance/time)
    tempData = (HitEucDistFromStart(:,:,1,s)-HitEucDistFromMoveOnset(:,:,1,s))./(DecisionTime(:,:,1,s));
    DataMatrixPerPlayer(18,firstSubs(s))   = nanmedian(tempData(:));
    tempData = (HitEucDistFromStart(:,:,2,s)-HitEucDistFromMoveOnset(:,:,2,s))./(DecisionTime(:,:,2,s));
    DataMatrixPerPlayer(18,secondSubs(s))  = nanmedian(tempData(:)); 
    
    % median vert. territory location
    tempData = HitDist(:,:,1,s);
    DataMatrixPerPlayer(19,firstSubs(s))   = nanmedian(tempData(:));
    tempData = HitDist(:,:,2,s);
    DataMatrixPerPlayer(19,secondSubs(s))  = nanmedian(tempData(:)); 
    
    % median hori. territory location
    tempData = HitWidth(:,:,1,s);
    DataMatrixPerPlayer(20,firstSubs(s))   = nanmedian(tempData(:));
    tempData = HitWidth(:,:,2,s);
    DataMatrixPerPlayer(20,secondSubs(s))  = nanmedian(tempData(:)); 
    
    % std vert. territory
    tempData = HitDist(:,:,1,s);
    DataMatrixPerPlayer(21,firstSubs(s))   = nanstd(tempData(:));
    tempData = HitDist(:,:,2,s);
    DataMatrixPerPlayer(21,secondSubs(s))  = nanstd(tempData(:)); 
    
    % std hori. territory
    tempData = HitWidth(:,:,1,s);
    DataMatrixPerPlayer(22,firstSubs(s))   = nanstd(tempData(:));
    tempData = HitWidth(:,:,2,s);
    DataMatrixPerPlayer(22,secondSubs(s))  = nanstd(tempData(:)); 
    
    
    % motor distance
    tempData = HitEucDistFromMoveOnset(:,:,1,s);
    DataMatrixPerPlayer(23,firstSubs(s))   = nanmedian(tempData(:));
    tempData = HitEucDistFromMoveOnset(:,:,2,s);
    DataMatrixPerPlayer(23,secondSubs(s))  = nanmedian(tempData(:)); 
        
    % motor speed
    tempData = HitEucDistFromMoveOnset(:,:,1,s)./MoveTime(:,:,1,s);
    DataMatrixPerPlayer(24,firstSubs(s))   = nanmedian(tempData(:));
    tempData = HitEucDistFromMoveOnset(:,:,2,s)./MoveTime(:,:,2,s);
    DataMatrixPerPlayer(24,secondSubs(s))  = nanmedian(tempData(:)); 
    
    % RT
    tempData = rtHit(:,:,1,s);
    DataMatrixPerPlayer(25,firstSubs(s))   = nanmedian(tempData(:));
    tempData = rtHit(:,:,2,s);
    DataMatrixPerPlayer(25,secondSubs(s))  = nanmedian(tempData(:)); 
        
    % distance
    tempData = HitEucDistFromStart(:,:,1,s);
    DataMatrixPerPlayer(26,firstSubs(s))   = nanmedian(tempData(:));
    tempData = HitEucDistFromStart(:,:,2,s);
    DataMatrixPerPlayer(26,secondSubs(s))  = nanmedian(tempData(:)); 
        
    % speed
    tempData = HitEucDistFromStart(:,:,1,s)./rtHit(:,:,1,s);
    DataMatrixPerPlayer(27,firstSubs(s))   = nanmedian(tempData(:));
    tempData = HitEucDistFromStart(:,:,2,s)./rtHit(:,:,2,s);
    DataMatrixPerPlayer(27,secondSubs(s))  = nanmedian(tempData(:)); 
    
    
    % RT miss
    tempData = rtHitMiss(:,:,1,s);
    DataMatrixPerPlayer(28,firstSubs(s))   = nanmedian(tempData(:));
    tempData = rtHitMiss(:,:,2,s);
    DataMatrixPerPlayer(28,secondSubs(s))  = nanmedian(tempData(:)); 
    
    % RT miss + hit
    tempData = [rtHit(:,:,1,s); rtHitMiss(:,:,1,s)];
    DataMatrixPerPlayer(29,firstSubs(s))   = nanmedian(tempData(:));
    tempData = [rtHit(:,:,2,s); rtHitMiss(:,:,2,s)];
    DataMatrixPerPlayer(29,secondSubs(s))  = nanmedian(tempData(:)); 
    
    
    
end

DataMatrixPerPlayer(30,firstSubs) = squeeze(sum(Scores(1,:,:)>Scores(2,:,:)));
DataMatrixPerPlayer(30,secondSubs) = squeeze(sum(Scores(1,:,:)<Scores(2,:,:)));


DataMatrixPerPlayerPerTrialVars = {'Score','nHit reward','nHit punish','nHits','nMiss','Decision RT','Motor RT','Decision Distance','Decision Speed','Vert. Dist.','Hori. Dist.','V. Dist. Std','H. Dist. Std','Motor distance','Motor speed','RT','distance','speed','RT miss','RT hit+miss','nWon','Mimicry'};

DataMatrixPerPlayerPerTrial(:,firstSubs,1)  = squeeze(Scores(1,:,:));
DataMatrixPerPlayerPerTrial(:,secondSubs,1) = squeeze(Scores(2,:,:));

for s = 1:length(Subjects{1})
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),2)   = nansum(1*(squeeze(TargetType(:,:,1,s))'==1));
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),2)  = nansum(1*(squeeze(TargetType(:,:,2,s))'==1));
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),3)   = nansum(1*(squeeze(TargetType(:,:,1,s))'==2));
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),3)  = nansum(1*(squeeze(TargetType(:,:,2,s))'==2));
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),4)   = nansum(1*(squeeze(TargetType(:,:,1,s))'==2|squeeze(TargetType(:,:,1,s))'==1));
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),4)  = nansum(1*(squeeze(TargetType(:,:,2,s))'==2|squeeze(TargetType(:,:,2,s))'==1));
    
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),5)   = nansum(1*isfinite(rtHitMiss(:,:,1,s))');
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),5)  = nansum(1*isfinite(rtHitMiss(:,:,2,s))');
    
    % median decision time
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),6)   = nanmedian(DecisionTime(:,:,1,s)');
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),6)  = nanmedian(DecisionTime(:,:,2,s)');
    
    % median movement time
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),7)   = nanmedian(MoveTime(:,:,1,s)');
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),7)  = nanmedian(MoveTime(:,:,2,s)');
    
    % movement distance
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),8)   = nanmedian(HitEucDistFromStart(:,:,1,s)'-HitEucDistFromMoveOnset(:,:,1,s)');
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),8)  = nanmedian(HitEucDistFromStart(:,:,2,s)'-HitEucDistFromMoveOnset(:,:,2,s)');
    
    % movement speed (distance/time)
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),9)   = nanmedian((HitEucDistFromStart(:,:,1,s)'-HitEucDistFromMoveOnset(:,:,1,s)')./DecisionTime(:,:,1,s)');
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),9)  = nanmedian((HitEucDistFromStart(:,:,2,s)'-HitEucDistFromMoveOnset(:,:,2,s)')./DecisionTime(:,:,2,s)');
    
    % median vert. territory location
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),10)   = nanmedian(HitDist(:,:,1,s)');
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),10)  = nanmedian(HitDist(:,:,2,s)');
    
    % median hori. territory location
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),11)   = nanmedian(HitWidth(:,:,1,s)');
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),11)  = nanmedian(HitWidth(:,:,2,s)');
    
    % std vert. territory
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),12)   = nanstd(HitDist(:,:,1,s)');
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),12)  = nanstd(HitDist(:,:,2,s)');
    
    % std hori. territory
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),13)   = nanstd(HitWidth(:,:,1,s)');
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),13)  = nanstd(HitWidth(:,:,2,s)');
    
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),14)   = nanmedian(HitEucDistFromMoveOnset(:,:,1,s)');
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),14)  = nanmedian(HitEucDistFromMoveOnset(:,:,2,s)');
    
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),15)   = nanmedian(HitEucDistFromMoveOnset(:,:,1,s)'./MoveTime(:,:,1,s)');
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),15)  = nanmedian(HitEucDistFromMoveOnset(:,:,2,s)'./MoveTime(:,:,2,s)');
    
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),16)   = nanmedian(rtHit(:,:,1,s)');
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),16)  = nanmedian(rtHit(:,:,2,s)');
    
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),17)   = nanmedian(HitEucDistFromStart(:,:,1,s)');
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),17)  = nanmedian(HitEucDistFromStart(:,:,2,s)');
    
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),18)   = nanmedian(HitEucDistFromStart(:,:,1,s)'./rtHit(:,:,1,s)');
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),18)  = nanmedian(HitEucDistFromStart(:,:,2,s)'./rtHit(:,:,2,s)');
    
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),19)   = nanmedian(rtHitMiss(:,:,1,s)');
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),19)  = nanmedian(rtHitMiss(:,:,2,s)');
    
    DataMatrixPerPlayerPerTrial(:,firstSubs(s),20)   = nanmedian([rtHit(:,:,1,s)'; rtHitMiss(:,:,1,s)']);
    DataMatrixPerPlayerPerTrial(:,secondSubs(s),20)  = nanmedian([rtHit(:,:,2,s)'; rtHitMiss(:,:,2,s)']);
    
end

%% CHECK FOR VARIATION IN TARGET LOCATIONS ACROSS PAIRS
% does this explain the correlations across pairs?

[R,P] = corrcoef(nanmean([DataMatrixPerPlayer(19,firstSubs); DataMatrixPerPlayer(19,secondSubs)]), nanmean(locListY));
[R,P] = corrcoef(nanmean([DataMatrixPerPlayer(20,firstSubs); DataMatrixPerPlayer(20,secondSubs)]), nanmean(locListX));

[R,P] = corrcoef(nanmean([DataMatrixPerPlayer(19,firstSubs); DataMatrixPerPlayer(19,secondSubs)]), var(locListY));
[R,P] = corrcoef(nanmean([DataMatrixPerPlayer(20,firstSubs); DataMatrixPerPlayer(20,secondSubs)]), var(locListX));

[R,P] = corrcoef(nanmean([DataMatrixPerPlayer(21,firstSubs); DataMatrixPerPlayer(21,secondSubs)]), var(locListY));
[R,P] = corrcoef(nanmean([DataMatrixPerPlayer(22,firstSubs); DataMatrixPerPlayer(22,secondSubs)]), var(locListX));

%% calculate mimicry score!


countPlots = 0;
mimicryScore = [];
for i = [6 10 13 15:21]
    countPlots = countPlots+1;
    
    % right way to calculate mimicry (fit regression)
    [b,bint,r,rint,stats] = regress(DataMatrixPerPlayer(i,firstSubs)',DataMatrixPerPlayer(i,secondSubs)');
    mimicryScore(countPlots,:) = r;
     
%      % easy way to calculate mimicry
%     for s = 1:length(Subjects{1})
%         
%         mimicryScore(countPlots,s) = DataMatrixPerPlayer(i,firstSubs(s))-DataMatrixPerPlayer(i,secondSubs(s));
%         
% %         plot(DataMatrixPerPlayer(i,firstSubs(s)),DataMatrixPerPlayer(i,secondSubs(s)),'ro');
% %         hold on
% %         text(DataMatrixPerPlayer(i,firstSubs(s)),DataMatrixPerPlayer(i,secondSubs(s)),num2str(s));
%     end
end

% only take positive values because it is all about the magnitude
mimicryScore = abs(mimicryScore);

% normalize mimicry score
mimicryScore = mimicryScore';
for i = 1:length([6 10 13 15:21])
    mimicryScore(:,i) = (mimicryScore(:,i)-min(mimicryScore(:,i)))./max(mimicryScore(:,i)-min(mimicryScore(:,i)));
end
mimicryScore = mimicryScore';



DataMatrixPerPlayer(31,firstSubs) = nanmean(mimicryScore);
% DataMatrixPerPlayer(29,secondSubs) = -1*nanmean(mimicryScore);

DataMatrixPerPlayer(31,secondSubs) = nanmean(mimicryScore);

correlation between mimicry and score
figure(99);
subplot(2,2,1);
plot(nanmean([DataMatrixPerPlayer(9,firstSubs); DataMatrixPerPlayer(9,secondSubs);])',nanmean([DataMatrixPerPlayer(23,firstSubs); DataMatrixPerPlayer(23,secondSubs);])','ro')
[r,p] = corr(nanmean([DataMatrixPerPlayer(9,firstSubs); DataMatrixPerPlayer(9,secondSubs);])',nanmean([DataMatrixPerPlayer(23,firstSubs); DataMatrixPerPlayer(23,secondSubs);])','type','spearman')

subplot(2,2,2);
plot(DataMatrixPerPlayer(9,:)',DataMatrixPerPlayer(23,:)','ro')
[r,p] = corr(DataMatrixPerPlayer(9,:)',DataMatrixPerPlayer(23,:)','type','spearman')


break

%%

%%%%%%%%%%%%%%%% ADD VARIANCE OF TRAJECTORY (CURVATURE) and Z-DIST AT
%%%%%%%%%%%%%%%% TARGET ONSET

%% Hits per target type
% Figure 1c

Colors = [0 1 0; 0 1 1; 1 0 0; 1 0 1; 0 0 1; 0.5 0 1];
tempData = [];
for i = 1:6
    for s = 1:length(Subjects{1})
        tempData1 = squeeze(TargetType(:,:,1,s));
        tempData2 = squeeze(TargetType(:,:,2,s));
    
        tempData(i,s) = nansum(1*(tempData1(:)==i))/(sum(isfinite(tempData1(:))));
        tempData(i,s+length(Subjects{1})) = nansum(1*(tempData2(:)==i))/(sum(isfinite(tempData2(:))));
    end
end

h = figure(1);
bar(1:6,nanmean(tempData'),'b')
hold on
errorbar(1:6,nanmean(tempData'),nanste(tempData'),'k.')

nanmean(tempData')
nanstd(tempData')

saveas(h,'Figures4/Figure1c.ai');
saveas(h,'Figures4/Figure1c.pdf');

plot2svg('Figures4/Figure1c.svg',h);

%% hit frequency in general

tempData = [];
% for i = 1:6
    for s = 1:length(Subjects{1})
%         tempData(i,s+length(Subjects{1})) = nanmean(nTargetType(:,i,1,s))
        
        tempData1 = HitFrequency(:,:,s);
        tempData(s) = nanmean(tempData1(1,:)+tempData1(2,:));
    end
% end

nanmean(tempData)
nanstd(tempData)

%% overlap in vertical territories

A = [];
R = [];
d = [];
for s = 1:length(Subjects{1})
    tempData1 = HitDist(:,:,1,s);
    tempData2 = HitDist(:,:,2,s);
    [A(s),R,d(s)] = computeROC(tempData1(:),768-tempData2(:));
    
end
nanmean(2*A)
nanstd(2*A)

%% percentage of misses
tempData = [];
for s = 1:length(Subjects{1})
    tempData1 = rtHitMiss(:,:,:,s);
    tempData2 = rtHit(:,:,:,s);
    
    tempData(s) = nansum(1*isfinite(tempData1(:)))/nansum(1*isfinite(tempData2(:)));
    
end
nanmean(tempData)
nanstd(tempData)

%% Density maps of example pair
% Figure 1d

h = figure(2);

for s = 14%1:length(Subjects{1})
%         subplot(4,4,s);
    tempIm = zeros(size(HitMaps,1),size(HitMaps,2),3);
    tempIm(:,:,1) = HitMaps(:,:,1,s);
    tempIm(:,:,3) = HitMaps(:,:,2,s);

    tempIm(:) = (tempIm(:)./max(tempIm(:)))*255;

    imshow(uint8(tempIm));
end
imagesc(uint8(tempIm(:,:,1)))
colormap('jet')
colormap('hot')

% show table
hold on
line([GaborRad/2 size(HitMaps,2)-GaborRad/2],[size(HitMaps,1)/2 size(HitMaps,1)/2],'Color',[.99 .99 .99],'LineWidth',2,'LineStyle',':') % center
line([GaborRad/2 size(HitMaps,2)-GaborRad/2],[GaborRad/2 GaborRad/2],'Color',[.99 .99 .99],'LineWidth',2,'LineStyle',':') % table
line([GaborRad/2 size(HitMaps,2)-GaborRad/2],[size(HitMaps,1)-GaborRad/2 size(HitMaps,1)-GaborRad/2],'Color',[.99 .99 .99],'LineWidth',2,'LineStyle',':') % table
line([GaborRad/2 GaborRad/2],[GaborRad/2 size(HitMaps,1)-GaborRad/2],'Color',[.99 .99 .99],'LineWidth',2,'LineStyle',':') % table
line([size(HitMaps,2)-GaborRad/2 size(HitMaps,2)-GaborRad/2],[GaborRad/2 size(HitMaps,1)-GaborRad/2],'Color',[.99 .99 .99],'LineWidth',2,'LineStyle',':') % table

% show position of head
HeadSize = 40;
[X,Y] = pol2cart(0:2*pi/100:2*pi,zeros(1,101)+HeadSize);
patch(X+1024/2+GaborRad,Y+HeadSize,'b')
patch([512+GaborRad 512+GaborRad-HeadSize/2 512+GaborRad+HeadSize/2],[2*HeadSize+HeadSize/3 1.5*HeadSize 1.5*HeadSize],'b','EdgeColor','b')
[X,Y] = pol2cart([0:pi/100:pi]+1.5*pi,[linspace(0.1,1,50) 1 linspace(1,.1,50)].*HeadSize/2);
patch(X+1024/2+GaborRad-1.1*HeadSize,Y+HeadSize,'b','EdgeColor','b')
[X,Y] = pol2cart([0:pi/100:pi]+.5*pi,[linspace(0.1,1,50) 1 linspace(1,.1,50)].*HeadSize/2);
patch(X+1024/2+GaborRad+1.1*HeadSize,Y+HeadSize,'b','EdgeColor','b')
text(1024/2+GaborRad,HeadSize/2,'s: 14','HorizontalAlignment','center','Color',[.99 .99 .99])
text(1024/2+GaborRad,HeadSize/2+20,'W','HorizontalAlignment','center','Color',[.99 .99 .99])

[X,Y] = pol2cart(0:2*pi/100:2*pi,zeros(1,101)+HeadSize);
patch(X+1024/2+GaborRad,Y+HeadSize+768-GaborRad/2,'r')
patch([512+GaborRad 512+GaborRad-HeadSize/2 512+GaborRad+HeadSize/2],[-2*HeadSize-HeadSize/3+size(HitMaps,1) -1.5*HeadSize+size(HitMaps,1) -1.5*HeadSize+size(HitMaps,1)],'r','EdgeColor','r')
[X,Y] = pol2cart([0:pi/100:pi]+1.5*pi,[linspace(0.1,1,50) 1 linspace(1,.1,50)].*HeadSize/2);
patch(X+1024/2+GaborRad-1.1*HeadSize,Y+HeadSize+768-GaborRad/2,'r','EdgeColor','r')
[X,Y] = pol2cart([0:pi/100:pi]+.5*pi,[linspace(0.1,1,50) 1 linspace(1,.1,50)].*HeadSize/2);
patch(X+1024/2+GaborRad+1.1*HeadSize,Y+HeadSize+768-GaborRad/2,'r','EdgeColor','r')
text(1024/2+GaborRad,size(HitMaps,1)-HeadSize/2-GaborRad/2,'s: 14','HorizontalAlignment','center','Color',[.99 .99 .99])
text(1024/2+GaborRad,size(HitMaps,1)-HeadSize/2+20-GaborRad/2,'L','HorizontalAlignment','center','Color',[.99 .99 .99])

Threshold = 70;
tempIm2 = tempIm(:,:,2);
[C1,h1] = contour(tempIm(:,:,2),[prctile(tempIm2(:),Threshold) prctile(tempIm2(:),Threshold)],'r','Color',[0 .5 0]);
tempIm2 = tempIm(:,:,3);
[C2,h2] = contour(tempIm(:,:,3),[prctile(tempIm2(:),Threshold) prctile(tempIm2(:),Threshold)],'b','Color',[0 0 .5]);

tempDist = HitDist(:,:,1,s);
tempDist2 = HitWidth(:,:,1,s);
%     nanmedian(tempDist(:))
tempDist = size(HitMaps,1)-(tempDist(isfinite(tempDist))+GaborRad/2);
tempDist2 = size(HitMaps,2)-(tempDist2(isfinite(tempDist2))+GaborRad/2);
line([size(HitMaps,2)-GaborRad/2 size(HitMaps,2)],[nanmedian(tempDist) nanmedian(tempDist)],'Color','r','LineWidth',3)
line([nanmedian(tempDist2) nanmedian(tempDist2)],[size(HitMaps,1)-GaborRad/2 size(HitMaps,1)],'Color','r','LineWidth',3)
line([size(HitMaps,2)-GaborRad/2 size(HitMaps,2)],[prctile(tempDist,10) prctile(tempDist,10)],'Color','r','LineWidth',3,'LineStyle',':')

tempDist = HitDist(:,:,2,s);
tempDist2 = HitWidth(:,:,2,s);
%     nanmedian(tempDist(:))
tempDist = tempDist(isfinite(tempDist))+GaborRad/2;
tempDist2 = (tempDist2(isfinite(tempDist2))+GaborRad/2);
line([0 GaborRad/2],[nanmedian(tempDist) nanmedian(tempDist)],'Color','b','LineWidth',3)
line([nanmedian(tempDist2) nanmedian(tempDist2)],[0 GaborRad/2],'Color','b','LineWidth',3)
line([0 GaborRad/2],[prctile(tempDist,90) prctile(tempDist,90)],'Color','b','LineWidth',3,'LineStyle',':')

line([0 GaborRad/2],[nanmedian(tempDist) nanmedian(tempDist)],'Color','b','LineWidth',3)
line([0 GaborRad/2],[prctile(tempDist,90) prctile(tempDist,90)],'Color','b','LineWidth',3,'LineStyle',':')


nVals = 254;
collermapper = flipud([linspace(0,1,nVals)' linspace(0,0,nVals)' linspace(1,0,nVals)']);
colormap(collermapper);
cb = colorbar('YTick',0:(nVals)/2:nVals,'YTickLabel',{'Player 1','Overlap Hits','Player 2'});
set(get(cb,'ylabel'),'String', 'Hit Frequency');
set(get(cb,'title'),'String', 'Hit Frequency');

saveas(h,['Figures4/Figure1d.png']);     
saveas(h,['Figures4/Figure1d.ai']);     
saveas(h,['Figures4/Figure1d.pdf']);
plot2svg('Figures4/Figure1d.svg',h);

break

%% 3d traces examples of both players
% Figure 1e

h = figure(3);
plot3(TempData(1,261:HitMoment+241),TempData(2,261:HitMoment+241),TempData(3,261:HitMoment+241),'b-','LineWidth',2)
hold on
plot3(TempDataMiss(1,241:HitMomentMiss+241),TempDataMiss(2,241:HitMomentMiss+241),TempDataMiss(3,241:HitMomentMiss+241),'r-','LineWidth',2)

plot3(TempData(1,moveOnset+241),TempData(2,moveOnset+241),TempData(3,moveOnset+241),'bo-','LineWidth',4)
plot3(TempDataMiss(1,moveOnsetMiss+241),TempDataMiss(2,moveOnsetMiss+241),TempDataMiss(3,moveOnsetMiss+241),'ro-','LineWidth',2)

xlim([0 1024])
ylim([0 768])
zlim([0 300])
set(gca,'xtick',[0 256 512 768 1024])
set(gca,'ytick',[0 192 384 576 768])
set(gca,'ztick',[0 75 150 225 300])


plot3(1024+zeros(1,HitMoment+1-20),TempData(2,261:HitMoment+241),TempData(3,261:HitMoment+241),'b-','LineWidth',1)
plot3(TempData(1,261:HitMoment+241),768+zeros(1,HitMoment+1-20),TempData(3,261:HitMoment+241),'b-','LineWidth',1)
plot3(TempData(1,261:HitMoment+241),TempData(2,261:HitMoment+241),zeros(1,HitMoment+1-20),'b-','LineWidth',1)

plot3(1024+zeros(1,HitMomentMiss+1),TempDataMiss(2,241:HitMomentMiss+241),TempDataMiss(3,241:HitMomentMiss+241),'r-','LineWidth',1)
plot3(TempDataMiss(1,241:HitMomentMiss+241),768+zeros(1,HitMomentMiss+1),TempDataMiss(3,241:HitMomentMiss+241),'r-','LineWidth',1)
plot3(TempDataMiss(1,241:HitMomentMiss+241),TempDataMiss(2,241:HitMomentMiss+241),zeros(1,HitMomentMiss+1),'r-','LineWidth',1)

grid on


plot2svg('Figures4/Figure1e2.svg',h);



%% correlations across pairs of players
% Figure 2

h = figure(4);
countPlots = 0;
colormapper = colormap('jet');
colormapper = colormapper(round(linspace(1,64,length(Subjects{1}))),:);
    
ylims = [35 50 65 80; 3.5 5.0 6.5 8; 600 850 1100 1350; 0 150 300 450; .35 .50 .65 0.8; 0 .05 .10 0.15; 6.5 8.5 10.5 12.5; 12 15 18 21; 6 9 12 15; 15 20 25 30; 4 6 8 10; 10.5 11.5 12.5 13.5; 0 2.5 5 7.5; 26 38 50 62; 0.55 0.65 0.75 0.85; 12 14 16 18; 14 18 22 26; 0.4 .6 .8 1.0; 0.4 .6 .8 1.0];
for i = [6 10 13:29] %1:size(DataMatrixPerPlayer,1)
    countPlots = countPlots+1;
    subplot(5,4,countPlots)
    for s = 1:length(Subjects{1})
        plot(DataMatrixPerPlayer(i,firstSubs(s)),DataMatrixPerPlayer(i,secondSubs(s)),'ko','Color',colormapper(s,:));
        hold on
    end
%     ylabel(DataMatrixPerPlayerVars{i});
    axis square
    vector = isfinite(DataMatrixPerPlayer(i,firstSubs)') & isfinite(DataMatrixPerPlayer(i,secondSubs)');
    [R,P] = corr(DataMatrixPerPlayer(i,firstSubs(vector))',DataMatrixPerPlayer(i,secondSubs(vector))','type','spearman');
    R = num2str(R);
    P = num2str(P);
    if ( length(P) < 2 )
        P = '0.000';
    end
    if ( length(R) < 5 )
        R = [R '0'];
    end
    text(mean(DataMatrixPerPlayer(i,firstSubs(vector))),mean(DataMatrixPerPlayer(i,secondSubs(vector))),['R=' R(1:5)]);
    text(mean(DataMatrixPerPlayer(i,firstSubs(vector))),mean(DataMatrixPerPlayer(i,secondSubs(vector)))-std(DataMatrixPerPlayer(i,secondSubs(vector)))*1,['P=' P(1:5)]);
    
    title(DataMatrixPerPlayerVars{i});
%     xlabel('Player 1');
%     ylabel('Player 2');

    Po = polyfit(DataMatrixPerPlayer(i,firstSubs(vector)),DataMatrixPerPlayer(i,secondSubs(vector)),1);
    line(ylims(countPlots,[1 4]),ylims(countPlots,[1 4]),'Color','k')
    line(ylims(countPlots,[1 4]),polyval(Po,ylims(countPlots,[1 4])),'Color','r','LineWidth',1)
    
    xlim(ylims(countPlots,[1 4]));
    ylim(ylims(countPlots,[1 4]));
    set(gca,'xtick',ylims(countPlots,:));
    set(gca,'ytick',ylims(countPlots,:));
end

plot2svg('Figures4/Figure2.svg',h);


%% correlations per trial
% Figure S2

h = figure(5);
countPlots = 1;
for i = [1 4:18]
    tempData = [];
    for t = 1:30
        [R,P] = corrcoef(DataMatrixPerPlayerPerTrial(t,firstSubs,i),DataMatrixPerPlayerPerTrial(t,secondSubs,i));
        tempData(t,1:2) = [R(2) P(2)];
    end
    countPlots = countPlots+1;
    subplot(5,4,countPlots)
    plot(tempData(:,1),'ko-');
    for t = 1:30
        if ( tempData(t,2)<0.05 )
            text(t,0,'*');
        end
    end
    title(DataMatrixPerPlayerPerTrialVars{i});
    axis square
    ylim([-1 1])
    xlim([0 31])
    set(gca,'xtick',[0 10 20 30]);
    set(gca,'ytick',-1:.5:1);
end
plot2svg('Figures4/FigureS2.svg',h);


h = figure(55);
countPlots = 1;
for i = [14 16]
    tempData = [];
    for t = 1:30
        [R,P] = corrcoef(DataMatrixPerPlayerPerTrial(t,firstSubs,i),DataMatrixPerPlayerPerTrial(t,secondSubs,i));
        tempData(t,1:2) = [R(2) P(2)];
    end
    countPlots = countPlots+1;
    subplot(2,2,countPlots)
    plot(tempData(:,1),'ko-');
    for t = 1:30
        if ( tempData(t,2)<0.05 )
            text(t,0,'*','HorizontalAlignment','center');
        end
    end
    title(DataMatrixPerPlayerPerTrialVars{i});
    axis square
    ylim([-1 1])
    xlim([0 31])
    set(gca,'xtick',[0 10 20 30]);
    set(gca,'ytick',-1:.5:1);
end
plot2svg('Figures4/FigureS2.svg',h);

%% behavior over time

for i = 1:size(DataMatrixPerPlayerPerTrial,3)
    FirstRT = DataMatrixPerPlayerPerTrial(:,firstSubs,i);
    SecondRT = DataMatrixPerPlayerPerTrial(:,secondSubs,i);

    figure(9999);
    subplot(4,5,i)
    plot(nanmean(FirstRT,2),'b')
    hold on
    plot(nanmean(SecondRT,2),'r')
    title(DataMatrixPerPlayerPerTrialVars{i});
end


%% Reaction times per fast and slow players

FirstRT = DataMatrixPerPlayerPerTrial(:,firstSubs,16);
SecondRT = DataMatrixPerPlayerPerTrial(:,secondSubs,16);

figure(1001);
subplot(2,2,1)
plot(nanmean(FirstRT,2),'b')
hold on
plot(nanmean(SecondRT,2),'r')

% MeanRT = mean([FirstRT(1,:); SecondRT(1,:)]);
[MeanRT_sorted1,Mean_idx1] = sort(FirstRT(1,:));
[MeanRT_sorted2,Mean_idx2] = sort(SecondRT(1,:));

[MeanRT_sorted1,Mean_idx1] = sort(mean(FirstRT(1:3,:)));
[MeanRT_sorted2,Mean_idx2] = sort(mean(SecondRT(1:3,:)));

% select Fast-Fast players
selectVectFast1 = logical(zeros(1,length(firstSubs)));
selectVectFast1(Mean_idx1(1:round(length(selectVectFast1)/2))) = 1;
selectVectFast2 = logical(zeros(1,length(firstSubs)));
selectVectFast2(Mean_idx2(1:round(length(selectVectFast1)/2))) = 1;

subplot(2,2,2)
plot(nanmean(FirstRT(:,selectVectFast1),2),'g')
hold on
plot(nanmean(SecondRT(:,selectVectFast2),2),'g')

% select Slow-Slow players
selectVectSlow1 = ~selectVectFast1;
selectVectSlow2 = ~selectVectFast2;

subplot(2,2,2)
plot(nanmean(FirstRT(:,selectVectSlow1),2),'r')
hold on
plot(nanmean(SecondRT(:,selectVectSlow2),2),'r')

DiffRT = abs(FirstRT(1,:)-SecondRT(2,:)); % first trial differences

subplot(2,2,3)
plot(nanmean(FirstRT(:,selectVectFast1&selectVectFast2),2),'g')
hold on
plot(nanmean(FirstRT(:,selectVectFast1&selectVectSlow2),2),'y')
plot(nanmean(FirstRT(:,selectVectSlow1&selectVectFast2),2),'m')
plot(nanmean(FirstRT(:,selectVectSlow1&selectVectSlow2),2),'r')

subplot(2,2,4)
plot(nanmean(SecondRT(:,selectVectFast1&selectVectFast2),2),'g')
hold on
plot(nanmean(SecondRT(:,selectVectFast1&selectVectSlow2),2),'m')
plot(nanmean(SecondRT(:,selectVectSlow1&selectVectFast2),2),'y')
plot(nanmean(SecondRT(:,selectVectSlow1&selectVectSlow2),2),'r')

figure(1002);
ha =[];

xdata = 1:30;
ydata = nanmean([FirstRT(:,selectVectFast1&selectVectFast2) SecondRT(:,selectVectFast1&selectVectFast2)],2)';
stedata = nanste([FirstRT(:,selectVectFast1&selectVectFast2) SecondRT(:,selectVectFast1&selectVectFast2)]');
plot(xdata,ydata,'g')
hold on
ha(1) = patch([xdata fliplr(xdata)],[ydata+stedata fliplr(ydata-stedata)],'g','FaceAlpha',0.3,'EdgeAlpha',0)

ydata = nanmean([FirstRT(:,selectVectFast1&selectVectSlow2) SecondRT(:,selectVectSlow1&selectVectFast2)],2)';
stedata = nanste([FirstRT(:,selectVectFast1&selectVectSlow2) SecondRT(:,selectVectSlow1&selectVectFast2)]');
plot(xdata,ydata,'y')
hold on
ha(2) = patch([xdata fliplr(xdata)],[ydata+stedata fliplr(ydata-stedata)],'y','FaceAlpha',0.3,'EdgeAlpha',0)

ydata = nanmean([FirstRT(:,selectVectSlow1&selectVectFast2) SecondRT(:,selectVectFast1&selectVectSlow2)],2)';
stedata = nanste([FirstRT(:,selectVectSlow1&selectVectFast2) SecondRT(:,selectVectFast1&selectVectSlow2)]');
plot(xdata,ydata,'m')
hold on
ha(3) = patch([xdata fliplr(xdata)],[ydata+stedata fliplr(ydata-stedata)],'m','FaceAlpha',0.3,'EdgeAlpha',0)

ydata = nanmean([FirstRT(:,selectVectSlow1&selectVectSlow2) SecondRT(:,selectVectSlow1&selectVectSlow2)],2)';
stedata = nanste([FirstRT(:,selectVectSlow1&selectVectSlow2) SecondRT(:,selectVectSlow1&selectVectSlow2)]');
plot(xdata,ydata,'r')
hold on
ha(4) = patch([xdata fliplr(xdata)],[ydata+stedata fliplr(ydata-stedata)],'r','FaceAlpha',0.3,'EdgeAlpha',0)

legend(ha,{'Fast player against fast opponent','Fast player against slow opponent','Slow player against fast opponent','Slow player against slow opponent'});


%% correlate RT of each of these 4 groups

figure(1003);
subplot(2,2,1);
plot(DataMatrixPerPlayer(25,firstSubs(selectVectFast1&selectVectFast2)),DataMatrixPerPlayer(25,secondSubs(selectVectFast1&selectVectFast2)),'go')
hold on
plot(DataMatrixPerPlayer(25,firstSubs(selectVectFast1&selectVectSlow2)),DataMatrixPerPlayer(25,secondSubs(selectVectSlow1&selectVectFast2)),'yo','Color',[1 .75 0])
plot(DataMatrixPerPlayer(25,firstSubs(selectVectSlow1&selectVectFast2)),DataMatrixPerPlayer(25,secondSubs(selectVectFast1&selectVectSlow2)),'mx')
plot(DataMatrixPerPlayer(25,firstSubs(selectVectSlow1&selectVectSlow2)),DataMatrixPerPlayer(25,secondSubs(selectVectSlow1&selectVectSlow2)),'rx')
legend('Fast player against fast opponent','Fast player against slow opponent','Slow player against fast opponent','Slow player against slow opponent','Location','NorthWest');
axis square
xlim([0.55 0.85])
ylim([0.55 0.85])

ydata = cell(1,4);
ydata{1} = [DataMatrixPerPlayer(25,firstSubs(selectVectFast1&selectVectFast2))'; DataMatrixPerPlayer(25,secondSubs(selectVectFast1&selectVectFast2))'];
ydata{2} = [DataMatrixPerPlayer(25,firstSubs(selectVectFast1&selectVectSlow2))'; DataMatrixPerPlayer(25,secondSubs(selectVectSlow1&selectVectFast2))'];
ydata{3} = [DataMatrixPerPlayer(25,firstSubs(selectVectSlow1&selectVectFast2))'; DataMatrixPerPlayer(25,secondSubs(selectVectFast1&selectVectSlow2))'];
ydata{4} = [DataMatrixPerPlayer(25,firstSubs(selectVectSlow1&selectVectSlow2))'; DataMatrixPerPlayer(25,secondSubs(selectVectSlow1&selectVectSlow2))'];

ydata{1} = [nanmean(DataMatrixPerPlayerPerTrial(1:5,firstSubs(selectVectFast1&selectVectFast2),16),1)'; nanmean(DataMatrixPerPlayerPerTrial(1:5,secondSubs(selectVectFast1&selectVectFast2),16),1)'];
ydata{2} = [nanmean(DataMatrixPerPlayerPerTrial(1:5,firstSubs(selectVectFast1&selectVectSlow2),16),1)'; nanmean(DataMatrixPerPlayerPerTrial(1:5,secondSubs(selectVectSlow1&selectVectFast2),16),1)'];
ydata{3} = [nanmean(DataMatrixPerPlayerPerTrial(1:5,firstSubs(selectVectSlow1&selectVectFast2),16),1)'; nanmean(DataMatrixPerPlayerPerTrial(1:5,secondSubs(selectVectFast1&selectVectSlow2),16),1)'];
ydata{4} = [nanmean(DataMatrixPerPlayerPerTrial(1:5,firstSubs(selectVectSlow1&selectVectSlow2),16),1)'; nanmean(DataMatrixPerPlayerPerTrial(1:5,secondSubs(selectVectSlow1&selectVectSlow2),16),1)'];

Colors = {'g','y','m','r'};
subplot(2,2,2);
for i = 1:4
    bar(i,nanmean(ydata{i}),Colors{i})
    hold on
    errorbar(i,nanmean(ydata{i}),nanste(ydata{i}),'k');
end
ylim([.6 .8])
xlim([0 5])
xlabel('Conditions');
ylabel('RT');

corrmatrix = NaN(4,4);
for i = 1:4
    for j = 1:4
        corrmatrix(i,j) = ttest2(ydata{i},ydata{j});
    end
end

%% Move distance per fast and slow players

FirstRT = DataMatrixPerPlayerPerTrial(:,firstSubs,14);
SecondRT = DataMatrixPerPlayerPerTrial(:,secondSubs,14);

figure(2001);
subplot(2,2,1)
plot(nanmean(FirstRT,2),'b')
hold on
plot(nanmean(SecondRT,2),'r')

% MeanRT = mean([FirstRT(1,:); SecondRT(1,:)]);
[MeanRT_sorted1,Mean_idx1] = sort(FirstRT(1,:));
[MeanRT_sorted2,Mean_idx2] = sort(SecondRT(1,:));

[MeanRT_sorted1,Mean_idx1] = sort(mean(FirstRT(1:3,:)));
[MeanRT_sorted2,Mean_idx2] = sort(mean(SecondRT(1:3,:)));

% select Short-Short players
selectVectFast1 = logical(zeros(1,length(firstSubs)));
selectVectFast1(Mean_idx1(1:round(length(selectVectFast1)/2))) = 1;
selectVectFast2 = logical(zeros(1,length(firstSubs)));
selectVectFast2(Mean_idx2(1:round(length(selectVectFast1)/2))) = 1;

subplot(2,2,2)
plot(nanmean(FirstRT(:,selectVectFast1),2),'g')
hold on
plot(nanmean(SecondRT(:,selectVectFast2),2),'g')

% select Long-Long players
selectVectSlow1 = ~selectVectFast1;
selectVectSlow2 = ~selectVectFast2;

subplot(2,2,2)
plot(nanmean(FirstRT(:,selectVectSlow1),2),'r')
hold on
plot(nanmean(SecondRT(:,selectVectSlow2),2),'r')

DiffRT = abs(FirstRT(1,:)-SecondRT(2,:)); % first trial differences

subplot(2,2,3)
plot(nanmean(FirstRT(:,selectVectFast1&selectVectFast2),2),'g')
hold on
plot(nanmean(FirstRT(:,selectVectFast1&selectVectSlow2),2),'y')
plot(nanmean(FirstRT(:,selectVectSlow1&selectVectFast2),2),'m')
plot(nanmean(FirstRT(:,selectVectSlow1&selectVectSlow2),2),'r')

subplot(2,2,4)
plot(nanmean(SecondRT(:,selectVectFast1&selectVectFast2),2),'g')
hold on
plot(nanmean(SecondRT(:,selectVectFast1&selectVectSlow2),2),'m')
plot(nanmean(SecondRT(:,selectVectSlow1&selectVectFast2),2),'y')
plot(nanmean(SecondRT(:,selectVectSlow1&selectVectSlow2),2),'r')

figure(2002);
ha =[];

xdata = 1:30;
ydata = nanmean([FirstRT(:,selectVectFast1&selectVectFast2) SecondRT(:,selectVectFast1&selectVectFast2)],2)';
stedata = nanste([FirstRT(:,selectVectFast1&selectVectFast2) SecondRT(:,selectVectFast1&selectVectFast2)]');
plot(xdata,ydata,'r')
hold on
ha(1) = patch([xdata fliplr(xdata)],[ydata+stedata fliplr(ydata-stedata)],'r','FaceAlpha',0.3,'EdgeAlpha',0)

ydata = nanmean([FirstRT(:,selectVectFast1&selectVectSlow2) SecondRT(:,selectVectSlow1&selectVectFast2)],2)';
stedata = nanste([FirstRT(:,selectVectFast1&selectVectSlow2) SecondRT(:,selectVectSlow1&selectVectFast2)]');
plot(xdata,ydata,'m')
hold on
ha(2) = patch([xdata fliplr(xdata)],[ydata+stedata fliplr(ydata-stedata)],'m','FaceAlpha',0.3,'EdgeAlpha',0)

ydata = nanmean([FirstRT(:,selectVectSlow1&selectVectFast2) SecondRT(:,selectVectFast1&selectVectSlow2)],2)';
stedata = nanste([FirstRT(:,selectVectSlow1&selectVectFast2) SecondRT(:,selectVectFast1&selectVectSlow2)]');
plot(xdata,ydata,'y')
hold on
ha(3) = patch([xdata fliplr(xdata)],[ydata+stedata fliplr(ydata-stedata)],'y','FaceAlpha',0.3,'EdgeAlpha',0)

ydata = nanmean([FirstRT(:,selectVectSlow1&selectVectSlow2) SecondRT(:,selectVectSlow1&selectVectSlow2)],2)';
stedata = nanste([FirstRT(:,selectVectSlow1&selectVectSlow2) SecondRT(:,selectVectSlow1&selectVectSlow2)]');
plot(xdata,ydata,'g')
hold on
ha(4) = patch([xdata fliplr(xdata)],[ydata+stedata fliplr(ydata-stedata)],'g','FaceAlpha',0.3,'EdgeAlpha',0)

legend(ha,{'Short player against short opponent','Short player against long opponent','Long player against short opponent','Long player against long opponent'});
xlabel('Trial Number')
ylabel('Move Distance')

%% correlate motor distance of each of these 4 groups

figure(2003);
subplot(2,2,1);
plot(DataMatrixPerPlayer(23,firstSubs(selectVectFast1&selectVectFast2)),DataMatrixPerPlayer(23,secondSubs(selectVectFast1&selectVectFast2)),'go')
hold on
plot(DataMatrixPerPlayer(23,firstSubs(selectVectFast1&selectVectSlow2)),DataMatrixPerPlayer(23,secondSubs(selectVectSlow1&selectVectFast2)),'yo','Color',[1 .75 0])
plot(DataMatrixPerPlayer(23,firstSubs(selectVectSlow1&selectVectFast2)),DataMatrixPerPlayer(23,secondSubs(selectVectFast1&selectVectSlow2)),'mx')
plot(DataMatrixPerPlayer(23,firstSubs(selectVectSlow1&selectVectSlow2)),DataMatrixPerPlayer(23,secondSubs(selectVectSlow1&selectVectSlow2)),'rx')
legend('Fast player against fast opponent','Fast player against slow opponent','Slow player against fast opponent','Slow player against slow opponent','Location','NorthWest');
axis square
xlim([0 10])
ylim([0 10])


ydata = cell(1,4);
ydata{1} = [DataMatrixPerPlayer(23,firstSubs(selectVectFast1&selectVectFast2))'; DataMatrixPerPlayer(23,secondSubs(selectVectFast1&selectVectFast2))'];
ydata{2} = [DataMatrixPerPlayer(23,firstSubs(selectVectFast1&selectVectSlow2))'; DataMatrixPerPlayer(23,secondSubs(selectVectSlow1&selectVectFast2))'];
ydata{3} = [DataMatrixPerPlayer(23,firstSubs(selectVectSlow1&selectVectFast2))'; DataMatrixPerPlayer(23,secondSubs(selectVectFast1&selectVectSlow2))'];
ydata{4} = [DataMatrixPerPlayer(23,firstSubs(selectVectSlow1&selectVectSlow2))'; DataMatrixPerPlayer(23,secondSubs(selectVectSlow1&selectVectSlow2))'];

ydata{1} = [nanmean(DataMatrixPerPlayerPerTrial(1:5,firstSubs(selectVectFast1&selectVectFast2),14),1)'; nanmean(DataMatrixPerPlayerPerTrial(1:5,secondSubs(selectVectFast1&selectVectFast2),14),1)'];
ydata{2} = [nanmean(DataMatrixPerPlayerPerTrial(1:5,firstSubs(selectVectFast1&selectVectSlow2),14),1)'; nanmean(DataMatrixPerPlayerPerTrial(1:5,secondSubs(selectVectSlow1&selectVectFast2),14),1)'];
ydata{3} = [nanmean(DataMatrixPerPlayerPerTrial(1:5,firstSubs(selectVectSlow1&selectVectFast2),14),1)'; nanmean(DataMatrixPerPlayerPerTrial(1:5,secondSubs(selectVectFast1&selectVectSlow2),14),1)'];
ydata{4} = [nanmean(DataMatrixPerPlayerPerTrial(1:5,firstSubs(selectVectSlow1&selectVectSlow2),14),1)'; nanmean(DataMatrixPerPlayerPerTrial(1:5,secondSubs(selectVectSlow1&selectVectSlow2),14),1)'];


Colors = {'r','m','y','g'};
subplot(2,2,2);
for i = 1:4
    bar(i,nanmean(ydata{i}),Colors{i})
    hold on
    errorbar(i,nanmean(ydata{i}),nanste(ydata{i}),'k');
end
ylim([2 6])
xlim([0 5])
xlabel('Conditions');
ylabel('Move Distance');

corrmatrix = NaN(4,4);
for i = 1:4
    for j = 1:4
        corrmatrix(i,j) = ttest2(ydata{i},ydata{j});
    end
end

%% correlate behavior across time

%% do the same for move distance




%% Hits per target type for winners and losers
% Figure Xa

h = figure(6);

subplot(2,2,1)
tempData = [];
tempData(1,:) = DataMatrixPerPlayer(11,[firstSubs(SubjectsWinExpVect==1) secondSubs(SubjectsWinExpVect==2)])./(DataMatrixPerPlayer(11,[firstSubs(SubjectsWinExpVect==1) secondSubs(SubjectsWinExpVect==2)])+DataMatrixPerPlayer(12,[firstSubs(SubjectsWinExpVect==1) secondSubs(SubjectsWinExpVect==2)])); % win hit reward
tempData(2,:) = DataMatrixPerPlayer(11,[firstSubs(SubjectsWinExpVect==2) secondSubs(SubjectsWinExpVect==1)])./(DataMatrixPerPlayer(11,[firstSubs(SubjectsWinExpVect==2) secondSubs(SubjectsWinExpVect==1)])+DataMatrixPerPlayer(12,[firstSubs(SubjectsWinExpVect==2) secondSubs(SubjectsWinExpVect==1)])); % lost hit reward
tempData(3,:) = DataMatrixPerPlayer(12,[firstSubs(SubjectsWinExpVect==1) secondSubs(SubjectsWinExpVect==2)])./(DataMatrixPerPlayer(11,[firstSubs(SubjectsWinExpVect==1) secondSubs(SubjectsWinExpVect==2)])+DataMatrixPerPlayer(12,[firstSubs(SubjectsWinExpVect==1) secondSubs(SubjectsWinExpVect==2)])); % win hit punish
tempData(4,:) = DataMatrixPerPlayer(12,[firstSubs(SubjectsWinExpVect==2) secondSubs(SubjectsWinExpVect==1)])./(DataMatrixPerPlayer(11,[firstSubs(SubjectsWinExpVect==2) secondSubs(SubjectsWinExpVect==1)])+DataMatrixPerPlayer(12,[firstSubs(SubjectsWinExpVect==2) secondSubs(SubjectsWinExpVect==1)])); % lost hit punish

bar(1:4,nanmean(tempData'))
hold on
errorbar(1:4,nanmean(tempData'),nanste(tempData'),'k.')
ylim([.4 .6])

subplot(2,2,2)
tempData2 = [];
tempData2(1,:) = DataMatrixPerPlayer(11,[firstSubs(SubjectsWinExpVect==1) secondSubs(SubjectsWinExpVect==2)]); % win hit reward
tempData2(2,:) = DataMatrixPerPlayer(11,[firstSubs(SubjectsWinExpVect==2) secondSubs(SubjectsWinExpVect==1)]); % lost hit reward
tempData2(3,:) = DataMatrixPerPlayer(12,[firstSubs(SubjectsWinExpVect==1) secondSubs(SubjectsWinExpVect==2)]); % win hit punish
tempData2(4,:) = DataMatrixPerPlayer(12,[firstSubs(SubjectsWinExpVect==2) secondSubs(SubjectsWinExpVect==1)]); % lost hit punish

bar(1:4,nanmean(tempData2'))
hold on
errorbar(1:4,nanmean(tempData2'),nanste(tempData2'),'k.')
% ylim([.4 .6])


anova_rm({[tempData(1,:)' tempData(3,:)'] [tempData(2,:)' tempData(4,:)']});

anova_rm({[tempData2(1,:)' tempData2(3,:)'] [tempData2(2,:)' tempData2(4,:)']});
[hh,pp] = ttest(tempData2(1,:)',tempData2(3,:)'); % NS
[hh,pp] = ttest(tempData2(2,:)',tempData2(4,:)'); % NS


% winner vs loser
group1 = [ones(sum(SubjectsWinExpVect~=0),1); ones(sum(SubjectsWinExpVect~=0),1)+1; ones(sum(SubjectsWinExpVect~=0),1); ones(sum(SubjectsWinExpVect~=0),1)+1];
% reward vs punishment
group2 = [ones(sum(SubjectsWinExpVect~=0),1); ones(sum(SubjectsWinExpVect~=0),1); ones(sum(SubjectsWinExpVect~=0),1)+1; ones(sum(SubjectsWinExpVect~=0),1)+1];
subjects = [repmat(1:sum(SubjectsWinExpVect~=0),1,4)]';

data = [tempData2(1,:)'; tempData2(2,:)'; tempData2(3,:)';tempData2(4,:)'];
P = anovan(data,{group1 group2 subjects},'random',3,'nested',[0 0 0; 0 0 0; 1 0 0],'varnames',{'Winner','Type','Subjects'},'model','full');

% NO SIGNIFICANT INTERACTION (p = 0.07)

anova_rm({[tempData2(1,:)' tempData2(3,:)'] [tempData2(2,:)' tempData2(4,:)']});

% NO SIGNIFICANT INTERACTION (p = 0.06)

%% Hits per target type for winners and losers per trial
% Figure Xb

Colors = {'g','r','y','m'};
subplot(2,2,3)
tempData2 = [];
tempData2(:,:,1) = DataMatrixPerPlayerPerTrial(:,[firstSubs(SubjectsWinExpVect==1) secondSubs(SubjectsWinExpVect==2)],2); % win hit reward
tempData2(:,:,2) = DataMatrixPerPlayerPerTrial(:,[firstSubs(SubjectsWinExpVect==2) secondSubs(SubjectsWinExpVect==1)],2); % lost hit reward
tempData2(:,:,3) = DataMatrixPerPlayerPerTrial(:,[firstSubs(SubjectsWinExpVect==1) secondSubs(SubjectsWinExpVect==2)],3); % win hit punish
tempData2(:,:,4) = DataMatrixPerPlayerPerTrial(:,[firstSubs(SubjectsWinExpVect==2) secondSubs(SubjectsWinExpVect==1)],3); % lost hit punish

for i = 1:4
    plot(nanmean(tempData2(:,:,i)'),Colors{i})
    hold on
% errorbar(i,nanmean(tempData'),nanste(tempData'),'k.')
% ylim([.4 .6])
end


% winner vs loser
group1 = [ones(30*sum(SubjectsWinExpVect~=0),1); ones(30*sum(SubjectsWinExpVect~=0),1)+1; ones(30*sum(SubjectsWinExpVect~=0),1); ones(30*sum(SubjectsWinExpVect~=0),1)+1];
% reward vs punishment
group2 = [ones(30*sum(SubjectsWinExpVect~=0),1); ones(30*sum(SubjectsWinExpVect~=0),1); ones(30*sum(SubjectsWinExpVect~=0),1)+1; ones(30*sum(SubjectsWinExpVect~=0),1)+1];
% trial
group3 = [repmat(repmat(1:30,1,sum(SubjectsWinExpVect~=0)),1,4)]';

subjects = [repmat(1:sum(SubjectsWinExpVect~=0),30,4)];
subjects = subjects(:);

data = [];
for i = 1:4
dataTemp = tempData2(:,:,i);
data = [data; dataTemp(:)];
end

% NO SIGNIFICANT INTERACTION (p = 0.057)
P = anovan(data,{group1 group2 group3 subjects},'random',[3 4],'nested',[0 0 0 0; 0 0 0 0; 1 0 0 0; 1 0 0 0],'varnames',{'Winner','Type','Trial','Subjects'},'model','interaction');


%% Independent variables per winners and losers
% Figure 3

h = figure(7);
ylims = [48 52 56 60; 4.5 5 5.5 6; 700 900 1100 1300; 100 150 200 250; 0.50 0.55 0.60 0.65; 0.06 0.07 0.08 0.09; 9.5 10 10.5 11; 15 16 17 18; 9 10 11 12; 21 22 23 24; 6 6.5 7 7.5; 11.6 11.8 12 12.2; 2.5 3 3.5 4; 40 43 46 49; 0.55 0.65 0.75 0.85; 12 14 16 18; 19 20 21 22;];
countPlots = 0;
pp = [];
tt = [];
for i = [6 10 13:27]
    countPlots = countPlots+1;
    subplot(5,4,countPlots)
    tempData1 = [DataMatrixPerPlayer(i,firstSubs((SubjectsWinExpVect==1))) DataMatrixPerPlayer(i,secondSubs((SubjectsWinExpVect==2)))];
    tempData2 = [DataMatrixPerPlayer(i,secondSubs((SubjectsWinExpVect==1))) DataMatrixPerPlayer(i,firstSubs((SubjectsWinExpVect==2)))];
    
    if ( i == 1 )
        bar(1,sum(tempData1),'w');
        hold on
        bar(2,sum(tempData2),'w');
    else
        bar(1,nanmean(tempData1),'w');
        hold on
        bar(2,nanmean(tempData2),'w');

        errorbar(1,nanmean(tempData1),nanste(tempData1),'k');
        errorbar(2,nanmean(tempData2),nanste(tempData2),'k');
    end
    
    axis square
    ylabel(DataMatrixPerPlayerVars{i});
    xlim([0 3]);
    ylim(ylims(countPlots,[1 4]));
    set(gca,'xtick',1:2)
    set(gca,'xticklabel',{'W','L'})
    set(gca,'ytick',ylims(countPlots,:))
%     set(gca,'yticklabel',num2str(ylims(countPlots,:)))
    
    [hh,pp(countPlots),conf,tstat] = ttest(tempData1,tempData2);
    tt(countPlots) = tstat.tstat;
    
    if ( pp(countPlots) < 0.05 )
        text(1.5,nanmean([tempData1 tempData2]),'*','HorizontalAlignment','center')
    end
end

plot2svg('Figures4/Figure3.svg',h);

%% Independent variables per winners and losers per trial
% Figure S3

h = figure(8);
countPlots = 1;
pp = [];
for i = [1 4:13]
    countPlots = countPlots+1;
    subplot(4,4,countPlots)
    tempData1 = [];
    tempData2 = [];
    for s = 1:length(Subjects{1})
        if ( SubjectsWinExpVect(s)==1 )
            tempData1(s,:) = DataMatrixPerPlayerPerTrial(:,firstSubs(s),i);
            tempData2(s,:) = DataMatrixPerPlayerPerTrial(:,secondSubs(s),i);
        elseif ( SubjectsWinExpVect(s)==2 )
            tempData1(s,:) = DataMatrixPerPlayerPerTrial(:,secondSubs(s),i);
            tempData2(s,:) = DataMatrixPerPlayerPerTrial(:,firstSubs(s),i);
        else
            tempData1(s,:) = NaN;
            tempData2(s,:) = NaN;
        end
    end
    
    plot(nanmean(tempData1),'b');
    hold on
    plot(nanmean(tempData2),'r');
    patch([1:30 30:-1:1],[nanmean(tempData1)-nanste(tempData1) fliplr(nanmean(tempData1)+nanste(tempData1))],'b')
    patch([1:30 30:-1:1],[nanmean(tempData2)-nanste(tempData2) fliplr(nanmean(tempData2)+nanste(tempData2))],'r')
    
%     errorbar(1,nanmean(tempData1),nanste(tempData1),'k');
%     errorbar(2,nanmean(tempData2),nanste(tempData2),'k');

    axis square
    ylabel(DataMatrixPerPlayerPerTrialVars{i});
    xlim([0 31]);
%     ylim(ylims(countPlots,[1 4]));
    set(gca,'xtick',0:10:30)
%     set(gca,'ytick',ylims(countPlots,:))
    
    for t = 1:30
        [hh,pp(t)] = ttest(tempData1(:,t),tempData2(:,t));
        if ( pp(t) < 0.05 )
            text(t,nanmean(nanmean([tempData1 tempData2])),'*','HorizontalAlignment','center')
        end
    end
end

plot2svg('Figures4/FigureS3.svg',h);



%% General linear model predicting score

% absolute score
% vars_idx = [6 10 13:22 1 2 3 23];
vars_idx = [19:22 25:27]; % no hits and misses
% vars_idx = [19:22 27]; % no hits and misses
% vars_idx = [19 21 27]; % no hits and misses

GLM_xdata = DataMatrixPerPlayer(vars_idx,:)';
for i = 1:length(vars_idx)
    GLM_xdata(:,i) = (GLM_xdata(:,i)-min(GLM_xdata(:,i)))./max(GLM_xdata(:,i)-min(GLM_xdata(:,i)));
end

GLM_ydata = DataMatrixPerPlayer(9,:)';
GLM_ydata = DataMatrixPerPlayer(28,:)';
GLM_ydata = (GLM_ydata-min(GLM_ydata))./max(GLM_ydata-min(GLM_ydata));
[b,dev,stats]    = glmfit(GLM_xdata, GLM_ydata, 'normal');

DataMatrixPerPlayerVars{vars_idx(stats.p(2:end)<0.05)}
{DataMatrixPerPlayerVars{vars_idx}}'
b
stats.t
stats.p



%% General linear model predicting number of games won


%% correlation

% vars_idx = [6 9 10 13:22 3 23];
vars_idx = [6 9 10 13:22 1 2 3 23];
vars_idx = [28 13 14 19 20 21 22 25 26 27];
vars_idx = [28 13 14 19 20 21 22 15 16 23 24];

GLM_xdata = DataMatrixPerPlayer(vars_idx,:)';

R_all = [];
P_all = [];
for i = 1:length(vars_idx)
    for j = 1:length(vars_idx)
        [R,P] = corr(GLM_xdata(:,i),GLM_xdata(:,j),'type','spearman');
        R_all(i,j) = R;
        P_all(i,j) = P;
    end
end


h = figure(9);
subplot(2,2,1);

pcheck = [];
for i = 2:length(vars_idx)
    pcheck = [pcheck P_all(i,1:i)];
end
Pfdr = fdr(pcheck,0.05);

imagesc(R_all(1:end,1:end));
hold on
for i = 1:length(vars_idx)
    for j = 1:length(vars_idx)
        if (P_all(i,j)<Pfdr)
            text(i,j,'*','HorizontalAlignment','center')
        end
    end
end
axis square
colorbar
set(gca,'ytick',1:length(vars_idx))
set(gca,'yticklabel',{DataMatrixPerPlayerVars{vars_idx}})

subplot(2,2,3);

imagesc(R_all(1:end,1:end));
hold on
for i = 1:length(vars_idx)
    for j = 1:length(vars_idx)
        if (P_all(i,j)<0.05)
            text(i,j,'*','HorizontalAlignment','center')
        end
    end
end
axis square
colorbar




%% correlation across trials


R_all = [];
P_all = [];
for i = 1:size(DataMatrixPerPlayerPerTrial,3)
    for j = 1:size(DataMatrixPerPlayerPerTrial,3)
        xdata = DataMatrixPerPlayerPerTrial(:,:,i);
        ydata = DataMatrixPerPlayerPerTrial(:,:,j);
        [R,P] = corrcoef(xdata(:),ydata(:));
        R_all(i,j) = R(2);
        P_all(i,j) = P(2);
    end
end

h = figure(9);
subplot(2,2,3);

pcheck = [];
for i = 2:size(DataMatrixPerPlayerPerTrial,3)
    pcheck = [pcheck P_all(i,1:i)];
end
Pfdr = fdr(pcheck,0.05);

imagesc(R_all(1:end,1:end));
hold on
for i = 1:size(DataMatrixPerPlayerPerTrial,3)
    for j = 1:size(DataMatrixPerPlayerPerTrial,3)
        if (P_all(i,j)<Pfdr)
            text(i,j,'*','HorizontalAlignment','center')
        end
    end
end
axis square
colorbar
set(gca,'ytick',1:size(DataMatrixPerPlayerPerTrial,3))
set(gca,'yticklabel',DataMatrixPerPlayerPerTrialVars)


%% GLM with smaller amount of variables

% vars_idx = [6 15 17 19 20 2 23];
% 
% GLM_xdata = DataMatrixPerPlayer(vars_idx,:)';
% for i = 1:length(vars_idx)
%     GLM_xdata(:,i) = (GLM_xdata(:,i)-min(GLM_xdata(:,i)))./max(GLM_xdata(:,i)-min(GLM_xdata(:,i)));
% end
% 
% GLM_ydata = DataMatrixPerPlayer(9,:)';
% % GLM_ydata = (GLM_ydata-min(GLM_ydata))./(GLM_ydata-min(GLM_ydata));
% [b,dev,stats]    = glmfit(GLM_xdata, GLM_ydata, 'normal');
% 
% DataMatrixPerPlayerVars{vars_idx(stats.p(2:end)<0.05)}
% {DataMatrixPerPlayerVars{vars_idx}}'
% b
% stats.t
% stats.p

%% factor analysis

h = figure(10);
[Lambda,Psi,T,stats2,F] = factoran(GLM_xdata,3);

biplot(Lambda,'LineWidth',3,'MarkerSize',20,'VarLabels',{DataMatrixPerPlayerVars{vars_idx}})

plot2svg('Figures4/FigureS4.svg',h);



%% GLM ON difference in score
% this is weird to do because the difference is already IN the sum score

% vars_idx = [6:13];
% 
% GLM_xdata = squeeze(nanmean(DataMatrixPerPlayerPerTrial(:,firstSubs,vars_idx)-DataMatrixPerPlayerPerTrial(:,secondSubs,vars_idx),1));
% 
% vars_idx = [6:14];
% 
% GLM_xdata(:,length(vars_idx)) = nanmean(mimicryScore); % add mimicry
% 
% for i = 1:length(vars_idx)
%     GLM_xdata(:,i) = (GLM_xdata(:,i)-min(GLM_xdata(:,i)))./max(GLM_xdata(:,i)-min(GLM_xdata(:,i)));
% end
% 
% GLM_ydata = nanmean(DataMatrixPerPlayerPerTrial(:,firstSubs,9)-DataMatrixPerPlayerPerTrial(:,secondSubs,9),1)';
% GLM_ydata = (GLM_ydata-min(GLM_ydata))./max(GLM_ydata-min(GLM_ydata));
% [b,dev,stats]    = glmfit(GLM_xdata, GLM_ydata, 'normal');
% 
% 
% DataMatrixPerPlayerPerTrialVars{vars_idx(stats.p(2:end)<0.05)}
% {DataMatrixPerPlayerPerTrialVars{vars_idx}}'
% b
% stats.t
% stats.p




%% check behaviors per winner per loser per trial
WinVect = zeros(30,2*length(Subjects{1}));
for s = 1:length(Subjects{1})
    for t = 1:30
        if ( DataMatrixPerPlayerPerTrial(t,firstSubs(s),1)>DataMatrixPerPlayerPerTrial(t,secondSubs(s),1) )
            WinVect(t,firstSubs(s)) = 1;
        elseif ( DataMatrixPerPlayerPerTrial(t,firstSubs(s),1)<DataMatrixPerPlayerPerTrial(t,secondSubs(s),1) )
            WinVect(t,secondSubs(s)) = 1;
        elseif ( DataMatrixPerPlayerPerTrial(t,firstSubs(s),1)==DataMatrixPerPlayerPerTrial(t,secondSubs(s),1) )
            WinVect(t,[firstSubs(s) secondSubs(s)]) = NaN;
        end
    end
end

figure(9999);
h = [];
for i = 1:size(DataMatrixPerPlayerPerTrial,3)
    subplot(5,4,i);
    
    tempData = DataMatrixPerPlayerPerTrial(:,:,i);
    % normalize
%     for s = 1:2*length(Subjects{1})
%         tempData(:,s) = tempData(:,s)-nanmedian(tempData(:,s));
%     end
   
    bar(1,nanmean(tempData(WinVect==1)),'w');
    hold on
    errorbar(1,nanmean(tempData(WinVect==1)),nanmean(tempData(WinVect==1)),'k');
    
    bar(2,nanmean(tempData(WinVect==0)),'w');
    hold on
    errorbar(2,nanmean(tempData(WinVect==0)),nanmean(tempData(WinVect==0)),'k');
    
    title(DataMatrixPerPlayerPerTrialVars{i});
    
    h(i) = ttest(tempData(WinVect==0),tempData(WinVect==1));
end


figure(99999);
subplot(2,2,1);
plot(DataMatrixPerPlayerPerTrial(:,firstSubs,6),DataMatrixPerPlayerPerTrial(:,secondSubs,1),'ro')

subplot(2,2,3);
plot(DataMatrixPerPlayer(15,firstSubs),DataMatrixPerPlayer(13,secondSubs),'ro')
subplot(2,2,4);
plot(DataMatrixPerPlayer(15,firstSubs),DataMatrixPerPlayer(28,secondSubs),'ro')


%%

%%%%%%%%%%%%% CREATE SAME PLOTS FOR MISSES!?





%% number of green and yellow targets hit as compared to misses

nHitPerTargetType = [];
for s = 1:length(Subjects{1})
    nHitPerTargetType(s,:) = sum([nTargetType(:,:,1,s); nTargetType(:,:,2,s)])./sum(CountNTargets(s,:));
end

nHitPerTargetTemp = sum(nHitPerTargetType(:,1:2)');
mean(nHitPerTargetTemp); % 88.4
std(nHitPerTargetTemp); % 5

save('SaveData/nHitPerTarget.mat','nHitPerTargetTemp'); % to compare with experiment 2


%% number of green and yellow targets hit as compared to other target types

nHitPerTargetType = [];
for s = 1:length(Subjects{1})
    nHitPerTargetType(s,:) = sum([nTargetType(:,:,1,s); nTargetType(:,:,2,s)]);
end
nHitPerTargetTypeTemp1 = sum(nHitPerTargetType(:,1:2)')./sum(nHitPerTargetType')
mean(nHitPerTargetTypeTemp1);
std(nHitPerTargetTypeTemp1);

nHitPerTargetType = [];
for s = 1:length(Subjects{1})
    for i = 1:2
        nHitPerTargetType(s+(i-1)*length(Subjects{1}),:) = sum(nTargetType(:,:,i,s));
    end
end

nHitPerTargetTypeTemp2 = sum(nHitPerTargetType(:,1:2)')./sum(nHitPerTargetType')
mean(nHitPerTargetTypeTemp2);
std(nHitPerTargetTypeTemp2);

save('SaveData/nHitPerTargetType.mat','nHitPerTargetTypeTemp1','nHitPerTargetTypeTemp2'); 



%% predict performance of opponent with RT and move distance of player
% per trial

Rpredict_all = [];
for s = 1:length(Subjects{1})
    Rpredict_all(s,1,1) = corr(DataMatrixPerPlayerPerTrial(:,firstSubs(s),4),DataMatrixPerPlayerPerTrial(:,secondSubs(s),16),'type','spearman');
    Rpredict_all(s,2,1) = corr(DataMatrixPerPlayerPerTrial(:,secondSubs(s),4),DataMatrixPerPlayerPerTrial(:,firstSubs(s),16),'type','spearman');
    Rpredict_all(s,3,1) = corr([DataMatrixPerPlayerPerTrial(:,firstSubs(s),4); DataMatrixPerPlayerPerTrial(:,secondSubs(s),4)],[DataMatrixPerPlayerPerTrial(:,secondSubs(s),16); DataMatrixPerPlayerPerTrial(:,firstSubs(s),16)],'type','spearman');
    Rpredict_all(s,4,1) = corr([DataMatrixPerPlayerPerTrial(:,firstSubs(s),4); DataMatrixPerPlayerPerTrial(:,secondSubs(s),4)],[DataMatrixPerPlayerPerTrial(:,firstSubs(s),16); DataMatrixPerPlayerPerTrial(:,secondSubs(s),16)],'type','spearman');
    
    Rpredict_all(s,1,2) = corr(DataMatrixPerPlayerPerTrial(:,firstSubs(s),4),DataMatrixPerPlayerPerTrial(:,secondSubs(s),14),'type','spearman');
    Rpredict_all(s,2,2) = corr(DataMatrixPerPlayerPerTrial(:,secondSubs(s),4),DataMatrixPerPlayerPerTrial(:,firstSubs(s),14),'type','spearman');
    Rpredict_all(s,3,2) = corr([DataMatrixPerPlayerPerTrial(:,firstSubs(s),4); DataMatrixPerPlayerPerTrial(:,secondSubs(s),4)],[DataMatrixPerPlayerPerTrial(:,secondSubs(s),14); DataMatrixPerPlayerPerTrial(:,firstSubs(s),14)],'type','spearman');
    Rpredict_all(s,4,2) = corr([DataMatrixPerPlayerPerTrial(:,firstSubs(s),4); DataMatrixPerPlayerPerTrial(:,secondSubs(s),4)],[DataMatrixPerPlayerPerTrial(:,firstSubs(s),14); DataMatrixPerPlayerPerTrial(:,secondSubs(s),14)],'type','spearman');
    
%     corr
%     DataMatrixPerPlayerPerTrial(:,firstSubs(s),4)  % nhits
%     DataMatrixPerPlayerPerTrial(:,firstSubs(s),14) % RT
%     DataMatrixPerPlayerPerTrial(:,firstSubs(s),16) % Move distance
end

nanmean(Rpredict_all)

hh = [];
pp = [];
for i = 1:4
    [hh(i,1),pp(i,1)] = ttest(Rpredict_all(:,i,1),0);
    [hh(i,2),pp(i,2)] = ttest(Rpredict_all(:,i,2),0);
end

%% predict performance of opponent with RT and move distance of player
% across all trials

selectPairs = 1:length(Subjects{1});

Rpredict_all2 = [];
Ppredict_all2 = [];
[Rpredict_all2(1,1),Ppredict_all2(1,1)] = corr(DataMatrixPerPlayer(13,firstSubs(selectPairs))',DataMatrixPerPlayer(15,secondSubs(selectPairs))','type','spearman');
[Rpredict_all2(2,1),Ppredict_all2(2,1)] = corr(DataMatrixPerPlayer(13,secondSubs(selectPairs))',DataMatrixPerPlayer(15,firstSubs(selectPairs))','type','spearman');
[Rpredict_all2(3,1),Ppredict_all2(3,1)] = corr([DataMatrixPerPlayer(13,firstSubs(selectPairs))'; DataMatrixPerPlayer(13,secondSubs(selectPairs))'],[DataMatrixPerPlayer(15,secondSubs(selectPairs))'; DataMatrixPerPlayer(15,firstSubs(selectPairs))'],'type','spearman');
[Rpredict_all2(4,1),Ppredict_all2(4,1)] = corr(DataMatrixPerPlayer(13,:)',DataMatrixPerPlayer(15,:)','type','spearman');

[Rpredict_all2(1,2),Ppredict_all2(1,2)] = corr(DataMatrixPerPlayer(13,firstSubs(selectPairs))',DataMatrixPerPlayer(23,secondSubs(selectPairs))','type','spearman');
[Rpredict_all2(2,2),Ppredict_all2(2,2)] = corr(DataMatrixPerPlayer(13,secondSubs(selectPairs))',DataMatrixPerPlayer(23,firstSubs(selectPairs))','type','spearman');
[Rpredict_all2(3,2),Ppredict_all2(3,2)] = corr([DataMatrixPerPlayer(13,firstSubs(selectPairs))'; DataMatrixPerPlayer(13,secondSubs(selectPairs))'],[DataMatrixPerPlayer(23,secondSubs(selectPairs))'; DataMatrixPerPlayer(23,firstSubs(selectPairs))'],'type','spearman');
[Rpredict_all2(4,2),Ppredict_all2(4,2)] = corr(DataMatrixPerPlayer(13,:)',DataMatrixPerPlayer(23,:)','type','spearman');

Rpredict_all2

save('SaveData/DataMatrixPerPlayer_exp1.mat','DataMatrixPerPlayer')

%%

corr(DataMatrixPerPlayer(13,:)',DataMatrixPerPlayer(23,:)','type','spearman')
corr(DataMatrixPerPlayer(13,:)',DataMatrixPerPlayer(15,:)','type','spearman')

colormapper = colormap('jet');
colormapper = colormapper(round(linspace(1,64,length(Subjects{1}))),:);
    
figure(999);
xdata = [];
ydata = [];
for s = 1:length(Subjects{1})
    xdata(s) = DataMatrixPerPlayer(15,firstSubs(s));
    ydata(s) = DataMatrixPerPlayer(13,firstSubs(s));
    plot(DataMatrixPerPlayer(15,firstSubs(s)),DataMatrixPerPlayer(13,firstSubs(s)),'ko','Color',colormapper(s,:));
    hold on
end
axis square
ylabel('Performance player 1');
xlabel('RT player 1');

figure(11999991);
xdata = [];
ydata = [];
for s = 1:length(Subjects{1})
    plot(DataMatrixPerPlayer(13,firstSubs(s)),DataMatrixPerPlayer(13,secondSubs(s)),'ko','Color',colormapper(s,:));
    hold on
end
axis square
ylabel('Player # hits');
xlabel('Opponent # hits');

[R,P] = corr(xdata',ydata','type','spearman');



%%
figure(1199999);

subplot(2,2,1);
xdata = [];
ydata = [];
for s = 1:length(Subjects{1})
    xdata(s) = mean([DataMatrixPerPlayer(15,firstSubs(s)) DataMatrixPerPlayer(15,secondSubs(s))]);
    ydata(s) = sum([DataMatrixPerPlayer(13,firstSubs(s)) DataMatrixPerPlayer(13,secondSubs(s))]);
    plot(mean([DataMatrixPerPlayer(15,firstSubs(s)) DataMatrixPerPlayer(15,secondSubs(s))]),sum([DataMatrixPerPlayer(13,firstSubs(s)) DataMatrixPerPlayer(13,secondSubs(s))]),'ko','Color',colormapper(s,:));
    hold on
end
axis square
ylabel('Sum of pairs # hits');
xlabel('Average of pairs Reaction Time [s]');

[R,P] = corr(xdata',ydata','type','spearman')

XLims = [0.45 0.75];
fitter = polyfit(mean([DataMatrixPerPlayer(15,firstSubs); DataMatrixPerPlayer(15,secondSubs)]),sum([DataMatrixPerPlayer(13,firstSubs); DataMatrixPerPlayer(13,secondSubs)]),1);
hold on
plot(XLims,polyval(fitter,XLims),'r')

[R,P] = corr(mean([DataMatrixPerPlayer(15,firstSubs); DataMatrixPerPlayer(15,secondSubs)])',sum([DataMatrixPerPlayer(13,firstSubs); DataMatrixPerPlayer(13,secondSubs)])','type','spearman')
R = num2str(R);
P = num2str(P);
text(.4,1900,R)
text(.4,1850,P)
ylim([1800 2400])

subplot(2,2,2);
xdata = [];
ydata = [];
for s = 1:length(Subjects{1})
    xdata(s) = mean([DataMatrixPerPlayer(23,firstSubs(s)) DataMatrixPerPlayer(23,secondSubs(s))]);
    ydata(s) = sum([DataMatrixPerPlayer(13,firstSubs(s)) DataMatrixPerPlayer(13,secondSubs(s))]);
    plot(mean([DataMatrixPerPlayer(23,firstSubs(s)) DataMatrixPerPlayer(23,secondSubs(s))]),sum([DataMatrixPerPlayer(13,firstSubs(s)) DataMatrixPerPlayer(13,secondSubs(s))]),'ko','Color',colormapper(s,:));
    hold on
end
axis square
ylabel('Sum of pairs # hits');
xlabel('Average of pairs Move Distance [s]');

[R,P] = corr(xdata',ydata','type','spearman')

XLims = [0 7];
fitter = polyfit(mean([DataMatrixPerPlayer(23,firstSubs); DataMatrixPerPlayer(23,secondSubs)]),sum([DataMatrixPerPlayer(13,firstSubs); DataMatrixPerPlayer(13,secondSubs)]),1);
hold on
plot(XLims,polyval(fitter,XLims),'r')
xlim([0 7])
ylim([1800 2400])

[R,P] = corr(mean([DataMatrixPerPlayer(23,firstSubs); DataMatrixPerPlayer(23,secondSubs)])',sum([DataMatrixPerPlayer(13,firstSubs); DataMatrixPerPlayer(13,secondSubs)])','type','spearman')
R = num2str(R);
P = num2str(P);
text(1,1900,R)
text(1,1850,P)

%%















figure(999999);
subplot(2,2,1);
for s = 1:length(Subjects{1})
    plot(DataMatrixPerPlayer(15,firstSubs(s)),DataMatrixPerPlayer(13,secondSubs(s)),'ko','Color',colormapper(s,:));
%     text(DataMatrixPerPlayer(15,firstSubs(s)),DataMatrixPerPlayer(13,secondSubs(s)),num2str(s));
    
    hold on
    plot(DataMatrixPerPlayer(15,secondSubs(s)),DataMatrixPerPlayer(13,firstSubs(s)),'ko','Color',colormapper(s,:));
    hold on
    text(DataMatrixPerPlayer(15,secondSubs(s)),DataMatrixPerPlayer(13,firstSubs(s)),num2str(s));
    
%     line([DataMatrixPerPlayer(15,firstSubs(s)) DataMatrixPerPlayer(15,secondSubs(s))],[DataMatrixPerPlayer(13,secondSubs(s)) DataMatrixPerPlayer(13,firstSubs(s))],'Color',colormapper(s,:));
end
ylabel('Opponents # hits');
xlabel('Players Reaction Time [s]');
axis square

[R,P] = corr([DataMatrixPerPlayer(15,firstSubs) DataMatrixPerPlayer(15,secondSubs)]',[DataMatrixPerPlayer(13,secondSubs) DataMatrixPerPlayer(13,firstSubs)]','type','spearman')
R = num2str(R);
P = num2str(P);
text(0.4,700,R)
text(0.4,600,P)

XLims = [.4 .8];
fitter = polyfit([DataMatrixPerPlayer(15,firstSubs) DataMatrixPerPlayer(15,secondSubs)],[DataMatrixPerPlayer(13,secondSubs) DataMatrixPerPlayer(13,firstSubs)],1);
hold on
plot(XLims,polyval(fitter,XLims),'r')
xlim([0.4 .8])
ylim([500 1500])




subplot(2,2,2);

for s = 1:length(Subjects{1})
    plot(DataMatrixPerPlayer(23,firstSubs(s)),DataMatrixPerPlayer(13,secondSubs(s)),'ko','Color',colormapper(s,:));
%     text(DataMatrixPerPlayer(15,firstSubs(s)),DataMatrixPerPlayer(13,secondSubs(s)),num2str(s));
    
    hold on
    plot(DataMatrixPerPlayer(23,secondSubs(s)),DataMatrixPerPlayer(13,firstSubs(s)),'ko','Color',colormapper(s,:));
    hold on
    text(DataMatrixPerPlayer(15,secondSubs(s)),DataMatrixPerPlayer(13,firstSubs(s)),num2str(s));
    
%     line([DataMatrixPerPlayer(15,firstSubs(s)) DataMatrixPerPlayer(15,secondSubs(s))],[DataMatrixPerPlayer(13,secondSubs(s)) DataMatrixPerPlayer(13,firstSubs(s))],'Color',colormapper(s,:));
end
ylabel('Opponents # hits');
xlabel('Players Move Distance [mm]');
axis square

XLims = [0 7];
fitter = polyfit([DataMatrixPerPlayer(23,firstSubs) DataMatrixPerPlayer(23,secondSubs)],[DataMatrixPerPlayer(13,secondSubs) DataMatrixPerPlayer(13,firstSubs)],1);
hold on
plot(XLims,polyval(fitter,XLims),'r')
xlim([0 7])
ylim([500 1500])

[R,P] = corr([DataMatrixPerPlayer(23,firstSubs) DataMatrixPerPlayer(23,secondSubs)]',[DataMatrixPerPlayer(13,secondSubs) DataMatrixPerPlayer(13,firstSubs)]','type','spearman')
R = num2str(R);
P = num2str(P);
text(1,700,R)
text(1,600,P)

figure(9999);
xdata = [];
ydata = [];
for s = 1:length(Subjects{1})
    if ( SubjectsWinExpVect(s) == 1 )
        subplot(2,2,1);
        
        axis square
        xlim([.4 .8])
        ylim([600 1400])
    else
        subplot(2,2,2);
        
        axis square
        xlim([.4 .8])
        ylim([600 1400])
    end
    plot(DataMatrixPerPlayer(15,firstSubs(s)),DataMatrixPerPlayer(13,firstSubs(s)),'ko','Color',colormapper(s,:));
    hold on
    if ( SubjectsWinExpVect(s) == 2 )
        subplot(2,2,1);
        
        axis square
        xlim([.4 .8])
        ylim([600 1400])
    else
        subplot(2,2,2);
        
        axis square
        xlim([.4 .8])
        ylim([600 1400])
    end
    plot(DataMatrixPerPlayer(15,secondSubs(s)),DataMatrixPerPlayer(13,secondSubs(s)),'ko','Color',colormapper(s,:));
    hold on
end
ylabel('Performance');
xlabel('RT');

figure(19999);
xdata = [];
ydata = [];
for s = 1:length(Subjects{1})
    if ( SubjectsWinExpVect(s) == 1 )
        subplot(2,2,1);
        
        axis square
        xlim([.4 .8])
        ylim([600 1400])
    else
        subplot(2,2,2);
        
        axis square
        xlim([.4 .8])
        ylim([600 1400])
    end
    plot(DataMatrixPerPlayer(15,firstSubs(s)),DataMatrixPerPlayer(13,secondSubs(s)),'ko','Color',colormapper(s,:));
    hold on
    if ( SubjectsWinExpVect(s) == 2 )
        subplot(2,2,1);
        
        axis square
        xlim([.4 .8])
        ylim([600 1400])
    else
        subplot(2,2,2);
        
        axis square
        xlim([.4 .8])
        ylim([600 1400])
    end
    plot(DataMatrixPerPlayer(15,secondSubs(s)),DataMatrixPerPlayer(13,firstSubs(s)),'ko','Color',colormapper(s,:));
    hold on
end
ylabel('Player Performance');
xlabel('Opponent RT');

XLims = [0.45 0.75];
fitter = polyfit(DataMatrixPerPlayer(15,:),DataMatrixPerPlayer(13,:),1);
hold on
plot(XLims,polyval(fitter,XLims),'r')



[R,P] = corr([DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==1))]',[DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==1))]','type','spearman')





vectorSubs = zeros(1,34);
vectorSubs(firstSubs) == 1;
vectorSubs(secondSubs) == 2;

% RT Win --> Hits Win
[R,P] = corr([DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==2))]',[DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==2))]','type','spearman','tail','left')

% RT Lost --> Hits Lost
[R,P] = corr([DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==1))]',[DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==1))]','type','spearman','tail','left')

% RT Win --> Hits Lost
[R,P] = corr([DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==2))]',[DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==2))]','type','spearman','tail','left')
% RT Lost --> Hits Win
[R,P] = corr([DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==1))]',[DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==1))]','type','spearman','tail','left')

% % RT win+lost --> Hits lost+win
% [R,P] = corr([DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==1))]',[DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==1))]','type','spearman')


% RT win --> RT Lost
[R,P] = corr([DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==2))]',[DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==2))]','type','spearman','tail','right')

% Hits win --> Hits Lost
[R,P] = corr([DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==2))]',[DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==2))]','type','spearman','tail','left')

% partial corr RT Win --> Hits Win, control: RT lost
[R,P] = partialcorr([DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==2))]',[DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==2))]',[DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==1))]','type','spearman','tail','left')
% partial corr RT Lost --> Hits Lost, control: RT win
[R,P] = partialcorr([DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==1))]',[DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==1))]',[DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==2))]','type','spearman','tail','left')

% partial corr RT Lost --> Hits Win, control: RT Win
[R,P] = partialcorr([DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==1))]',[DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==1))]',[DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==2))]','type','spearman','tail','left')
% partial corr RT Win --> Hits Lost, control: RT Lost
[R,P] = partialcorr([DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==2))]',[DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==2))]',[DataMatrixPerPlayer(15,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==1))]','type','spearman','tail','left')


% MD Win --> Hits Win
[R,P] = corr([DataMatrixPerPlayer(23,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(23,secondSubs(SubjectsWinExpVect==2))]',[DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==2))]','type','spearman','tail','right')

% MD Lost --> Hits Lost
[R,P] = corr([DataMatrixPerPlayer(23,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(23,secondSubs(SubjectsWinExpVect==1))]',[DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==1))]','type','spearman','tail','right')

% MD Win --> Hits Lost
[R,P] = corr([DataMatrixPerPlayer(23,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(23,secondSubs(SubjectsWinExpVect==2))]',[DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==2))]','type','spearman','tail','right')
% MD Lost --> Hits Win
[R,P] = corr([DataMatrixPerPlayer(23,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(23,secondSubs(SubjectsWinExpVect==1))]',[DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==1))]','type','spearman','tail','right')

% % MD win+lost --> Hits lost+win
% [R,P] = corr([DataMatrixPerPlayer(23,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(23,secondSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(23,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(23,secondSubs(SubjectsWinExpVect==1))]',[DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==1))]','type','spearman')




% MD win --> MD Lost
[R,P] = corr([DataMatrixPerPlayer(23,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(23,secondSubs(SubjectsWinExpVect==2))]',[DataMatrixPerPlayer(23,secondSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(23,firstSubs(SubjectsWinExpVect==2))]','type','spearman','tail','right')

% Hits win --> Hits Lost
[R,P] = corr([DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==2))]',[DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==2))]','type','spearman','tail','left')


% partial corr MD Win --> Hits Win, control: MD lost
[R,P] = partialcorr([DataMatrixPerPlayer(23,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(23,secondSubs(SubjectsWinExpVect==2))]',[DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==2))]',[DataMatrixPerPlayer(23,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(23,secondSubs(SubjectsWinExpVect==1))]','type','spearman','tail','right')
% partial corr MD Lost --> Hits Lost, control: MD win
[R,P] = partialcorr([DataMatrixPerPlayer(23,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(23,secondSubs(SubjectsWinExpVect==1))]',[DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==1))]',[DataMatrixPerPlayer(23,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(23,secondSubs(SubjectsWinExpVect==2))]','type','spearman','tail','right')

% partial corr MD Lost --> Hits Win, control: MD Win
[R,P] = partialcorr([DataMatrixPerPlayer(23,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(23,secondSubs(SubjectsWinExpVect==1))]',[DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==1))]',[DataMatrixPerPlayer(23,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(23,secondSubs(SubjectsWinExpVect==2))]','type','spearman','tail','right')
% partial corr MD Win --> Hits Lost, control: MD Lost
[R,P] = partialcorr([DataMatrixPerPlayer(23,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(23,secondSubs(SubjectsWinExpVect==2))]',[DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==2))]',[DataMatrixPerPlayer(23,firstSubs(SubjectsWinExpVect==2)) DataMatrixPerPlayer(23,secondSubs(SubjectsWinExpVect==1))]','type','spearman','tail','right')


[R,P] = corr(DataMatrixPerPlayer(13,firstSubs)',DataMatrixPerPlayer(13,secondSubs)','type','spearman')







figure()
subplot(2,2,1);
plot(DataMatrixPerPlayer(13,firstSubs)',DataMatrixPerPlayer(13,secondSubs)','ro')
hold on
plot([DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==0))]',[DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==0))]','go')

xlim([600 1600])
ylim([600 1600])


subplot(2,2,2);
plot([DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==2))]',[DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==1)) DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==2))]','ro')
hold on
plot([DataMatrixPerPlayer(13,firstSubs(SubjectsWinExpVect==0))]',[DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==0))]','go')

xlim([600 1600])
ylim([600 1600])

[R,P] = corr(DataMatrixPerPlayer(15,secondSubs(SubjectsWinExpVect==1|SubjectsWinExpVect==0))',DataMatrixPerPlayer(13,secondSubs(SubjectsWinExpVect==1|SubjectsWinExpVect==0))','type','spearman');


figure();
for s = 1:length(Subjects)
    subplot(4,5,s)
    plot(DataMatrixPerPlayerPerTrial(:,firstSubs(s),15),DataMatrixPerPlayerPerTrial(:,secondSubs(s),13),'ko','Color',colormapper(s,:));
    hold on
    XLims = [0.2 1];%[min(DataMatrixPerPlayerPerTrial(:,firstSubs(s),3)) max(DataMatrixPerPlayerPerTrial(:,firstSubs(s),3))];
    fitter = polyfit(DataMatrixPerPlayerPerTrial(:,firstSubs(s),15),DataMatrixPerPlayerPerTrial(:,secondSubs(s),13),1);
    plot(XLims,polyval(fitter,XLims),'r')
%     xlim([0.35 .95])
%     ylim([20 60])
end



%%


h = figure(4);
countPlots = 0;
colormapper = colormap('jet');
colormapper = colormapper(round(linspace(1,64,length(Subjects{1}))),:);
    
ylims = [0.40 .55 .70 0.85; 0 3 6 9];
for i = [15 23] %1:size(DataMatrixPerPlayer,1)
    countPlots = countPlots+1;
    subplot(2,2,countPlots)
    for s = 1:length(Subjects{1})
        plot(DataMatrixPerPlayer(i,firstSubs(s)),DataMatrixPerPlayer(i,secondSubs(s)),'ko','Color',colormapper(s,:));
        hold on
%         text(DataMatrixPerPlayer(i,firstSubs(s)),DataMatrixPerPlayer(i,secondSubs(s)),num2str(s));
        
    end
%     ylabel(DataMatrixPerPlayerVars{i});
    axis square
    vector = isfinite(DataMatrixPerPlayer(i,firstSubs)') & isfinite(DataMatrixPerPlayer(i,secondSubs)');
    [R,P] = corr(DataMatrixPerPlayer(i,firstSubs(vector))',DataMatrixPerPlayer(i,secondSubs(vector))','type','spearman');
    R = num2str(R);
    P = num2str(P);
    if ( length(P) < 2 )
        P = '0.000';
    end
    if ( length(R) < 5 )
        R = [R '0'];
    end
    text(mean(DataMatrixPerPlayer(i,firstSubs(vector))),mean(DataMatrixPerPlayer(i,secondSubs(vector))),['R=' R(1:5)]);
    text(mean(DataMatrixPerPlayer(i,firstSubs(vector))),mean(DataMatrixPerPlayer(i,secondSubs(vector)))-std(DataMatrixPerPlayer(i,secondSubs(vector)))*1,['P=' P(1:5)]);
    
    title(DataMatrixPerPlayerVars{i});
%     xlabel('Player 1');
%     ylabel('Player 2');

    Po = polyfit(DataMatrixPerPlayer(i,firstSubs(vector)),DataMatrixPerPlayer(i,secondSubs(vector)),1);
    line(ylims(countPlots,[1 4]),ylims(countPlots,[1 4]),'Color','k')
    line(ylims(countPlots,[1 4]),polyval(Po,ylims(countPlots,[1 4])),'Color','r','LineWidth',1)
    
    xlim(ylims(countPlots,[1 4]));
    ylim(ylims(countPlots,[1 4]));
    set(gca,'xtick',ylims(countPlots,:));
    set(gca,'ytick',ylims(countPlots,:));
end


%% difference RT and move distance player miss and opponent hit

RTmissdiff1 = [];
RTmissdiff2 = [];
for s = 1:length(Subjects{1})
    rtTemp = rtHitMiss(:,:,1,s)-rtHit(:,:,2,s);
    RTmissdiff1(s) = nanmedian(rtTemp(:));
    rtTemp = rtHitMiss(:,:,2,s)-rtHit(:,:,1,s);
    RTmissdiff2(s) = nanmedian(rtTemp(:));
end

[nanmean([RTmissdiff1 RTmissdiff2]) nanstd([RTmissdiff1 RTmissdiff2])]


MDmissdiff1 = [];
MDmissdiff2 = [];
for s = 1:length(Subjects{1})
    mdTemp = HitEucDistFromMoveOnsetMiss(:,:,1,s)-HitEucDistFromMoveOnset(:,:,2,s);
    MDmissdiff1(s) = nanmedian(mdTemp(:));
    mdTemp = HitEucDistFromMoveOnsetMiss(:,:,2,s)-HitEucDistFromMoveOnset(:,:,1,s);
    MDmissdiff2(s) = nanmedian(mdTemp(:));
end

[nanmean([MDmissdiff1 MDmissdiff2]) nanstd([MDmissdiff1 MDmissdiff2])]



countmissperc = [];
for s = 1:length(Subjects{1})
    countmissperc(s) = (sum(sum(isfinite(rtHitMiss(:,:,1,s))))+sum(sum(isfinite(rtHitMiss(:,:,2,s)))))/(sum(sum(isfinite(rtHit(:,:,1,s))))+sum(sum(isfinite(rtHit(:,:,2,s)))));
end

[mean(countmissperc*100) std(countmissperc*100)]


figure();
for s = 1:length(Subjects{1})
    xdata(s) = sum(CountNWrongTargetsPerPlayer(s,:,1));
    ydata(s) = sum(CountNWrongTargetsPerPlayer(s,:,2));
    plot(sum(CountNWrongTargetsPerPlayer(s,:,1)),sum(CountNWrongTargetsPerPlayer(s,:,2)),'ro')
    hold on
end
axis square
ylim([0 300])
xlim([0 300])
xlabel('# Misses Player 1');
ylabel('# Misses Player 2');

[R,P] = corr(xdata',ydata','type','Spearman')
% [R,P] = corr(xdata',ydata','type','Pearson')

vect = xdata<200;
[R,P] = corr(xdata(vect)',ydata(vect)','type','Spearman')
% [R,P] = corr(xdata(vect)',ydata(vect)','type','Pearson')


figure();
for s = 1:length(Subjects{1})
    plot(sum(CountNTargetsPerPlayer(s,:,1)),sum(CountNTargetsPerPlayer(s,:,2)),'ro')
    hold on
end
