function RunFullscreen(ExpMode)
% RUNFULLSCREEN   Run fullscreen Whac-a-mole experiment
%   Summer 2013 // Modified by Sasen
%   ExpMode: 0 = test mode, 1 = real experiment mode

%% Experiment description
% 
% Interactive whac-a-mole game.      
% Targets pop up at random locations. These should be hit by players.

%% Function Settings
  
% nargin = 0;
   
switch nargin,
    case 0
        ExpMode        =  0; % 0 = test mode, 1 = real experiment mode
        Screen('Preference', 'Verbosity', 1)
end

%% Screen Settings

Dist2Scr            =   720;            % (mm)
HoriScrDist         =   400;            % (mm)
ScrHz               =   60;             % framerate of screen (frames/second)
ScrNum              =   0;              % SS: changed from 2 due to InitializeScreens crash
BGCol               =   [0 0 0];        % backgroundcolor
TextColors          =   {[255 255 255]};

%ScrRes              =   [1280 800];     % Resolution of screen [hori vert]  [1024 768]
%ScrRes              =   [1024 768];     % Resolution of screen [hori vert]  [1024 768]
ResInfo 	    = Screen('Resolution',0);
ScrRes		    = [ResInfo.width ResInfo.height];

%% Experiment Parameters

KbName('UnifyKeyNames');

nMaxTrials                  = 30;           % number of trials per experiment.
nTrials                     = 10;           % number of trials per block. To prevent tracker crashes, this should be small.
TrialLength                 = 40;           % length of a game [s]
MaxTargetsOnScreen          = 8;            % maximum number of targets presented on screen simulteanously
TargetIntervalTimeRange     = [0 1500];     % time range of interval between targets [ms]
TargetPresTime              = 1250;         % time a target will stay on screen [ms]
TargetSize                  = 40;           % target diameter [pixel]
HitSize                     = 40;           % size of hit circle (if this circle touches the target, it is hit)
FeedBackDuration            = .75;         % duration of the feedback rectangle presented after target is hit

RecordHz                    = 200;          % at which speed should the tracker record?

meanNumberOfTargetOnScreen  = MaxTargetsOnScreen/((TargetPresTime+mean(TargetIntervalTimeRange))/TargetPresTime);
blockNums                   = linspace(1,nMaxTrials+1,(nMaxTrials/nTrials)+1);

%% More parameters

OutComePlayers               = [1 1 -1*ones(1,4); 
                                0 0 0 0 0 0];

% equalized for luminance at screen border (no projector bias)     
TargetColors  = [ 0   255     0;,... % green   22.3, .186/.670
                150   150    10;,... % yellow  22.6, .340/.545
                255     0     0;,... % red     6.64, .621/.322
                190     0   190;,... % magenta 6.32, .314/.131
                 30    60   255;,... % blue    5.49, .167/.121
                 80    50   160;,... % purple  5.22, .213/.135
                255   255   255];    % white   29.7, .265/.329, black   1.02, .320/.334

targetFeedbackCols = [];
targetFeedbackCols(1,:,1) = [0 255 0];
targetFeedbackCols(2,:,1) = [255 255 255];
targetFeedbackCols(1,:,2) = [255 255 255];
targetFeedbackCols(2,:,2) = [255 0 0];
targetFeedbackCols(1,:,3) = [255 0 0];
targetFeedbackCols(2,:,3) = [255 255 255];
targetFeedbackCols(1,:,4) = [255 255 255];
targetFeedbackCols(2,:,4) = [0 255 0];
targetFeedbackCols(1,:,5) = [0 255 0];
targetFeedbackCols(2,:,5) = [0 255 0];
targetFeedbackCols(1,:,6) = [255 0 0];
targetFeedbackCols(2,:,6) = [255 0 0];

% MAKE CALIBRATION TO GET THESE CORNERS!
calcorners = NaN(3,3,3);
calcorners(:,:,1) = [4.5914   13.8926   23.1742
                    5.0000   14.2434   23.5634
                    5.2680   14.4818   23.8340];
                     
calcorners(:,:,2) = [0.0217    0.4300    0.9884
                    -6.7067   -6.3475   -5.8403
                    -13.6602  -13.3281  -12.8529];
                     
calcorners(:,:,3) = [9.2613    9.2640    9.0308
                    9.5755    9.5183    9.2453
                    9.8692    9.7699    9.3148];

fitval = [];
fitval(1,:) = polyfit(nanmean(calcorners(:,:,1)),nanmean(calcorners(:,:,2)),1);
fitval(2,:) = polyfit(nanmean(calcorners(:,:,2),2),nanmean(calcorners(:,:,1),2),1);

