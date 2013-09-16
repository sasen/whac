%% INPUTS TO THIS SCRIPT
CreateHitMaps       = 0;
Subjects{1}         = {'35','94s','233','eli','jkc','m7r','de3'};
Subjects{2}         = {'sasen','eli','ss5','3u1','sasen','ss','789'};
screenSize          = [35 46];  %%% SS: need to fix? (in cm)
zPixel              = 0.0177; % size   %%% SS: need to fix?
RecHz               = 200; % 1 sec in Trackerframes; 240
tZero = RecHz + 1; % TempData Index for t=0; tZero
t100ms = round(RecHz/10); % 100ms in Trackerframes; 24 
t200ms = t100ms * 2;  % 200ms in Trackerframes; 48

% for preallocating matrices
nTrials = 39;
TrlLen = 30; % in s
nOnscreen = 8; % max moles onscreen at once
maxHit = TrlLen * nOnscreen; % max # hits: nOnscreen hits/s obv impossible
nGames = length(Subjects{1});
%---------------
%%
GaborRad            = 50;
Gabor               = repmat(normpdf(-1*GaborRad:1:GaborRad,0,2*sqrt(GaborRad)),length(-1*GaborRad:1:GaborRad),1);
Gabor               = Gabor-min(Gabor(:));
Gabor               = (Gabor)./max(Gabor(:))*255;
Gabor               = Gabor.*Gabor';

Scores                  = NaN(2,nTrials,nGames);
ScoresWinExp            = NaN(2,nTrials,nGames);
MeanScoreVsWinExpVect   = NaN(1,nGames);
HitFrequency            = NaN(2,nTrials,nGames);
HitFrequency2            = NaN(2,nTrials,nGames);
HitFrequencyWinExp      = NaN(2,nTrials,nGames);

HitEucDistFromStart        = NaN(nTrials,maxHit,2,nGames);
HitEucDistFromStartWinExp  = NaN(nTrials,maxHit,2,nGames);
HitEucDistFromMoveOnset    = NaN(nTrials,maxHit,2,nGames);
HitEucDistFromMoveOnsetMiss= NaN(nTrials,maxHit,2,nGames);

HitVerDistFromStart        = NaN(nTrials,maxHit,2,nGames);
HitVerDistFromStartWinExp  = NaN(nTrials,maxHit,2,nGames);

HitHorDistFromStart        = NaN(nTrials,maxHit,2,nGames);
HitHorDistFromStartWinExp  = NaN(nTrials,maxHit,2,nGames);

HitDist                 = NaN(nTrials,maxHit,2,nGames);
HitDistWinExp           = NaN(nTrials,maxHit,2,nGames);

HitWidth                = NaN(nTrials,maxHit,2,nGames);
HitWidthWinExp          = NaN(nTrials,maxHit,2,nGames);

HitHeight               = NaN(nTrials,maxHit,2,nGames);

HitTrajectStd           = NaN(nTrials,maxHit,2,nGames);
HitTrajectStdWinExp     = NaN(nTrials,maxHit,2,nGames);

TargetType              = NaN(nTrials,maxHit,2,nGames);
TargetTypeWinExp        = NaN(nTrials,maxHit,2,nGames);

nTargetType             = zeros(nTrials,6,2,nGames);

rtHitCrossCorr          = NaN(nTrials,521,nGames);

rtHit                   = NaN(nTrials,maxHit,2,nGames);
rtHitMiss               = NaN(nTrials,maxHit,2,nGames); % reaction time of players that hit target later than the opponent

DecisionTime            = NaN(nTrials,maxHit,2,nGames);
MoveTime                = NaN(nTrials,maxHit,2,nGames);

locListX = [];
locListY = [];

if ( CreateHitMaps == 1 )
    HitMaps                 = zeros(768+GaborRad+2,1024+GaborRad+2,2,nGames);
    HitMaps1_10             = zeros(768+GaborRad+2,1024+GaborRad+2,2,nGames);
    HitMaps11_20             = zeros(768+GaborRad+2,1024+GaborRad+2,2,nGames);
    HitMaps21_30             = zeros(768+GaborRad+2,1024+GaborRad+2,2,nGames);
