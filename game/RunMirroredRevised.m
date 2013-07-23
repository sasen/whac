function RunMirrored(ExpMode)
% RUNMIRRORED  Run mirrored Whac-a-mole experiment
%   Summer 2013 // Modified by Sasen
%   eg:   RunMirrored(ExpMode);
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

blockStructure              = [3 6 6 6];   % 3 practice trials; switch after each block 
TrialLength                 = 30;           % length of a game [s]
MaxTargetsOnScreen          = 8;            % maximum number of targets presented on screen simulteanously
TargetIntervalTimeRange     = [0 1500];     % time range of interval between targets [ms]
TargetPresTime              = 1250;         % time a target will stay on screen [ms]
TargetSize                  = 40;           % target diameter [pixel]
HitSize                     = 40;           % size of hit circle (if this circle touches the target, it is hit)
FeedBackDuration            = 0.75;         % duration of the feedback rectangle presented after target is hit
RecordHz                    = 200;          % at which speed should the tracker record?
maxZ                        = 0.5;          % height in normalized inches

nMaxTrials = sum(blockStructure);   % number of trials per experiment
newBlockNums = cumsum([1 blockStructure]);

meanNumberOfTargetOnScreen  = MaxTargetsOnScreen/((TargetPresTime+mean(TargetIntervalTimeRange))/TargetPresTime);


%% More parameters

OutComePlayers               = [1 1 -1*ones(1,4); 
                                0 0 0 0 0 0];

% equalized for luminance at screen border (no projector bias)     
TargetColors  = [ 0   255     0;... % green   22.3, .186/.670
                150   150    10;... % yellow  22.6, .340/.545
                255     0     0;... % red     6.64, .621/.322
                190     0   190;... % magenta 6.32, .314/.131
                 30    60   255;... % blue    5.49, .167/.121
                 80    50   160;... % purple  5.22, .213/.135
                255   255   255];    % white   29.7, .265/.329, black   1.02, .320/.334

%% Input

ExpNum  = 2;
dirname = 'Results/RunMirrored/';
if ExpMode > 0
    pwdir = 'C:\Documents and Settings\Maryam\My Documents\MATLAB\Whac-a-mole';
    cd(pwdir);
    pname1 = input('Player 1 ID:','s');
    pname2 = input('Player 2 ID:','s');
    ppname = [pname1 '_' pname2];

    %% figure out what trial number to start with (if prev trials exist)
    startTrialNum = 1;
    while (exist([dirname ppname '_t' num2str(startTrialNum) '_e' num2str(ExpNum) '.mat'],'file') )
        startTrialNum = startTrialNum + 1;  
    end
    disp(['Starting with trial ' num2str(startTrialNum)]);    
    Priority(2);
else
    pname1 = 'tt';
    pname2 = 'tt';
    ppname = [pname1 '_' pname2];    
    startTrialNum = 1;
    ExpNum = 998;    
    Priority(1); %Why is this a different priority level? LOOK HERE
end

%% load or perform calibration
[T_SB1, in2px] = findrot(1,'jul22');
[T_SB2, ~]     = findrot(2,'jul22');


%% open screens

[window, windowRect] = InitializeScreens(ScrNum,BGCol,1);
%% IF ABOVE LINE PRODUCES ERROR, REMEMBER TO addpath('MatlabFunctions')!

%% Initialization

%InitializeScreenPref(window,ExpMode,ScrHz,ScrRes); % too cavalier
InitializeTextPref(window,16,'Helvetica',1);

if ExpMode > 0
%    RemoveListening; %PsychJava fail: window loses focus, MatLab segfaults
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
HalfScrRes = [ScrRes(1)/2 ScrRes(2)];  % half-screens split along horizontal side
woff = Screen('OpenOffScreenWindow',window,[0 0 0 0], [ScrRes(1)/2 0 ScrRes(1) ScrRes(2)]);
InitializeTextPref(woff,16,'Helvetica',1);

woff1 = Screen('OpenOffScreenWindow',window,[0 0 0 0], [0 0 HalfScrRes]);
woff2 = Screen('OpenOffScreenWindow',window,[0 0 0 0], [0 0 HalfScrRes]);

%% Welcome/Instructions
tSize=Screen('TextSize',woff,20);
DrawText(woff,{'WELCOME TO WHAC-A-MOLE!'},TextColors,20,20,0,0);
Screen('TextSize',woff,tSize);

DrawText(woff,{'POINTS'},TextColors,20,100,0);
DrawText(woff,{'MOLE TYPE'},TextColors,125,100,0);