maxZ = 10;
 
%% Input

if ExpMode > 0
    ppname1 = input('Initials Player 1:','s');
    ppname2 = input('Initials Player 2:','s');
    
    startTrialNum = str2num(input('Trial Number (1 if new experiment, or higher after crash):','s'));
    
    if ( sum(startTrialNum == blockNums)>0 & startTrialNum~=1 )
        disp('DID PLAYERS SWITCH SIDES?! ');
        disp('PLAYER 1 should stand left again (red sensor)');
        disp('PLAYER 2 should stand right.');
    end
    
    if ( startTrialNum == 1 & exist(['' ppname1 '_' ppname2 '_t1_e1.mat'])>0 )
        disp('INITIALS ALREADY EXIST');
        error('STOP');
        return;
    end
    
    calibration = str2num(input('Calibration (0 if everything okay, or 1 for recalibration of tracker):','s'));

    ExpNum  = 1;
    
    ppname = [ppname1 '_' ppname2];
    Priority(2);
else
    ppname1 = 'tt';
    ppname2 = 'tt';
    
    startTrialNum = 1;

    ExpNum = 999;
    
    calibration = 0;
    
    ppname = [ppname1 '_' ppname2];
    Priority(1);
end

%% re-calibrate tracker
% if necessary

if ( calibration == 1 )
    Calibration;
end

%% open screens

Screen('Preference', 'SkipSyncTests', 1);
[window, windowRect] = InitializeScreens(ScrNum,BGCol,1);
%% IF ABOVE LINE PRODUCES ERROR, REMEMBER TO addpath('MatlabFunctions')!

%% Initialization

InitializeScreenPref(window,ExpMode,ScrHz,ScrRes);
InitializeTextPref(window,16,'Helvetica',1);

% screen linearization
% cd MonitorCalibration
%     LumVals = load('wet3.mat');
% cd ..

% [newClutTable, oldClutTable] = CorrectClut(ScrNum, fliplr([LumVals.wet3.c_R_cdm2; LumVals.wet3.c_G_cdm2; LumVals.wet3.c_B_cdm2]), fliplr(LumVals.wet3.ind), 1);
[newClutTable, oldClutTable] = CorrectClut(ScrNum);

if ExpMode > 0
    RemoveListening; % no keyboard input on command line, and remove mouse arrow
    HideCursor;
end

% predraw arrow parts
fbsc = 1.0;   %% target feedback size (sidelength) scale factor. 1 = TargetSize
winfb = Screen('OpenOffscreenWindow', window, [0 0 0 0], [0 0 fbsc*TargetSize 1.5*fbsc*TargetSize]);
Screen('FillRect', winfb, [255 255 255], [fbsc*TargetSize/3 0 fbsc*2*TargetSize/3 fbsc*TargetSize/2]);  % arrowshaft
Screen('FillPoly', winfb, [255 255 255], [0 fbsc*TargetSize/2; fbsc*TargetSize fbsc*TargetSize/2; fbsc*TargetSize/2 fbsc*TargetSize], 1);  % arrowhead (downward)
Screen('FillRect', winfb, [255 255 255], [0 fbsc*TargetSize fbsc*TargetSize 1.5*fbsc*TargetSize]);  % hammerhead
rect_arrowshaft = [0 0 fbsc*TargetSize fbsc*TargetSize/2];
rect_arrowhead = [0 fbsc*TargetSize/2 fbsc*TargetSize fbsc*TargetSize];
rect_hammerhead = [0 fbsc*TargetSize fbsc*TargetSize 1.5*fbsc*TargetSize];

fbArrowRect = [];
fbArrowRect(1,:,1) = rect_arrowhead;
fbArrowRect(2,:,1) = rect_arrowshaft;
fbArrowRect(1,:,2) = rect_arrowhead;
fbArrowRect(2,:,2) = rect_arrowshaft;
fbArrowRect(1,:,3) = rect_hammerhead;
fbArrowRect(2,:,3) = rect_arrowshaft;
fbArrowRect(1,:,4) = rect_hammerhead;
fbArrowRect(2,:,4) = rect_arrowshaft;
fbArrowRect(1,:,5) = rect_hammerhead;
fbArrowRect(2,:,5) = rect_arrowshaft;
fbArrowRect(1,:,6) = rect_hammerhead;
fbArrowRect(2,:,6) = rect_arrowshaft;

%% Open a half-size offscreen window for mirrored stuff
woff = Screen('OpenOffScreenWindow',window,[0 0 0], [ScrRes(1)/2 0 ScrRes(1) ScrRes(2)]);
InitializeTextPref(woff,16,'Helvetica',1);