elseif ( CreateHitMaps == 2 )
    HitMapsFromStart        = zeros(2*768+2*GaborRad+2,2*1024+2*GaborRad+2,2,nGames);
end

MeanTrackPos              = NaN(nTrials,6,2,nGames); % first three is mean, other three is std
MeanTrackPosWinExp        = NaN(nTrials,6,2,nGames);

for s = 1:nGames
    disp(['Subject #' num2str(s) ' of ' num2str(nGames)])
    %         disp(SwitchedCondition)
    
    for TrlNum = 1:nTrials
        MatData = LoadGame(Subjects{1}{s},Subjects{2}{s},1,TrlNum);
        TrialIncludedVect = (MatData.TrialList/1000)<MatData.TrialLength; % to speed the code, remove data of targets that were not present because trial was over
        
        % check for variance in X and Y across pairs
        %              MoleTypeList(TrialIncludedVect)
        locListX(TrlNum,s) = nanmean(MatData.LocationListX(TrialIncludedVect));
        locListY(TrlNum,s) = nanmean(MatData.LocationListY(TrialIncludedVect));
        
        
        % check scores
        Scores(1,TrlNum,s) = MatData.ScorePlayers(1,TrlNum);
        Scores(2,TrlNum,s) = MatData.ScorePlayers(2,TrlNum);
        p1 = 1;
        p2 = 2;
        pall = [1 2];
        pswitch = 1;
        
        % hit frequency
        for p = 1:2
            Vect = MatData.HitList_p==p & TrialIncludedVect==1 & MatData.MoleTypeList<3;
            HitFrequency(pall(p),TrlNum,s) = sum(Vect)/sum(TrialIncludedVect & MatData.MoleTypeList<3);
            
            Vect = MatData.HitList_p==p & TrialIncludedVect==1 & MatData.MoleTypeList>2;
            HitFrequency2(pall(p),TrlNum,s) = sum(Vect)/sum(TrialIncludedVect & MatData.MoleTypeList>2);
            
            %                 Vect = MatData.HitList_p==p & TrialIncludedVect==1 & MatData.MoleTypeList>2;
            %                 wrongTarget(pall(p),TrlNum,s) = sum(Vect)/sum(TrialIncludedVect & MatData.MoleTypeList<3);
            %
            %                 wrongTargetSum(pall(p),TrlNum,s) = sum(Vect)/sum(TrialIncludedVect & MatData.MoleTypeList<3);
            
        end
        
        
        % convert z height to pixel  %%% SS: need to fix?
        zMax = MatData.maxZ;