PointColor = [255 0 0; 128 128 128; 0 255 0];
tgtHalf = TargetSize/2;
iconLEdge = 200-tgtHalf;
iconREdge = 200+tgtHalf;

% Table of Mole Types and Points
Screen('DrawLine',woff,[255 255 255], 20, tgtHalf+100, 250, tgtHalf+100);
for moleTypeNum = 1:6
    myPts = OutComePlayers(1,moleTypeNum);
    myOffset = 100+moleTypeNum*TargetSize;
    DrawText(woff,{num2str(myPts)},{PointColor(myPts+2,:)},50,myOffset,0,0);
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
DrawText(woff,{'spacebar to start'},{[127 127 127]},75,ScrRes(2)-75,0,0);


Screen('FillRect', window, BGCol); % draw background
Screen('FrameRect',woff);
DrawMirrored(window, woff,woff, ScrRes,1);  % draw instructions on both sides
Screen('Flip', window);
WaitForKeyPress({'SPACE'});


Screen('FillRect', window, BGCol); % draw background
Screen('Flip', window);

%% initiate finger tracker

if ( ExpMode > 0 )
    tracker(0,RecordHz);         % make sure it's off
    data = tracker(5,RecordHz);  % start tracker; throw away data
end

SwitchSides = -1;
ScorePlayers     = zeros(2,nMaxTrials);
MoneyPlayers     = [0 0];
PlayerContinues  = zeros(1,nMaxTrials); % this variable checks who presses the continue button, 1 = left, 2 = right

if ( startTrialNum > 1 )
    MatData = load([dirname ppname '_t' num2str(startTrialNum-1) '_e' num2str(ExpNum)]); % LOAD DATA BEFORE CRASH

    ScorePlayers     = MatData.ScorePlayers;
    MoneyPlayers     = MatData.MoneyPlayers;
    SwitchSides      = MatData.SwitchSides;
    if ( sum(startTrialNum == newBlockNums) > 0 )
        SwitchSides = -1;
    end
    clear MatData
    
    ScorePlayers(:,startTrialNum:end)  = 0;
end

endTrialNum = nMaxTrials;  %newBlockNums(find(newBlockNums<=startTrialNum,1,'last')+1)-1;

%% Trial loop
for TrlNum = startTrialNum:endTrialNum
   
   % show switch sides instructions    
    if sum(TrlNum == newBlockNums(2:end)) > 0
        DrawSwitchSidesInstruction;
        SwitchSides = -1*SwitchSides;
    end
    