%%%%%%%%%%% Welcome/Instructions
tSize=Screen('TextSize',woff,20);
DrawText(woff,{'WELCOME TO WHAC-A-MOLE!'},TextColors,20,20,0,0);
Screen('TextSize',woff,tSize);

DrawText(woff,{'POINTS'},TextColors,20,100,0);
DrawText(woff,{'MOLE TYPE'},TextColors,150,100,0);

PointColor = [255 0 0; 128 128 128; 0 255 0];
tgtHalf = TargetSize/2;
iconLEdge = 200-tgtHalf;
iconREdge = 200+tgtHalf;

% Table of Mole Types and Points
Screen('DrawLine',woff,[255 255 255], 20, tgtHalf+100, 250, tgtHalf+100);
for moleTypeNum = 1:6
    myPts = OutComePlayers(1,moleTypeNum);
    myOffset = 100+moleTypeNum*TargetSize;
    DrawText(woff,{[num2str(myPts)]},{PointColor(myPts+2,:)},50,myOffset,0,0);
    Screen('FillOval',woff,TargetColors(moleTypeNum,:),[iconLEdge myOffset-tgtHalf iconREdge myOffset+tgtHalf]);
    Screen('DrawLine',woff,[255 255 255], 20, tgtHalf+myOffset, 250, tgtHalf+myOffset);
end

% Table of feedback symbols
bottomY = (2/3)*ScrRes(2);
Screen('DrawLine',woff,[255 255 255], 20, bottomY-tgtHalf-2, 250, bottomY-tgtHalf-2);
DrawText(woff,{'POINT GAINED'},TextColors,20,bottomY,0,0);
Screen('DrawTexture',woff,winfb,rect_arrowshaft,[iconLEdge bottomY-tgtHalf iconREdge bottomY]);
Screen('DrawTexture',woff,winfb,rect_arrowhead,[iconLEdge bottomY iconREdge bottomY+tgtHalf]);
Screen('DrawLine',woff,[255 255 255], 20, bottomY+tgtHalf+2, 250, bottomY+tgtHalf+2);
bottomY = bottomY+TargetSize+4;
DrawText(woff,{'POINT LOST'},TextColors,20,bottomY,0,0);
Screen('DrawTexture',woff,winfb,rect_arrowshaft,[iconLEdge bottomY-tgtHalf iconREdge bottomY]);
Screen('DrawTexture',woff,winfb,rect_hammerhead,[iconLEdge bottomY iconREdge bottomY+tgtHalf]);
Screen('DrawLine',woff,[255 255 255], 20, bottomY+tgtHalf+2, 250, bottomY+tgtHalf+2);



Screen('FillRect', window, BGCol); % draw background
DrawMirrored(window, woff,woff, ScrRes);  % draw instructions on both sides
Screen('Flip', window);
WaitForKeyPress({'SPACE'});


Screen('FillRect', window, BGCol); % draw background
Screen('Flip', window);

%% initiate finger tracker

if ( ExpMode > 0 )
    tracker(0,RecordHz);
end

if ( ExpMode > 0 )
    data = tracker(5,RecordHz);
end

%%

SwitchSides = -1;

ScorePlayers     = zeros(2,nMaxTrials);

MoneyPlayers     = [0 0];

PlayerContinues  = zeros(1,nMaxTrials); % this variable checks who presses the continue button, 1 = left, 2 = right

if ( startTrialNum > 1 )
    MatData = load(['' ppname '_t' num2str(startTrialNum-1) '_e' num2str(ExpNum)]); % LOAD DATA BEFORE CRASH

    ScorePlayers     = MatData.ScorePlayers;
    MoneyPlayers     = MatData.MoneyPlayers;
    SwitchSides      = MatData.SwitchSides;
    if ( sum(startTrialNum == blockNums) > 0 ) 
        SwitchSides = -1;
    end
    clear MatData
    
    ScorePlayers(:,startTrialNum:end)  = 0;
end

if ( ExpMode > 0 )
    data = tracker(5,RecordHz);
end

if ( sum(startTrialNum == blockNums)>0 )
    endTrialNum = startTrialNum+nTrials-1;
else
    endTrialNum = blockNums(find(startTrialNum<blockNums,1,'first'))-1;
end


%% Trial loop
for TrlNum = startTrialNum:endTrialNum
%     disp(['Loading trial: ' num2str(TrlNum)]);
   
%% show flip sides instructions
    
    if sum(TrlNum == blockNums+nTrials/2) > 0 % every half of the trials
        DrawSwitchSidesInstruction;
        SwitchSides = -1*SwitchSides;
    end
    
%% show mole instructions