%         MatData.TrackList{1}(3,:) = (MatData.TrackList{1}(3,:)-zMax+0.5)/zPixel; % extra 0.5 addition to get around average of table height (average z = 9.5, hit z = 10)
%         MatData.TrackList{2}(3,:) = (MatData.TrackList{2}(3,:)-zMax+0.5)/zPixel; % extra 0.5 addition to get around average of table height (average z = 9.5, hit z = 10)
        
        % correct for Z differences across players (one side was always
        % higher than the other side)
        
        
        CountNTargetsTemp = MatData.MoleTypeList;
        CountNTargetsTemp(MatData.TrialList>40000) = NaN;
        CountNTargets(s,TrlNum) = sum(CountNTargetsTemp(:)==1|CountNTargetsTemp(:)==2);
        
        CountNWrongTargets(s,TrlNum) = sum(CountNTargetsTemp(:)>2);
        
        for p = 1:2
            CountNTargetsPerPlayer(s,TrlNum,p) = sum(CountNTargetsTemp(:)<3 & MatData.HitList_p(:)==p);
            CountNWrongTargetsPerPlayer(s,TrlNum,p) = sum(CountNTargetsTemp(:)>2 & MatData.HitList_p(:)==p);
        end
        
        rtHitAll = cell(1,2);
        % hit heat map
        for p = 1:2
            rtHitAll{p} = NaN(1,length(MatData.TrackList{p}));
            if ( MatData.SwitchSides == 1 ) % switched sides
                if ( pswitch == 1 )
                    MeanTrackPos(TrlNum,1,pall(p),s) = 1024-nanmean(MatData.TrackList{p}(1,:));
                    MeanTrackPos(TrlNum,2,pall(p),s) = 768-nanmean(MatData.TrackList{p}(2,:));
                    MeanTrackPos(TrlNum,3,pall(p),s) = nanmean(MatData.TrackList{p}(3,:));
                else
                    MeanTrackPos(TrlNum,1,pall(p),s) = nanmean(MatData.TrackList{p}(1,:));
                    MeanTrackPos(TrlNum,2,pall(p),s) = nanmean(MatData.TrackList{p}(2,:));
                    MeanTrackPos(TrlNum,3,pall(p),s) = nanmean(MatData.TrackList{p}(3,:));
                end
            else
                if ( pswitch == -1 )
                    MeanTrackPos(TrlNum,1,pall(p),s) = 1024-nanmean(MatData.TrackList{p}(1,:));
                    MeanTrackPos(TrlNum,2,pall(p),s) = 768-nanmean(MatData.TrackList{p}(2,:));
                    MeanTrackPos(TrlNum,3,pall(p),s) = nanmean(MatData.TrackList{p}(3,:));
                else
                    MeanTrackPos(TrlNum,1,pall(p),s) = nanmean(MatData.TrackList{p}(1,:));
                    MeanTrackPos(TrlNum,2,pall(p),s) = nanmean(MatData.TrackList{p}(2,:));
                    MeanTrackPos(TrlNum,3,pall(p),s) = nanmean(MatData.TrackList{p}(3,:));
                end
            end
            
            MeanTrackPos(TrlNum,4,pall(p),s) = nanstd(MatData.TrackList{p}(1,:));
            MeanTrackPos(TrlNum,5,pall(p),s) = nanstd(MatData.TrackList{p}(2,:));
            MeanTrackPos(TrlNum,6,pall(p),s) = nanstd(MatData.TrackList{p}(3,:));
            
            %% go through all of this player's successful hits
            countHits = 0;
            pH = p;  % player who hit
            pM = mod(p,2)+1; % other player (who may have missed)
            for t = find(MatData.HitList_p==p)'
                countHits = countHits+1;
                
                % target onset
                %                    tOnset = round(9.6*(MatData.TrialList(t)/MatData.TrialLength));
                tOnset = Secs2Track(MatData.TrialList(t)/1000,MatData.TrackList{3});
                % MatData.mole{1}(:,find(MatData.mole{1}(1,:) == t))
                
                if ( tOnset < tZero )  % tZero is one second in trackerframes
                    tAhead = tOnset + (2*RecHz);  % 2s into the future
                    TempData        = [NaN(3,tZero-tOnset) MatData.TrackList{pH}(:,1:tAhead)];
                    TempDataMiss    = [NaN(3,tZero-tOnset) MatData.TrackList{pM}(:,1:tAhead)];
                else
                    tAhead = min(tOnset+(2*RecHz),length(MatData.TrackList{3}));
                    TempData        = MatData.TrackList{pH}(:,tOnset-RecHz:tAhead);
                    TempDataMiss    = MatData.TrackList{pM}(:,tOnset-RecHz:tAhead);
                end
                                
                % target hit moment
                HitMoment       = find(TempData(3,tZero:end) < zMax & TempData(1,tZero:end) > MatData.LocationListX(t)-MatData.HitSize/2 & TempData(1,tZero:end) < MatData.LocationListX(t)+MatData.HitSize/2 & TempData(2,tZero:end) > MatData.LocationListY(t)-MatData.HitSize/2 & TempData(2,tZero:end) < MatData.LocationListY(t)+MatData.HitSize/2,1,'first');
                HitMomentMiss   = find(TempDataMiss(3,tZero:end) < zMax & TempDataMiss(1,tZero:end) > MatData.LocationListX(t)-MatData.HitSize/2 & TempDataMiss(1,tZero:end) < MatData.LocationListX(t)+MatData.HitSize/2 & TempDataMiss(2,tZero:end) > MatData.LocationListY(t)-MatData.HitSize/2 & TempDataMiss(2,tZero:end) < MatData.LocationListY(t)+MatData.HitSize/2,1,'first');
                
                if ( HitMoment > (2*t100ms) ) % minimum reaction time of 200ms (faster is impossible)-> measured at 240hz per second
                    for i = 1:3
                        idxFinite                           = find(isfinite(TempData(i,:)));
                        pI                                  = nan(1,length(TempData(i,:)));
                        pI(min(idxFinite):max(idxFinite))   = interp1(idxFinite,TempData(i,idxFinite),min(idxFinite):max(idxFinite),'cubic');
                        TempData(i,:) = pI;
                    end
                    
                    minMoveDelay = t100ms;
                    LastPositive = find(diff(TempData(3,tZero:tZero+HitMoment-minMoveDelay))>0 & TempData(3,tZero+1:tZero+HitMoment-minMoveDelay)>zMax,1,'last');
                    LastPositiveMiss = find(diff(TempDataMiss(3,tZero:tZero+HitMomentMiss-minMoveDelay))>0 & TempDataMiss(3,tZero+1:tZero+HitMomentMiss-minMoveDelay)>zMax,1,'last');
                    
                    if ( LastPositive ) % failure of data collection
                        moveOnset = LastPositive+find(diff(TempData(3,tZero+LastPositive:tZero+HitMoment))<0,1,'first');
                        moveOnsetMiss = LastPositiveMiss+find(diff(TempDataMiss(3,tZero+LastPositiveMiss:tZero+HitMomentMiss))<0,1,'first');
                        