%% load trial (timing, type, and location of targets)  

    nTargetOnsets       = 2*round(1000*TrialLength/(TargetPresTime+mean(TargetIntervalTimeRange)));
    TrialList           = cell(1,2);
    TrialList{1}        = zeros(MaxTargetsOnScreen,nTargetOnsets);
    TrialList{2}        = zeros(MaxTargetsOnScreen,nTargetOnsets);
    LocationListY       = cell(1,2);
    LocationListY{1}    = zeros(MaxTargetsOnScreen,nTargetOnsets);
    LocationListY{2}    = zeros(MaxTargetsOnScreen,nTargetOnsets);
    LocationListX       = cell(1,2);
    LocationListX{1}    = zeros(MaxTargetsOnScreen,nTargetOnsets);
    LocationListX{2}    = zeros(MaxTargetsOnScreen,nTargetOnsets);
    HitList_t           = cell(1,2); % timing of hitting the target
    HitList_t{1}        = zeros(MaxTargetsOnScreen,nTargetOnsets);
    HitList_t{2}        = zeros(MaxTargetsOnScreen,nTargetOnsets);
    HitList_p           = cell(1,2); % player idx who hit the target
    HitList_p{1}        = zeros(MaxTargetsOnScreen,nTargetOnsets);
    HitList_p{2}        = zeros(MaxTargetsOnScreen,nTargetOnsets);    
    MoleTypeList        = cell(1,2);
    MoleTypeList{1}     = zeros(MaxTargetsOnScreen,nTargetOnsets);
    MoleTypeList{2}     = zeros(MaxTargetsOnScreen,nTargetOnsets);
    TargetCoverageMap   = cell(1,2);
    TargetCoverageMap{1}= zeros(ScrRes(2),ScrRes(1));
    TargetCoverageMap{2}= zeros(ScrRes(2),ScrRes(1));
    TempCoverageMap     = zeros(TargetSize+1,TargetSize+1);
    TrackList           = cell(1,3);
    TrackList{1}        = NaN(3,TrialLength*RecordHz);
    TrackList{2}        = NaN(3,TrialLength*RecordHz);
    TrackList{3}        = NaN(1,TrialLength*RecordHz);
    
    PlayerLeftIdx   = (SwitchSides/2)+1.5; % NOTE THAT PLAYER LEFT DOES NOT HAVE TO BE PLAYER 1 (only at the beginning and after each 12 trials)
    PlayerRightIdx  = mod((SwitchSides/2)+1.5,2)+1;
    
    rng('shuffle');
    for i = 1:MaxTargetsOnScreen
         TrialList{PlayerLeftIdx}(i,:)  = i*(mean(TargetIntervalTimeRange)/MaxTargetsOnScreen) + cumsum(TargetPresTime+TargetIntervalTimeRange(1)+(TargetIntervalTimeRange(2)-TargetIntervalTimeRange(1))*rand(1,nTargetOnsets));
         TrialList{PlayerRightIdx}(i,:) = i*(mean(TargetIntervalTimeRange)/MaxTargetsOnScreen) + cumsum(TargetPresTime+TargetIntervalTimeRange(1)+(TargetIntervalTimeRange(2)-TargetIntervalTimeRange(1))*rand(1,nTargetOnsets));
         TrialList{PlayerLeftIdx}(i,:) = TrialList{PlayerRightIdx}(i,:); %%%%Alpha over Beta%%%%
         
         tempList    = cell(1,2);
         tempList{1} = [];
         templist{2} = [];
         for j = 1:ceil(nTargetOnsets/8)
            tempList{PlayerLeftIdx}  = [tempList{1} Shuffle([1 2 3 4 5 6 1 2])];  % this is wrong
            tempList{PlayerRightIdx} = [tempList{2} Shuffle([1 2 3 4 5 6 1 2])];
            tempList{PlayerLeftIdx} = tempList{PlayerRightIdx}; %%%%Alpha over Beta%%%%
            
         end
         MoleTypeList{PlayerLeftIdx}(i,:)  = tempList{PlayerLeftIdx}(1:nTargetOnsets);
         MoleTypeList{PlayerRightIdx}(i,:) = tempList{PlayerRightIdx}(1:nTargetOnsets);
    end
    
    rng('shuffle');
    nHistoryTargetOverlapCheck = 4; % number of iterations back into history to check for overlapping targets

    for j = 1:nTargetOnsets
        if j > nHistoryTargetOverlapCheck
            TargetCoverageMap{PlayerLeftIdx} = TargetCoverageMap{PlayerLeftIdx}-1;
            TargetCoverageMap{PlayerLeftIdx}(TargetCoverageMap{PlayerLeftIdx}(:)<0) = 0;
            TargetCoverageMap{PlayerRightIdx} = TargetCoverageMap{PlayerRightIdx}-1;
            TargetCoverageMap{PlayerRightIdx}(TargetCoverageMap{PlayerRightIdx}(:)<0) = 0;
            TargetCoverageNum = nHistoryTargetOverlapCheck;
        else
            TargetCoverageNum = j;
        end
        
        for i = 1:MaxTargetsOnScreen
            for p = 1:2  % player #
                proposedY = round(TargetSize+(HalfScrRes(2)-2*TargetSize)*rand(1,1));
                proposedYmin = proposedY - TargetSize/2;
                proposedYmax = proposedY + TargetSize/2;
                proposedX = round(TargetSize+(HalfScrRes(1)-2*TargetSize)*rand(1,1));
                proposedXmin = proposedX - TargetSize/2;
                proposedXmax = proposedX + TargetSize/2;
                TempCoverageMap = TargetCoverageMap{p}(proposedYmin:proposedYmax,proposedXmin:proposedXmax);
                while ( sum(TempCoverageMap(:))>0 )
                    proposedY  = round(TargetSize+(HalfScrRes(2)-2*TargetSize)*rand(1,1));
                    proposedYmin = proposedY - TargetSize/2;
                    proposedYmax = proposedY + TargetSize/2;
                    proposedX  = round(TargetSize+(HalfScrRes(1)-2*TargetSize)*rand(1,1));     
                    proposedXmin = proposedX - TargetSize/2;
                    proposedXmax = proposedX + TargetSize/2;
                    TempCoverageMap = TargetCoverageMap{p}(proposedYmin:proposedYmax,proposedXmin:proposedXmax);
                end
                TargetCoverageMap{p}(proposedYmin:proposedYmax,proposedXmin:proposedXmax) = TargetCoverageMap{p}(proposedYmin:proposedYmax,proposedXmin:proposedXmax)+TargetCoverageNum;
                LocationListY{p}(i,j)  = proposedY;
                LocationListX{p}(i,j)  = proposedX;
            end
        end        
    end
    
    LocationListX{PlayerLeftIdx}=LocationListX{PlayerRightIdx}; %%%%Alpha over Beta%%%%
    LocationListY{PlayerLeftIdx}=LocationListY{PlayerRightIdx}; %%%%Alpha over Beta%%%%
    
    for i = 3:-1:1
        Text = {'',...
            'Get ready!',...
            '',...
            };

        Screen('FillRect', woff, BGCol); % draw background        
        DrawText(woff,Text,TextColors,50,ScrRes(2)/4,0,0);
        DrawText(woff,{num2str(i)},TextColors,80,ScrRes(2)/3,0);
        Screen('FrameRect',woff);
        DrawMirrored(window,woff,woff,ScrRes,1);
        Screen('Flip', window);
        WaitSecs(0.5);
    end
    
    %% start trial

    if ( ExpMode > 0 )
        data = tracker(5,RecordHz);
    else
        data = ones(5,2);
    end
    trackedNow = GetSecs;
    TimeStampTrackerLeft    = data(2,1)-1;
    vbl = Screen('Flip', window);
        
    tStart          = GetSecs;
    dataCount       = 0;
    targetNum       = ones(2,MaxTargetsOnScreen);
    targetHit       = zeros(2,MaxTargetsOnScreen);
    playerHit       = zeros(2,MaxTargetsOnScreen);
    targetShown     = zeros(2,MaxTargetsOnScreen);
    targetFeedback = cell(1,2);
    targetFeedback{1} = [];
    targetFeedback{2} = [];
    x = [0 0]; y = [0 0]; z = [0 0]; side = [0 0]; pWin = [0 0]; % indexable by Left/Right-PlayerIdx
    while ( (GetSecs-tStart < TrialLength) && ~KbCheck)
        
        Screen('FillRect', window, BGCol); % draw background
        Screen('FillRect', woff1, [0 0 0 0]); % clear bg for pane 1
        Screen('FillRect', woff2, [0 0 0 0]); % clear bg for feedback pane 2
        Screen('FrameRect',woff1);
        Screen('FrameRect',woff2);
        pWin(PlayerLeftIdx)  = woff1;
        pWin(PlayerRightIdx) = woff2;
        
        tFrame = GetSecs;
        while GetSecs-tFrame < (1/ScrHz)
            
            % present or remove targets from screen
            for i = 1:MaxTargetsOnScreen
                tElapsed = (GetSecs-tStart)*1000;
                for p = [PlayerLeftIdx PlayerRightIdx]
                    TimeDiff = round((tElapsed-TrialList{p}(i,targetNum(p,i))));
                    if targetHit(p,i) > 0 
                        HitList_t{p}(i,targetNum(p,i)) = tElapsed/1000;
                        HitList_p{p}(i,targetNum(p,i)) = playerHit(p,i);
                        targetNum(p,i) = targetNum(p,i)+1; % get next target for presentation after a hit
                        targetHit(p,i) = 0;
                        playerHit(p,i) = 0;
                        targetShown(p,i) = 0;
                    elseif TimeDiff >= TargetPresTime % target is missed
                        targetNum(p,i) = targetNum(p,i)+1;
                        targetShown(p,i) = 0;
                    elseif TimeDiff > 0 && TimeDiff < TargetPresTime % show target
                        tempColor = TargetColors(MoleTypeList{p}(i,targetNum(p,i)),:);
                        tempColor = round(tempColor.*((TargetPresTime/2)-abs(TimeDiff-(TargetPresTime/2)))/(TargetPresTime/2));
                        Screen('FillOval', pWin(p), tempColor, CenterSq(LocationListX{p}(i,targetNum(p,i)),LocationListY{p}(i,targetNum(p,i)),TargetSize), TargetSize+2);
                        targetShown(p,i) = 1;
                    else
                        targetShown(p,i) = 0;
                    end
                end  % check each player's i'th target separately                
            end
            
            WaitSecs('UntilTime', trackedNow+1/RecordHz);  % avoid buffer underflow
            trackedNow = GetSecs;
            if ( ExpMode > 0 )
                % data = tracker(5,RecordHz);
                [data, ~, bytes_read] = ReadPnoRTAllML_ver4(5);
            else
                data = ones(5,2);
                bytes_read = 48;
            end

            if ( IsTrackerPacketOK(data, bytes_read) )   % don't process invalid data
                dataCount = dataCount + 1;
                [xPos1, yPos1, zPos1] = TransformSensorData(data(:,1), T_SB1, in2px);
                [xPos2, yPos2, zPos2] = TransformSensorData(data(:,2), T_SB2, in2px);
                TrackList{PlayerLeftIdx}(:,dataCount)  = [xPos1; yPos1; zPos1];
                TrackList{PlayerRightIdx}(:,dataCount) = [xPos2; yPos2; zPos2];
                TrackList{3}(1,dataCount)              = data(2,1)-TimeStampTrackerLeft;
                            
                xPos1orig = xPos1;
                yPos1orig = yPos1;
                xPos2orig = xPos2;
                yPos2orig = yPos2;
                % Split Board: ensure players stay on their own sides
                if ( xPos1 < HalfScrRes(1) )    % PlayerLeft has strayed across the line; reset to origin
                    % we'll draw a red warning circle later
                    xPos1 = 0;
                    yPos1 = 0;
                end
                if ( xPos2 > HalfScrRes(1) )    % PlayerRight has strayed across the line; reset to origin
                    % we'll draw a blue warning circle later
                    xPos2 = 0;
                    yPos2 = 0;
                end

                % Split Board: now remap PlayerLeft to PlayerRight coordinates
                xPos1 = ScrRes(1)-xPos1;
                yPos1 = ScrRes(2)-yPos1;
                
                side(PlayerLeftIdx)  = 1;
                side(PlayerRightIdx) = 2;
                x(PlayerLeftIdx) = xPos1;
                x(PlayerRightIdx)= xPos2;
                y(PlayerLeftIdx) = yPos1;
                y(PlayerRightIdx)= yPos2;
                z(PlayerLeftIdx) = zPos1;
                z(PlayerRightIdx)= zPos2;
              % check whether target is hit
              for i = 1:MaxTargetsOnScreen
                for p = [PlayerLeftIdx PlayerRightIdx]  % scoring each board separately
                    Hit=0;
                    if ( targetShown(p,i) ) % only if target is really presented
                        Hit = z(p) < maxZ & LocationListX{p}(i,targetNum(p,i)) > x(p)-HitSize/2 & LocationListX{p}(i,targetNum(p,i)) < x(p)+HitSize/2 & LocationListY{p}(i,targetNum(p,i)) > y(p)-HitSize/2 & LocationListY{p}(i,targetNum(p,i)) < y(p)+HitSize/2;
                    end
                    if ( Hit )
                        targetHit(p,i) = side(p); % 1 for player left, 2 for player right, 0 if not hit
                        playerHit(p,i) = p;
                        targetFeedback{p}(1:2,end+1) = [LocationListX{p}(i,targetNum(p,i)) LocationListY{p}(i,targetNum(p,i))];
                        targetFeedback{p}(3,end) = GetSecs;  %% should this be in tracker time?
                        targetFeedback{p}(4,end) = targetHit(p,i);
                        targetFeedback{p}(5,end) = targetNum(p,i);
                        targetFeedback{p}(6,end) = i;
                    else
                        targetHit(p,i) = 0;
                    end
                end  % for p (scoring each board separately)

                % if target(s) hit, change score
                if ( sum(targetHit(:,i)) > 0 )
                    % if runmirrored & both players hit, decide who was closer (or random) & remove credit from later player
                    if ExpNum==2 
                        if targetHit(1,i) && targetHit(2,i)
                            if z(1) < z(2)
                                playerHit(2,i) = 0;  %%%%%%%%%%%%%% what should this do? 0 or 1? or just go away?
                                targetFeedback{2} = targetFeedback{2}(1:end-1);
                            elseif z(1) > z(2)
                                playerHit(1,i) = 0;  %%%%%%%%%%%%%% what should this do? 0 for scoring?
                                targetFeedback{1} = targetFeedback{1}(1:end-1);
                            end  % else they both get credit
                        elseif targetHit(1,i)
                            targetHit(2,i) = targetHit(1,i);   % force advance to the next target
                        elseif targetHit(2,i)
                            targetHit(1,i) = targetHit(2,i);   % force advance... is this working???
                        end %if competitive mirroring
                    end  % if anything got hit
                    for p = [PlayerLeftIdx PlayerRightIdx]   % score separately
                        if (playerHit(p,i))
                            ScorePlayers(playerHit(p,i),TrlNum) = ScorePlayers(playerHit(p,i),TrlNum)+OutComePlayers(1,MoleTypeList{p}(i,targetNum(p,i)));
                        end
                    end
                end

              end
            else
                xPos1orig=0; yPos1orig=0; xPos2orig=0; yPos2orig=0;
            end   % processing of valid tracker data
        end   % 1/ScrHz while loop

        if ( xPos1orig < HalfScrRes(1) )    % PlayerLeft has strayed across the line
            Screen('FrameOval', window, [0 0 255], CenterSq(xPos1orig,yPos1orig,HitSize) );
        else