%     if TrlNum < 4 | sum(TrlNum == ceil(linspace(startTrialNum,endTrialNum+1,3)))>0
%         DrawMoleTypeInstruction;
%     end

%% load trial (timing, type, and location of targets)  

    nTargetOnsets       = 2*round(1000*TrialLength/(TargetPresTime+mean(TargetIntervalTimeRange)));
    TrialList           = zeros(MaxTargetsOnScreen,nTargetOnsets);
    LocationListY       = zeros(MaxTargetsOnScreen,nTargetOnsets);
    LocationListX       = zeros(MaxTargetsOnScreen,nTargetOnsets);
    HitList_t           = zeros(MaxTargetsOnScreen,nTargetOnsets); % timing of hitting the target
    HitList_p           = zeros(MaxTargetsOnScreen,nTargetOnsets); % player idx who hit the target
    MoleTypeList        = zeros(MaxTargetsOnScreen,nTargetOnsets);
    
    TrackList           = cell(1,2);
    TrackList{1}        = NaN(3,TrialLength*260); % 240 Hz -> increased to 260 just to be sure in cases of a bit higher Hz rates
    TrackList{2}        = NaN(3,TrialLength*260); % 240 Hz
    
    TargetCoverageMap   = zeros(ScrRes(2),ScrRes(1));
    
    if ( ExpMode > 0 )
        tracker(0,RecordHz);
    end
    
    rng('shuffle');
    for i = 1:MaxTargetsOnScreen
         TrialList(i,:)     = [i*(mean(TargetIntervalTimeRange)/MaxTargetsOnScreen) + cumsum(TargetPresTime+TargetIntervalTimeRange(1)+(TargetIntervalTimeRange(2)-TargetIntervalTimeRange(1))*rand(1,nTargetOnsets))];
         
         tempList = [];
         for j = 1:ceil(nTargetOnsets/8)
            tempList = [tempList Shuffle([1 2 3 4 5 6 1 2])];
            
         end
         MoleTypeList(i,:)  = tempList(1:nTargetOnsets);
    end
    
    rng('shuffle');
    nHistoryTargetOverlapCheck = 4; % number of iterations back into history to check for overlapping targets
    count = 0;
    for j = 1:nTargetOnsets
        if j > nHistoryTargetOverlapCheck
            TargetCoverageMap = TargetCoverageMap-1;
            TargetCoverageMap(TargetCoverageMap(:)<0) = 0;
            TargetCoverageNum = nHistoryTargetOverlapCheck;
        else
            TargetCoverageNum = j;
        end
        
        for i = 1:MaxTargetsOnScreen
            LocationListY(i,j) = round(TargetSize+(ScrRes(2)-2*TargetSize)*rand(1,1));
            
            LocationListX(i,j) = round(TargetSize+(ScrRes(1)-2*TargetSize)*rand(1,1));
            
            TempCoverageMap = TargetCoverageMap(LocationListY(i,j)-TargetSize/2:LocationListY(i,j)+TargetSize/2,LocationListX(i,j)-TargetSize/2:LocationListX(i,j)+TargetSize/2);
            
            while ( sum(TempCoverageMap(:))>0 )
                LocationListY(i,j)  = round(TargetSize+(ScrRes(2)-2*TargetSize)*rand(1,1));
                LocationListX(i,j)  = round(TargetSize+(ScrRes(1)-2*TargetSize)*rand(1,1));
                
                TempCoverageMap = TargetCoverageMap(LocationListY(i,j)-TargetSize/2:LocationListY(i,j)+TargetSize/2,LocationListX(i,j)-TargetSize/2:LocationListX(i,j)+TargetSize/2);
                
            end    
            
            TargetCoverageMap(LocationListY(i,j)-TargetSize/2:LocationListY(i,j)+TargetSize/2,LocationListX(i,j)-TargetSize/2:LocationListX(i,j)+TargetSize/2) = TargetCoverageMap(LocationListY(i,j)-TargetSize/2:LocationListY(i,j)+TargetSize/2,LocationListX(i,j)-TargetSize/2:LocationListX(i,j)+TargetSize/2)+TargetCoverageNum;
        end
        
    end
    
    for i = 3:-1:1
        Text = {'',...
            'Get ready!',...
            '',...
            };

        Screen('FillRect', woff, BGCol); % draw background        
        DrawText(woff,Text,TextColors,20,ScrRes(2)/4,0,0);
        DrawText(woff,{num2str(i)},TextColors,50,ScrRes(2)/3,0);
        DrawMirrored(window,woff,woff,ScrRes);
        Screen('Flip', window);
        WaitSecs(0.5);
    end
        
    if ( ExpMode > 0 )
        data = tracker(5,RecordHz);
    end
            