%                         h = figure();
%                         subplot(2,1,1), plot(TempData(3,tZero:tZero+HitMoment),'r')
%                         hold on
%                         plot(moveOnset,TempData(3,tZero+moveOnset),'go')
%                         title([MatData.ppname ' ' num2str(countHits) ' (Zpos 1s before HitMoment)'])
%                         mvXYZ = TempData(:,tZero+moveOnset);
%                         xlabel(num2str(mvXYZ));
%                         subplot(2,1,2), plot(diff(TempData(3,tZero:tZero+HitMoment)),'r')
%                         hold on
%                         line([1 HitMoment],[-2 -2]);
%                         title('Zvel 1s before HitMoment')
%                         drawnow;
%                         
%                         figure();
%                         subplot(2,1,1)
%                         plot((-240:size(TempData,2)-tZero).*(1/240),TempData(3,:)*zPixel)
%                         hold on
%                         line([0 .625 1.25],[-2 6 -2])
%                         line([0 .625 1.25]-242*(1/240),[-2 6 -2])
%                         title([MatData.ppname ' ' num2str(countHits) ' Zpos vs time'])
%                         xlim([-.5 1.5]);
%                         
%                         subplot(2,1,2)
%                         plot((-240:size(TempData,2)-242).*(1/240),abs(diff(TempData(3,:)*zPixel)))
%                         xlim([-.5 1.5]);
%                         hold on
%                         title('Zspeed vs time')
%                         line([-.5 1.5],[2 2]*zPixel)
%                         drawnow;
%                         WaitSecs(0.5);
%                         WaitForKeyPress({'SPACE'},[]);
%                         close all
                        
                        if ( moveOnset ) % there is no moveOnset if the player is already near the target (but just missed it by a couple pixels and then just moves over the screen towards the target)