%             Screen('FrameOval', window, [255 255 255], CenterSq(xPos1orig,yPos1orig,HitSize) );
%             Screen('FrameOval', window, [255 255 255], CenterSq(xPos1orig,yPos1orig,10) );
%             DrawText(window,{num2str(zPos1)},{[255 255 255]},20,25,0,0); 
        end
        if ( xPos2orig > HalfScrRes(1) )    % PlayerRight has strayed across the line
            Screen('FrameOval', window, [255 0 0], CenterSq(xPos2orig,yPos2orig,HitSize) );
        else
%             Screen('FrameOval', window, [255 255 255], CenterSq(xPos2orig,yPos2orig,HitSize) );
%             Screen('FrameOval', window, [255 255 255], CenterSq(xPos2orig,yPos2orig,10) );
%             DrawText(window,{num2str(zPos2)},{[255 255 255]},20,125,0,0);
        end

        % check whether feedback should be presented about target hit
        for p = [PlayerLeftIdx PlayerRightIdx]  % check each feedback list separately
            i = 1;
            while i <= size(targetFeedback{p},2)
                if ( GetSecs-targetFeedback{p}(3,i) > FeedBackDuration ) % remove because feedback is over
                    targetFeedback{p} = [targetFeedback{p}(:,1:i-1) targetFeedback{p}(:,i+1:end)];
                elseif ( GetSecs-targetFeedback{p}(3,i) <= FeedBackDuration && targetFeedback{p}(3,i)~= 0 ) % show feedback
                    tF_x = targetFeedback{p}(1,i);
                    tF_y = targetFeedback{p}(2,i);
                    tF_side = targetFeedback{p}(4,i);
                    tF_tNum = targetFeedback{p}(5,i);
                    tF_i = targetFeedback{p}(6,i);
                    targetArea = [tF_x-fbsc*TargetSize/2 tF_y tF_x+fbsc*TargetSize/2 tF_y+fbsc*TargetSize/2; 
                                  tF_x-fbsc*TargetSize/2 tF_y-fbsc*TargetSize/2 tF_x+fbsc*TargetSize/2 tF_y];
                    % Select FeedbackArrow parts
                    P1rect = fbArrowRect(tF_side, :, MoleTypeList{p}(tF_i, tF_tNum));
                    P2rect = fbArrowRect(mod(tF_side,2)+1, :, MoleTypeList{p}(tF_i, tF_tNum));
                    fbAngle = 180*(tF_side-1);
                    % add feedback to proper side's window
                    if (tF_side==1)
                        Screen('DrawTexture', woff1, winfb, P1rect, targetArea(1,:),fbAngle);
                        Screen('DrawTexture', woff1, winfb, P2rect, targetArea(2,:),fbAngle);
                        Screen('DrawTexture', woff2, winfb, P2rect, targetArea(1,:),fbAngle+180);
                        Screen('DrawTexture', woff2, winfb, P1rect, targetArea(2,:),fbAngle+180);
                    elseif (tF_side==2)
                        Screen('DrawTexture', woff2, winfb, P1rect, targetArea(2,:),fbAngle+180);
                        Screen('DrawTexture', woff2, winfb, P2rect, targetArea(1,:),fbAngle+180);
                        Screen('DrawTexture', woff1, winfb, P2rect, targetArea(2,:),fbAngle);
                        Screen('DrawTexture', woff1, winfb, P1rect, targetArea(1,:),fbAngle);
                    end
                    i = i + 1;
                end
            end
        end  % for p (check feedback lists separately)
    	% draw feedback panes & games directly onto projected window
        DrawMirrored(window, woff1, woff2, ScrRes);
        
        % show updated screen
        vbl = Screen('Flip', window, vbl+0.5*(1/ScrHz), [], 1); 
    end  %%% timepoints loop (for M timepoints within a trial)

    if (GetSecs-tStart < TrialLength)  % keypress to quit game
        Screen('DrawText',window,'Quitting due to keypress',ScrRes(1)/2-100,ScrRes(2)/2,[255 255 255]);
        Screen('Flip', window);
        WaitSecs(0.5);
        break  % exit the outer trial loop
    end
    
    Screen('FillRect', window, BGCol); % draw background
    Screen('Flip', window);
    
    if ( ExpMode > 0 )
        tracker(0,RecordHz);
    end    
    
    Screen('FillRect', woff1, [0 0 0 0]); % black bg for feedback pane
    Screen('FrameRect',woff1);
    Screen('FillRect', woff2, [0 0 0 0]); % black bg for feedback pane
    Screen('FrameRect',woff2);

    PlayerLeftScore = ScorePlayers(PlayerLeftIdx,TrlNum);
    PlayerRightScore = ScorePlayers(PlayerRightIdx,TrlNum);
    if (PlayerLeftScore > PlayerRightScore )
        DrawText(woff1,{'YOU WIN!'},{[0 255 0]},0.5*ScrRes(1)/6,ScrRes(2)/6,0);
        DrawText(woff2,{'YOU LOSE!'},{[255 0 0]},0.5*ScrRes(1)/6,ScrRes(2)/6,0);        
        DrawText(woff1,{['YOUR SCORE IS  ' num2str(PlayerLeftScore)]},{[0 255 0]},0.5*ScrRes(1)/6,ScrRes(2)/3,0);
        DrawText(woff1,{['YOUR OPPONENT GOT  ' num2str(PlayerRightScore)]},{[255 0 0]},0.5*ScrRes(1)/6,2*ScrRes(2)/3,0);
        DrawText(woff2,{['YOUR SCORE IS  ' num2str(PlayerRightScore)]},{[255 0 0]},0.5*ScrRes(1)/6,ScrRes(2)/3,0);
        DrawText(woff2,{['YOUR OPPONENT GOT  ' num2str(PlayerLeftScore)]},{[0 255 0]},0.5*ScrRes(1)/6,2*ScrRes(2)/3,0);
        MoneyPlayers(PlayerLeftIdx) = MoneyPlayers(PlayerLeftIdx)+0.8;
    elseif ( PlayerLeftScore < PlayerRightScore )
        DrawText(woff1,{'YOU LOSE!'},{[255 0 0]},0.5*ScrRes(1)/6,ScrRes(2)/6,0);
        DrawText(woff2,{'YOU WIN!'},{[0 255 0]},0.5*ScrRes(1)/6,ScrRes(2)/6,0);      
 	    DrawText(woff1,{['YOUR SCORE IS  ' num2str(PlayerLeftScore)]},{[255 0 0]},0.5*ScrRes(1)/6,ScrRes(2)/3,0);
       	DrawText(woff1,{['YOUR OPPONENT GOT  ' num2str(PlayerRightScore)]},{[0 255 0]},0.5*ScrRes(1)/6,2*ScrRes(2)/3,0);
      	DrawText(woff2,{['YOUR SCORE IS  ' num2str(PlayerRightScore)]},{[0 255 0]},0.5*ScrRes(1)/6,ScrRes(2)/3,0);
       	DrawText(woff2,{['YOUR OPPONENT GOT  ' num2str(PlayerLeftScore)]},{[255 0 0]},0.5*ScrRes(1)/6,2*ScrRes(2)/3,0);
        MoneyPlayers(PlayerRightIdx) = MoneyPlayers(PlayerRightIdx)+0.8;
    else % draw
        DrawText(woff1,{'DRAW!'},{[0 0 255]},0.5*ScrRes(1)/6,ScrRes(2)/6,0);
        DrawText(woff2,{'DRAW!'},{[0 0 255]},0.5*ScrRes(1)/6,ScrRes(2)/6,0);       
        DrawText(woff1,{['YOUR SCORE IS  ' num2str(PlayerLeftScore)]},{[0 0 255]},0.5*ScrRes(1)/6,ScrRes(2)/3,0);
        DrawText(woff1,{['YOUR OPPONENT GOT  ' num2str(PlayerRightScore)]},{[0 0 255]},0.5*ScrRes(1)/6,2*ScrRes(2)/3,0);
        DrawText(woff2,{['YOUR SCORE IS  ' num2str(PlayerRightScore)]},{[0 0 255]},0.5*ScrRes(1)/6,ScrRes(2)/3,0);
        DrawText(woff2,{['YOUR OPPONENT GOT  ' num2str(PlayerLeftScore)]},{[0 0 255]},0.5*ScrRes(1)/6,2*ScrRes(2)/3,0);
        MoneyPlayers(PlayerLeftIdx) = MoneyPlayers(PlayerLeftIdx)+0.4;
        MoneyPlayers(PlayerRightIdx) = MoneyPlayers(PlayerRightIdx)+0.4;
    end
    
    %%%%%%%%%%%%%%%%%%%%% SAVE DATA 
    save([dirname ppname '_t' num2str(TrlNum) '_e' num2str(ExpNum),'.mat']); % SAVE DATA
    %%%%%%%%%%%%%%%%%%%%%
    