%     disp(['Trial starts: ' num2str(TrlNum)]);
    
%% start trial

    if ( ExpMode > 0 )
        data = tracker(5,RecordHz);
    else
        data = ones(5,2);
    end
    
    PlayerLeftIdx   = (SwitchSides/2)+1.5; % NOTE THAT PLAYER LEFT DOES NOT HAVE TO BE PLAYER 1 (only at the beginning and after each 10 trials)
    PlayerRightIdx  = mod((SwitchSides/2)+1.5,2)+1;
    
    TimeStampTrackerLeft    = data(2,1)-1;
    TimeStampTrackerRight   = data(2,2)-1;
    
    vbl = Screen('Flip', window);
    
    targetFeedback = [];
    
    tStart          = GetSecs;
    targetNum       = ones(1,MaxTargetsOnScreen);
    targetHit       = zeros(1,MaxTargetsOnScreen);
    playerHit       = zeros(1,MaxTargetsOnScreen);
    targetShown     = zeros(1,MaxTargetsOnScreen);
    while GetSecs-tStart < TrialLength
        
        Screen('FillRect', window, BGCol); % draw background
        
        tFrame = GetSecs;
        while GetSecs-tFrame < (1/ScrHz)
            
            % present or remove targets from screen
            for i = 1:MaxTargetsOnScreen
                TimeDifference = round((((GetSecs-tStart)*1000)-TrialList(i,targetNum(i))));

                % select next target for presentation after a target hit
                if targetHit(i) > 0 
                    HitList_t(i,targetNum(i)) = GetSecs-tStart;
                    HitList_p(i,targetNum(i)) = playerHit(i);
                    
                    targetNum(i) = targetNum(i)+1;
                    targetHit(i) = 0;
                    playerHit(i) = 0;
                    targetShown(i) = 0;
                elseif TimeDifference >= TargetPresTime % target is missed
                    targetNum(i) = targetNum(i)+1;
                    targetShown(i) = 0;
                elseif TimeDifference > 0 & TimeDifference < TargetPresTime % show target
                    tempColor = TargetColors(MoleTypeList(i,targetNum(i)),:);
                    tempColor = round(tempColor.*((TargetPresTime/2)-abs(TimeDifference-(TargetPresTime/2)))/(TargetPresTime/2));
                    Screen('FillOval', window, tempColor, [LocationListX(i,targetNum(i))-TargetSize/2 LocationListY(i,targetNum(i))-TargetSize/2 LocationListX(i,targetNum(i))+TargetSize/2 LocationListY(i,targetNum(i))+TargetSize/2], TargetSize+2);
                    targetShown(i) = 1;
                else
                    targetShown(i) = 0;
                end

            end

            % check whether feedback should be presented about target hit
            i = 0;
            while i < size(targetFeedback,2)
                i = i +1;
                if ( GetSecs-targetFeedback(3,i) > FeedBackDuration ) % remove because feedback is over
                    targetFeedback = [targetFeedback(:,1:i-1) targetFeedback(:,i+1:end)];
                elseif ( GetSecs-targetFeedback(3,i) <= FeedBackDuration & targetFeedback(3,i)~= 0 ) % show feedback
                    
                    targetArea = [targetFeedback(1,i)-fbsc*TargetSize/2 targetFeedback(2,i) targetFeedback(1,i)+fbsc*TargetSize/2 targetFeedback(2,i)+fbsc*TargetSize/2; 
                                  targetFeedback(1,i)-fbsc*TargetSize/2 targetFeedback(2,i)-fbsc*TargetSize/2 targetFeedback(1,i)+fbsc*TargetSize/2 targetFeedback(2,i)];
                    
                    % Select FeedbackArrow parts
                    P1rect = fbArrowRect(targetFeedback(4,i),:,MoleTypeList(targetFeedback(6,i),targetFeedback(5,i)));
                    P2rect = fbArrowRect(mod(targetFeedback(4,i),2)+1,:,MoleTypeList(targetFeedback(6,i),targetFeedback(5,i)));
                    fbAngle = 0;
                    if (targetFeedback(4,i) == 2)
                        fbAngle = 180;
                    end
                    % add to feedback pane #1
                    Screen('DrawTexture', window, winfb, P1rect, targetArea(1,:),0+fbAngle);
                    Screen('DrawTexture', window, winfb, P2rect, targetArea(2,:),0+fbAngle);
                end
            end
                
            if ( ExpMode > 0 )
                data = tracker(5,RecordHz);
            else
                data = ones(5,2);
            end
            [xPos1, yPos1, zPos1, xPos2, yPos2, zPos2] = TransformTrackerData(data,calcorners,ScrRes,fitval);

            TimeStampLeft   = round(data(2,1)-TimeStampTrackerLeft);
            TimeStampRight  = round(data(2,2)-TimeStampTrackerRight);

            TrackList{PlayerLeftIdx}(:,TimeStampLeft)         = [xPos1; yPos1; zPos1];
            TrackList{PlayerRightIdx}(:,TimeStampRight)       = [xPos2; yPos2; zPos2];