ReachStartIdx(TrlNum,t,pall(pH),s) = tOnset + moveOnset;
ReachEndIdx(TrlNum,t,pall(pH),s)   = tOnset + HitMoment;
                            DecisionTime(TrlNum,countHits,pall(pH),s) = moveOnset*(1/RecHz);
                            MoveTime(TrlNum,countHits,pall(pH),s) = (HitMoment-moveOnset)*(1/RecHz);
                            
                            %HitTrajectStd(TrlNum,countHits,pall(p),s)   = sum(sqrt((TempData(1,tZero:tZero+HitMoment-1)-linspace(TempData(1,tZero),TempData(1,tZero+HitMoment),HitMoment)).^2+(TempData(2,tZero:tZero+HitMoment-1)-linspace(TempData(2,tZero),TempData(2,tZero+HitMoment),HitMoment)).^2))/HitMoment;
                            HitTrajectStd(TrlNum,countHits,pall(pH),s)   = sum(sqrt((TempData(1,tZero+moveOnset:tZero+HitMoment-1)-linspace(TempData(1,tZero+moveOnset),TempData(1,tZero+HitMoment),HitMoment-moveOnset)).^2+(TempData(2,tZero+moveOnset:tZero+HitMoment-1)-linspace(TempData(2,tZero+moveOnset),TempData(2,tZero+HitMoment),HitMoment-moveOnset)).^2))/(HitMoment-moveOnset);
                            
                            XTemp2 = MatData.LocationListX(t)-nanmean(TempData(1,tZero+moveOnset-5:tZero+moveOnset+5));
                            YTemp2 = MatData.LocationListY(t)-nanmean(TempData(2,tZero+moveOnset-5:tZero+moveOnset+5));
                            ZTemp2 = nanmean(TempData(3,tZero+moveOnset-5:tZero+moveOnset+5));
                            
                            if ( isfinite(XTemp2) & isfinite(YTemp2) & isfinite(ZTemp2) )
                                XTemp2 = (XTemp2/1024)*screenSize(2);
                                YTemp2 = (YTemp2/768)*screenSize(1);
                                ZTemp2 = ZTemp2*zPixel; %% SS: need to fix?
                                
                                HitEucDistFromMoveOnset(TrlNum,countHits,pall(pH),s) = sqrt((XTemp2^2)+(YTemp2^2)+(ZTemp2^2));
                                
                                
                            end
                            
                        else
                            HitMoment = NaN;
                        end
                        
                        if ( moveOnsetMiss )