%     disp('Participants read score results');        
    DrawMirrored(window, woff1, woff2,ScrRes,1)
    Screen('Flip', window);

    if ( ExpMode > 0 )
        data = tracker(5,RecordHz);  % throw data away
    end
    
    %% "next game" button created
    AreaOfInterest = [20 ScrRes(2)-50 ScrRes(1)/2-20 ScrRes(2)-10];
    Screen('FrameRect', window, [255 255 255], AreaOfInterest);
    DrawText(window,{' NEXT GAME '},TextColors,AreaOfInterest(1)+50,AreaOfInterest(2)+10,0,0);
    Screen('Flip', window);
        
    if ( ExpMode > 0 )
        continueHit = 0;
        while continueHit==0
            data = tracker(5,RecordHz); % check for "next" button tap
            [xPos1, yPos1, zPos1] = TransformSensorData(data(:,1),T_SB1, in2px);
            [xPos2, yPos2, zPos2] = TransformSensorData(data(:,2),T_SB2, in2px);  
            if ( yPos1 < AreaOfInterest(4) && yPos1 > AreaOfInterest(2) && xPos1 > AreaOfInterest(1) && xPos1 < AreaOfInterest(3) && zPos1 < maxZ )
                PlayerContinues(TrlNum) = PlayerLeftIdx;
                continueHit = 1;
                trHit = 1;
                xHit = xPos1;
                yHit = yPos1;
            elseif ( yPos2 < AreaOfInterest(4) && yPos2 > AreaOfInterest(2) && xPos2 > AreaOfInterest(1) && xPos2 < AreaOfInterest(3) && zPos2 < maxZ )
                PlayerContinues(TrlNum) = PlayerRightIdx;
                continueHit = 1;
                trHit = 2;
                xHit = xPos2;
                yHit = yPos2;
            end
        end
    else
        WaitForKeyPress({'SPACE'});
        trHit = 1;
        xHit = 50;
        yHit = 50;
    end    
    Screen('FillRect', window, BGCol); % draw background
    DrawText(window,{'LOADING'},TextColors,AreaOfInterest(1)+50,AreaOfInterest(2)+10,0,0);
    
    % Draw arrow toward continuing player
    targetArea = [xHit-fbsc*TargetSize/2 yHit xHit+fbsc*TargetSize/2 yHit+fbsc*TargetSize/2;
                  xHit-fbsc*TargetSize/2 yHit-fbsc*TargetSize/2 xHit+fbsc*TargetSize/2 yHit];    
    fbAngle = 180*(trHit-1);
    Screen('DrawTexture', window, winfb, fbArrowRect(trHit,:,1), targetArea(1,:),fbAngle);
    Screen('DrawTexture', window, winfb, fbArrowRect(mod(trHit,2)+1,:,1), targetArea(2,:),fbAngle);    
    Screen('Flip', window);

end  %%%%%% trial loop (for N trials)

%% end of the block of games, or end of the expt
if ( ExpMode > 0 )
    tracker(0,RecordHz);
end

%% end message
Screen('FillRect', window, BGCol); % draw background
Screen('FillRect', woff, BGCol); % draw background

if ( TrlNum == nMaxTrials )
    Text = {'FINISHED!','Thanks for playing!'};
    DrawText(window,Text,{[0 255 0]},100,200,0);
    DrawText(woff,Text,{[0 255 0]},100,200,0);    
else
    Text = {'The experiment needs to be restarted!','Call the experimenter'};
    DrawText(window,Text,TextColors,20,20,0);
    DrawText(woff,Text,TextColors,20,20,0);    
end

Screen('DrawTexture', window, woff, [], [ScrRes(1)/2 0 ScrRes(1) ScrRes(2)], 180);
Screen('Flip', window);
WaitSecs(5);
Screen('FillRect', window, BGCol); % draw background
Screen('Flip', window);

ShowCursor('Arrow');
%ListenChar(0);
Screen CloseAll;
home;