%             %%%%%%%%%%%%%%%%%%%
%             % TEST DRAW OF POSITION
%             Screen('FrameOval', window, [255 255 255], [xPos1-HitSize/2 yPos1-HitSize/2 xPos1+HitSize/2 yPos1+HitSize/2] );
%             Screen('FrameOval', window, [255 255 255], [xPos1-5 yPos1-5 xPos1+5 yPos1+5] );
             
%             Screen('FrameOval', window, [255 255 255], [xPos2-HitSize/2 yPos2-HitSize/2 xPos2+HitSize/2 yPos2+HitSize/2] );
%             Screen('FrameOval', window, [255 255 255], [xPos2-5 yPos2-5 xPos2+5 yPos2+5] );
             
%             DrawText(window,{num2str(zPos1)},{[255 255 255]},20,25,0,0); %
%             DrawText(window,{num2str(zPos2)},{[255 255 255]},20,125,0,0); %
            %%%%%%%%%%%%%%%%%%%
            
            % check whether target is hit
            for i = 1:MaxTargetsOnScreen
                if ( targetShown(i) == 1 ) % only if target is really presented
                    LeftPlayerHit   = zPos1 < maxZ & LocationListX(i,targetNum(i)) > xPos1-HitSize/2 & LocationListX(i,targetNum(i)) < xPos1+HitSize/2 & LocationListY(i,targetNum(i)) > yPos1-HitSize/2 & LocationListY(i,targetNum(i)) < yPos1+HitSize/2;
                    RightPlayerHit  = zPos2 < maxZ & LocationListX(i,targetNum(i)) > xPos2-HitSize/2 & LocationListX(i,targetNum(i)) < xPos2+HitSize/2 & LocationListY(i,targetNum(i)) > yPos2-HitSize/2 & LocationListY(i,targetNum(i)) < yPos2+HitSize/2;

                    if ( LeftPlayerHit & RightPlayerHit )
                        if ( zPos1 < zPos2 )
                            targetHit(i) = 1; % 1 for player left, 2 for player right, 0 if not hit
                            playerHit(i) = PlayerLeftIdx;
                        elseif ( zPos1 > zPos2 )
                            targetHit(i) = 2; % 1 for player left, 2 for player right, 0 if not hit
                            playerHit(i) = PlayerRightIdx;
                        else
                            targetHit(i) = round(rand(1,1))+1;
                            if ( targetHit(i) == 1 )
                                playerHit(i) = PlayerLeftIdx;
                            else
                                playerHit(i) = PlayerRightIdx;
                            end
                        end
                        targetFeedback(1:2,end+1) = [LocationListX(i,targetNum(i)) LocationListY(i,targetNum(i))];
                        targetFeedback(3,end) = GetSecs;
                        targetFeedback(4,end) = targetHit(i);
                        targetFeedback(5,end) = targetNum(i);
                        targetFeedback(6,end) = i;
                    elseif ( LeftPlayerHit )
                        targetHit(i) = 1; % 1 for player left, 2 for player right, 0 if not hit
                        playerHit(i) = PlayerLeftIdx;
                        targetFeedback(1:2,end+1) = [LocationListX(i,targetNum(i)) LocationListY(i,targetNum(i))];
                        targetFeedback(3,end) = GetSecs;
                        targetFeedback(4,end) = targetHit(i);
                        targetFeedback(5,end) = targetNum(i);
                        targetFeedback(6,end) = i;
                    elseif ( RightPlayerHit )
                        targetHit(i) = 2; % 1 for player left, 2 for player right, 0 if not hit
                        playerHit(i) = PlayerRightIdx;
                        targetFeedback(1:2,end+1) = [LocationListX(i,targetNum(i)) LocationListY(i,targetNum(i))];
                        targetFeedback(3,end) = GetSecs;
                        targetFeedback(4,end) = targetHit(i);
                        targetFeedback(5,end) = targetNum(i);
                        targetFeedback(6,end) = i;
                    else
                        targetHit(i) = 0;
                    end

                    % if target is hit, change score
                    if ( targetHit(i) > 0 )
                        ScorePlayers(playerHit(i),TrlNum) = ScorePlayers(playerHit(i),TrlNum)+OutComePlayers(1,MoleTypeList(i,targetNum(i)));
                        ScorePlayers(mod(playerHit(i),2)+1,TrlNum) = ScorePlayers(mod(playerHit(i),2)+1,TrlNum)+OutComePlayers(2,MoleTypeList(i,targetNum(i)));
                    end
                end
            end
        end
        
        % show updated screen
        vbl = Screen('Flip', window, vbl+0.5*(1/ScrHz), [], 1); 
    end

    Screen('FillRect', window, BGCol); % draw background
    Screen('Flip', window);
    
    if ( ExpMode > 0 )
        tracker(0,RecordHz);
        WaitSecs(1);
    end
    
    % instruction
    Screen('FillRect', window, BGCol); % draw background
    Screen('FillRect', woff, [0 0 0]); % black bg for feedback pane
    
    PlayerLeftScore = ScorePlayers(PlayerLeftIdx,TrlNum);
    PlayerRightScore = ScorePlayers(PlayerRightIdx,TrlNum);
        
    if (PlayerLeftScore > PlayerRightScore )
        DrawText(window,{'YOU WIN!'},{[0 255 0]},0.5*ScrRes(1)/6,ScrRes(2)/6,0);
        DrawText(woff,{'YOU LOSE!'},{[255 0 0]},0.5*ScrRes(1)/6,ScrRes(2)/6,0);        
        DrawText(window,{['YOUR SCORE IS  ' num2str(PlayerLeftScore)]},{[0 255 0]},0.5*ScrRes(1)/6,ScrRes(2)/3,0);
        DrawText(window,{['YOUR OPPONENT GOT  ' num2str(PlayerRightScore)]},{[255 0 0]},0.5*ScrRes(1)/6,2*ScrRes(2)/3,0);
        DrawText(woff,{['YOUR SCORE IS  ' num2str(PlayerRightScore)]},{[255 0 0]},0.5*ScrRes(1)/6,ScrRes(2)/3,0);
        DrawText(woff,{['YOUR OPPONENT GOT  ' num2str(PlayerLeftScore)]},{[0 255 0]},0.5*ScrRes(1)/6,2*ScrRes(2)/3,0);
        MoneyPlayers(PlayerLeftIdx) = MoneyPlayers(PlayerLeftIdx)+0.8;
    elseif ( PlayerLeftScore < PlayerRightScore )
        DrawText(window,{'YOU LOSE!'},{[255 0 0]},0.5*ScrRes(1)/6,ScrRes(2)/6,0);
        DrawText(woff,{'YOU WIN!'},{[0 255 0]},0.5*ScrRes(1)/6,ScrRes(2)/6,0);      
 	DrawText(window,{['YOUR SCORE IS  ' num2str(PlayerLeftScore)]},{[255 0 0]},0.5*ScrRes(1)/6,ScrRes(2)/3,0);
       	DrawText(window,{['YOUR OPPONENT GOT  ' num2str(PlayerRightScore)]},{[0 255 0]},0.5*ScrRes(1)/6,2*ScrRes(2)/3,0);
      	DrawText(woff,{['YOUR SCORE IS  ' num2str(PlayerRightScore)]},{[0 255 0]},0.5*ScrRes(1)/6,ScrRes(2)/3,0);
       	DrawText(woff,{['YOUR OPPONENT GOT  ' num2str(PlayerLeftScore)]},{[255 0 0]},0.5*ScrRes(1)/6,2*ScrRes(2)/3,0);
        MoneyPlayers(PlayerRightIdx) = MoneyPlayers(PlayerRightIdx)+0.8;
    else % draw
        DrawText(window,{'DRAW!'},{[0 0 255]},0.5*ScrRes(1)/6,ScrRes(2)/6,0);
        DrawText(woff,{'DRAW!'},{[0 0 255]},0.5*ScrRes(1)/6,ScrRes(2)/6,0);       
        DrawText(window,{['YOUR SCORE IS  ' num2str(PlayerLeftScore)]},{[0 0 255]},0.5*ScrRes(1)/6,ScrRes(2)/3,0);
        DrawText(window,{['YOUR OPPONENT GOT  ' num2str(PlayerRightScore)]},{[0 0 255]},0.5*ScrRes(1)/6,2*ScrRes(2)/3,0);
        DrawText(woff,{['YOUR SCORE IS  ' num2str(PlayerRightScore)]},{[0 0 255]},0.5*ScrRes(1)/6,ScrRes(2)/3,0);
        DrawText(woff,{['YOUR OPPONENT GOT  ' num2str(PlayerLeftScore)]},{[0 0 255]},0.5*ScrRes(1)/6,2*ScrRes(2)/3,0);
        MoneyPlayers(PlayerLeftIdx) = MoneyPlayers(PlayerLeftIdx)+0.4;
        MoneyPlayers(PlayerRightIdx) = MoneyPlayers(PlayerRightIdx)+0.4;
    end
    