ReachStartIdx(TrlNum,t,pall(pM),s) = tOnset + moveOnsetMiss;
ReachEndIdx(TrlNum,t,pall(pM),s)   = tOnset + HitMomentMiss;
                            XTemp2 = MatData.LocationListX(t)-nanmean(TempDataMiss(1,tZero+moveOnsetMiss-5:tZero+moveOnsetMiss+5));
                            YTemp2 = MatData.LocationListY(t)-nanmean(TempDataMiss(2,tZero+moveOnsetMiss-5:tZero+moveOnsetMiss+5));
                            ZTemp2 = nanmean(TempDataMiss(3,tZero+moveOnsetMiss-5:tZero+moveOnsetMiss+5));
                            
                            if ( isfinite(XTemp2) & isfinite(YTemp2) & isfinite(ZTemp2) )
                                XTemp2 = (XTemp2/1024)*screenSize(2);
                                YTemp2 = (YTemp2/768)*screenSize(1);
                                ZTemp2 = ZTemp2*zPixel; %% SS: need to fix?
                                HitEucDistFromMoveOnsetMiss(TrlNum,countHits,pall(pM),s) = sqrt((XTemp2^2)+(YTemp2^2)+(ZTemp2^2));
                            end
                        end
                    else
                        HitMoment = NaN;
                    end
                end
                
                if ( size(HitMoment,2)>0 & HitMoment > 2*t100ms ) % minimal of 200ms reaction time
                    rtHit(TrlNum,countHits,pall(pH),s) = HitMoment*(1/RecHz);
                    rtHitAll{pH}(tOnset+HitMoment) = HitMoment*(1/RecHz); % use this variable to calculate cross var
                else
                    rtHit(TrlNum,countHits,pall(pH),s) = NaN;
                end
                
                
                if ( size(HitMomentMiss,2)>0 & HitMomentMiss > 2*t100ms & isfinite(HitMomentMiss) )
                    rtHitMiss(TrlNum,countHits,pall(pM),s) = HitMomentMiss*(1/RecHz);
                    
                else
                    rtHitMiss(TrlNum,countHits,pall(pM),s) = NaN;
                end
                
                TargetType(TrlNum,countHits,pall(p),s) = MatData.MoleTypeList(t);
                
                nTargetType(TrlNum,MatData.MoleTypeList(t),pall(p),s) = nTargetType(TrlNum,MatData.MoleTypeList(t),pall(p),s)+1;
                
                
                XTemp = MatData.LocationListX(t)-nanmean(MatData.TrackList{p}(1,tOnset-5:tOnset+5));
                YTemp = MatData.LocationListY(t)-nanmean(MatData.TrackList{p}(2,tOnset-5:tOnset+5));
                ZTemp = nanmean(MatData.TrackList{p}(3,tOnset-5:tOnset+5));
                
                if ( isfinite(XTemp) & isfinite(YTemp) )
                    XTemp = (XTemp/1024)*screenSize(2);
                    YTemp = (YTemp/768)*screenSize(1);
                    ZTemp = ZTemp*zPixel; %% SS: need to fix?
                    
                    HitEucDistFromStart(TrlNum,countHits,pall(p),s) = sqrt((XTemp^2)+(YTemp^2)+(ZTemp^2));
                    HitVerDistFromStart(TrlNum,countHits,pall(p),s) = abs(YTemp);
                    HitHorDistFromStart(TrlNum,countHits,pall(p),s) = abs(XTemp);
                end
                
                if ( CreateHitMaps==2 )
                    rangeX = round((XTemp-GaborRad:XTemp+GaborRad)+1024+GaborRad/2+1);
                    rangeY = round((YTemp-GaborRad:YTemp+GaborRad)+786+GaborRad/2+1);
                    
                    if ( sum(rangeX>2100)==0 & sum(rangeY>1588)==0 & isfinite(XTemp) & isfinite(YTemp) )
                        HitMapsFromStart(rangeY,rangeX,pall(p),s) = HitMapsFromStart(rangeY,rangeX,pall(p),s)+Gabor;
                    end
                end
                
                if ( MatData.SwitchSides == 1 ) % switched sides
                    if ( pswitch == 1 )
                        MatData.LocationListX(t) = 1024-MatData.LocationListX(t);
                        MatData.LocationListY(t) = 768-MatData.LocationListY(t);
                    end
                else
                    if ( pswitch == -1 )
                        MatData.LocationListX(t) = 1024-MatData.LocationListX(t);
                        MatData.LocationListY(t) = 768-MatData.LocationListY(t);
                    end
                end
                
                if ( CreateHitMaps==1 )
                    rangeX = (MatData.LocationListX(t)-GaborRad:MatData.LocationListX(t)+GaborRad)+GaborRad/2+1;
                    rangeY = (MatData.LocationListY(t)-GaborRad:MatData.LocationListY(t)+GaborRad)+GaborRad/2+1;
                    
                    HitMaps(rangeY,rangeX,pall(p),s) = HitMaps(rangeY,rangeX,pall(p),s)+Gabor;
                    if ( TrlNum < 11 )
                        HitMaps1_10(rangeY,rangeX,pall(p),s) = HitMaps1_10(rangeY,rangeX,pall(p),s)+Gabor;
                    elseif ( TrlNum < 21 )
                        HitMaps11_20(rangeY,rangeX,pall(p),s) = HitMaps11_20(rangeY,rangeX,pall(p),s)+Gabor;
                    else
                        HitMaps21_30(rangeY,rangeX,pall(p),s) = HitMaps21_30(rangeY,rangeX,pall(p),s)+Gabor;
                    end
                end
                HitDist(TrlNum,countHits,pall(p),s) = MatData.LocationListY(t);
                HitWidth(TrlNum,countHits,pall(p),s) = MatData.LocationListX(t);
                HitHeight(TrlNum,countHits,pall(p),s) = nanmean(MatData.TrackList{p}(3,tOnset-5:tOnset+5));
            end  % for t=find(hitlist_p==p)
            
            % interpolate RT for cross corr
            idxFinite                           = find(isfinite(rtHitAll{p}));
            if length(idxFinite) > 1
                pI                                  = nan(1,length(rtHitAll{p}));
                pI(min(idxFinite):max(idxFinite))   = interp1(idxFinite,rtHitAll{p}(idxFinite),min(idxFinite):max(idxFinite),'cubic');
                rtHitAll{p} = pI;
            end            
        end   % for p=1:2
        
        vect = isfinite(rtHitAll{1}) & isfinite(rtHitAll{2});
        if sum(vect) > 0
            rtHitCrossCorr(TrlNum,:,s) = xcorr(rtHitAll{1}(vect),rtHitAll{2}(vect),260)/sum(vect);
        end
    end
    
    HitDist(:,:,1,s) = 768-HitDist(:,:,1,s); % flip for player 1 because he/she was on other side of table
    HitWidth(:,:,1,s) = 1024-HitWidth(:,:,1,s); % flip for player 1 because he/she was on other side of table
    
    MeanTrackPos(:,1,1,s) =  1024-MeanTrackPos(:,1,1,s);
    MeanTrackPos(:,2,1,s) =  768-MeanTrackPos(:,2,1,s);
    
    if ( sum((Scores(1,1:nTrials,s)-Scores(2,1:nTrials,s))>0) > nTrials/2 ) % player 1 wins
        ScoresWinExp(1,:,s) = Scores(1,:,s);
        ScoresWinExp(2,:,s) = Scores(2,:,s);
        
        HitFrequencyWinExp(1,:,s) = HitFrequency(1,:,s);
        HitFrequencyWinExp(2,:,s) = HitFrequency(2,:,s);
        
        HitDistWinExp(:,:,1,s) = HitDist(:,:,1,s);
        HitDistWinExp(:,:,2,s) = HitDist(:,:,2,s);
        
        HitWidthWinExp(:,:,1,s) = HitWidth(:,:,1,s);
        HitWidthWinExp(:,:,2,s) = HitWidth(:,:,2,s);
        
        rtHitWinExp(:,:,1,s) = rtHit(:,:,1,s);
        rtHitWinExp(:,:,2,s) = rtHit(:,:,2,s);
        
        HitTrajectStdWinExp(:,:,1,s) = HitTrajectStd(:,:,1,s);
        HitTrajectStdWinExp(:,:,2,s) = HitTrajectStd(:,:,2,s);
        
        rtHitMissWinExp(:,:,1,s) = rtHitMiss(:,:,1,s);
        rtHitMissWinExp(:,:,2,s) = rtHitMiss(:,:,2,s);
        
        TargetTypeWinExp(:,:,1,s) = TargetType(:,:,1,s);
        TargetTypeWinExp(:,:,2,s) = TargetType(:,:,2,s);
        
        HitVerDistFromStartWinExp(:,:,1,s) =  HitVerDistFromStart(:,:,1,s);
        HitVerDistFromStartWinExp(:,:,2,s) =  HitVerDistFromStart(:,:,2,s);
        
        HitEucDistFromStartWinExp(:,:,1,s) =  HitEucDistFromStart(:,:,1,s);
        HitEucDistFromStartWinExp(:,:,2,s) =  HitEucDistFromStart(:,:,2,s);
        
        MeanTrackPosWinExp(:,:,1,s) =  MeanTrackPos(:,:,1,s);
        MeanTrackPosWinExp(:,:,2,s) =  MeanTrackPos(:,:,2,s);
        
    elseif ( sum((Scores(1,1:nTrials,s)-Scores(2,1:nTrials,s))>0) < nTrials/2 ) % player 2 wins
        ScoresWinExp(1,1:nTrials,s) = Scores(2,1:nTrials,s);
        ScoresWinExp(2,1:nTrials,s) = Scores(1,1:nTrials,s);
        
        HitFrequencyWinExp(1,:,s) = HitFrequency(2,:,s);
        HitFrequencyWinExp(2,:,s) = HitFrequency(1,:,s);
        
        HitDistWinExp(:,:,1,s) = HitDist(:,:,2,s);
        HitDistWinExp(:,:,2,s) = HitDist(:,:,1,s);
        
        HitWidthWinExp(:,:,1,s) = HitWidth(:,:,2,s);
        HitWidthWinExp(:,:,2,s) = HitWidth(:,:,1,s);
        
        HitTrajectStdWinExp(:,:,1,s) = HitTrajectStd(:,:,2,s);
        HitTrajectStdWinExp(:,:,2,s) = HitTrajectStd(:,:,1,s);
        
        rtHitWinExp(:,:,1,s) = rtHit(:,:,2,s);
        rtHitWinExp(:,:,2,s) = rtHit(:,:,1,s);
        
        rtHitMissWinExp(:,:,1,s) = rtHitMiss(:,:,2,s);
        rtHitMissWinExp(:,:,2,s) = rtHitMiss(:,:,1,s);
        
        TargetTypeWinExp(:,:,1,s) = TargetType(:,:,2,s);
        TargetTypeWinExp(:,:,2,s) = TargetType(:,:,1,s);
        
        HitVerDistFromStartWinExp(:,:,1,s) =  HitVerDistFromStart(:,:,2,s);
        HitVerDistFromStartWinExp(:,:,2,s) =  HitVerDistFromStart(:,:,1,s);
        
        HitEucDistFromStartWinExp(:,:,1,s) =  HitEucDistFromStart(:,:,2,s);
        HitEucDistFromStartWinExp(:,:,2,s) =  HitEucDistFromStart(:,:,1,s);
        
        MeanTrackPosWinExp(:,:,1,s) =  MeanTrackPos(:,:,2,s);
        MeanTrackPosWinExp(:,:,2,s) =  MeanTrackPos(:,:,1,s);
    else
        ScoresWinExp(1,1:nTrials,s) = NaN;
        ScoresWinExp(2,1:nTrials,s) = NaN;
        
        HitFrequencyWinExp(1,:,s) = NaN;
        HitFrequencyWinExp(2,:,s) = NaN;
        
        HitDistWinExp(:,:,1,s) = NaN;
        HitDistWinExp(:,:,2,s) = NaN;
        
        HitWidthWinExp(:,:,1,s) = NaN;
        HitWidthWinExp(:,:,2,s) = NaN;
        
        HitTrajectStdWinExp(:,:,1,s) = NaN;
        HitTrajectStdWinExp(:,:,2,s) = NaN;
        
        rtHitWinExp(:,:,1,s) = NaN;
        rtHitWinExp(:,:,2,s) = NaN;
        
        rtHitMissWinExp(:,:,1,s) = NaN;
        rtHitMissWinExp(:,:,2,s) = NaN;
        
        TargetTypeWinExp(:,:,1,s) = NaN;
        TargetTypeWinExp(:,:,2,s) = NaN;
        
        HitVerDistFromStartWinExp(:,:,1,s) =  NaN;
        HitVerDistFromStartWinExp(:,:,2,s) =  NaN;
        
        HitEucDistFromStartWinExp(:,:,1,s) =  NaN;
        HitEucDistFromStartWinExp(:,:,2,s) =  NaN;
        
        MeanTrackPosWinExp(:,:,1,s) =  NaN;
        MeanTrackPosWinExp(:,:,2,s) =  NaN;
    end
    
    % higher mean score does not mean more money.
    if ( sum((Scores(1,1:nTrials,s)-Scores(2,1:nTrials,s))>0) > nTrials/2 & nanmean(Scores(1,1:nTrials,s)) > nanmean(Scores(2,1:nTrials,s)) | sum((Scores(1,1:nTrials,s)-Scores(2,1:nTrials,s))>0) < nTrials/2 & nanmean(Scores(1,1:nTrials,s)) < nanmean(Scores(2,1:nTrials,s)) ) % player X wins experiment has overall higher score
        MeanScoreVsWinExpVect(s) = 1;
    else
        MeanScoreVsWinExpVect(s) = 0;
    end
    
    if ( sum((Scores(1,1:nTrials,s)-Scores(2,1:nTrials,s))>0) > nTrials/2 )
        SubjectsWinExpVect(s) = 1;
        SubjectsWinExp{ 1 }{s} = ['W']; % subject had most wins
        SubjectsWinExp{ 2 }{s} = ['L']; % subject had least wins
    elseif ( sum((Scores(1,1:nTrials,s)-Scores(2,1:nTrials,s))>0) < nTrials/2 )
        SubjectsWinExpVect(s) = 2;
        SubjectsWinExp{ 2 }{s} = ['W']; % subject had most wins
        SubjectsWinExp{ 1 }{s} = ['L']; % subject had least wins
    else
        SubjectsWinExpVect(s) = 0;
        SubjectsWinExp{ 1 }{s} = ['D']; % subject had most wins
        SubjectsWinExp{ 2 }{s} = ['D']; % subject had least wins
    end
    
end

save('AllData.mat');