%    DrawText(window,{['BALANCE: ' num2str(MoneyPlayers(PlayerLeftIdx))]},{[255 255 255]},round(0.5*ScrRes(1)/6),round(ScrRes(2)/1.5),0);
%    DrawText(woff,{['BALANCE: ' num2str(MoneyPlayers(PlayerRightIdx))]},{[255 255 255]},round(0.5*ScrRes(1)/6),round(ScrRes(2)/1.5),0);
    
    
    
    %%%%%%%%%%%%%%%%%%%%% SAVE DATA 
    save(['' ppname '_t' num2str(TrlNum) '_e' num2str(ExpNum),'.mat']); % SAVE DATA
    %%%%%%%%%%%%%%%%%%%%%
    
    
    
    AreaOfInterest = [20 ScrRes(2)-50 ScrRes(1)/2-20 ScrRes(2)-10];
    Screen('FrameRect', window, [255 255 255], AreaOfInterest);
    DrawText(window,{' NEXT GAME '},TextColors,AreaOfInterest(1)+50,AreaOfInterest(2)+10,0,0);
    
    Screen('DrawTexture', window, woff, [], [ScrRes(1)/2 0 ScrRes(1) ScrRes(2)], 180);

    Screen('Flip', window);

%     disp('Participants read score results');
    
    if ( ExpMode > 0 )
        WaitSecs(1);
        data = tracker(5,RecordHz);
        WaitSecs(1);
    end
    
    if ( ExpMode > 0 )
        continueHit = 0;
        while continueHit==0
            data = tracker(5,RecordHz);
            WaitSecs(1/RecordHz);
            
            [xPos1, yPos1, zPos1, xPos2, yPos2, zPos2] = TransformTrackerData(data,calcorners,ScrRes,fitval);
            if ( yPos1 < AreaOfInterest(4) & yPos1 > AreaOfInterest(2) & xPos1 > AreaOfInterest(1) & xPos1 < AreaOfInterest(3) & zPos1 < maxZ )
                PlayerContinues(TrlNum) = PlayerLeftIdx;
                continueHit = 1;
            elseif ( yPos2 < AreaOfInterest(4) & yPos2 > AreaOfInterest(2) & xPos2 > AreaOfInterest(1) & xPos2 < AreaOfInterest(3) & zPos2 < maxZ )
                PlayerContinues(TrlNum) = PlayerRightIdx;
                continueHit = 1;
            end
        end
    else
        WaitForKeyPress({'SPACE'});
    end
    
    Screen('FillRect', window, BGCol); % draw background
    Screen('Flip', window);
    
    
end

if ( ExpMode > 0 )
    tracker(0,RecordHz);
end

% give feedback
Screen('FillRect', window, BGCol); % draw background
Screen('FillRect', woff, BGCol); % draw background

if ( TrlNum == nMaxTrials )
    
    Text = {'FINISHED!',... 
    'Thanks for playing!'};

    DrawText(window,Text,{[255 0 0]},100,200,0);
    DrawText(woff,Text,{[255 0 0]},100,200,0);
    
else
    
    Text = {'The experiment needs to be restarted!',... 
        ''};

    DrawText(window,Text,TextColors,20,20,0);
    DrawText(woff,Text,TextColors,20,20,0);
        
    Text = {'PLAYERS SHOULD ALSO SWITCH:','','SIDES,','AND TOUCH DEVICES','','CALL THE EXPERIMENTER'};
    
    DrawText(window,Text,TextColors,20,120,0,0);
    DrawText(woff,Text,TextColors,20,120,0,0);
end

Screen('DrawTexture', window, woff, [], [ScrRes(1)/2 0 ScrRes(1) ScrRes(2)], 180);
Screen('Flip', window);


WaitSecs(5);
Screen('FillRect', window, BGCol); % draw background
Screen('Flip', window);

ShowCursor('Arrow');
ListenChar(0);
Screen CloseAll;

% disp('recorded at:');
% disp([num2str((sum(isfinite(TrackList{1}(1,:)))/9600)*240) 'Hz']) % for long 40s trials

clc;

disp(['Money Player 1: ' num2str(MoneyPlayers(1))])
disp(['Money Player 2: ' num2str(MoneyPlayers(2))])

if TrlNum<nMaxTrials
    disp(['Next trial should be: ' num2str(endTrialNum+1)])
end

