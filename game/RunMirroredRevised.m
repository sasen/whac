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
calcorners(:,:,1) = [    4.8078   13.9688   23.1681
    5.0142   14.2244   23.5174
    5.2643   14.4456   23.8417];

calcorners(:,:,2) =[    0.5527    0.8864    1.2118
   -6.2717   -5.9730   -5.6018
  -13.3088  -13.0224  -12.7822];


calcorners(:,:,3) = [
    8.9273    8.8635    8.5339
    9.2165    9.0977    8.7652
    9.5305    9.3808    8.8094];
% calcorners = NaN(3,3,3);
% calcorners(:,:,1) = [4.5914   13.8926   23.1742
%                     5.0000   14.2434   23.5634
%                     5.2680   14.4818   23.8340];
%                      
% calcorners(:,:,2) = [0.0217    0.4300    0.9884
%                     -6.7067   -6.3475   -5.8403
%                     -13.6602  -13.3281  -12.8529];
%                      
% calcorners(:,:,3) = [9.2613    9.2640    9.0308
%                     9.5755    9.5183    9.2453
%                     9.8692    9.7699    9.3148];

fitval = [];
% fitval(1,:) = polyfit(nanmean(calcorners(:,:,1)),nanmean(calcorners(:,:,2)),1);
% fitval(2,:) = polyfit(nanmean(calcorners(:,:,2),2),nanmean(calcorners(:,:,1),2),1);
fitval(1,:) = (regress((nanmean(calcorners(:,:,2)))',[(nanmean(calcorners(:,:,1)))',[1;1;1]]))';
fitval(2,:) = (regress(nanmean(calcorners(:,:,1),2),[nanmean(calcorners(:,:,2),2),[1;1;1]]))';

maxZ = 10;
 
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

%% open screens

[window, windowRect] = InitializeScreens(ScrNum,BGCol,1);
%% IF ABOVE LINE PRODUCES ERROR, REMEMBER TO addpath('MatlabFunctions')!

%% Initialization

%InitializeScreenPref(window,ExpMode,ScrHz,ScrRes); % too cavalier
InitializeTextPref(window,16,'Helvetica',1);

[newClutTable, oldClutTable] = CorrectClut(ScrNum);

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
    TempCoverageMap     = cell(1,2);
    TempCoverageMap{1}  = zeros(ScrRes(2),ScrRes(1));
    TempCoverageMap{2}  = zeros(ScrRes(2),ScrRes(1));
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
            tempList{PlayerLeftIdx}  = [tempList{1} Shuffle([1 2 3 4 5 6 1 2])];
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
            LocationListY{PlayerLeftIdx}(i,j)  = round(TargetSize+(HalfScrRes(2)-2*TargetSize)*rand(1,1));
            LocationListY{PlayerRightIdx}(i,j) = round(TargetSize+(HalfScrRes(2)-2*TargetSize)*rand(1,1));
            LocationListX{PlayerLeftIdx}(i,j)  = round(TargetSize+(HalfScrRes(1)-2*TargetSize)*rand(1,1));
            LocationListX{PlayerRightIdx}(i,j) = round(TargetSize+(HalfScrRes(1)-2*TargetSize)*rand(1,1));
            TempCoverageMap{PlayerLeftIdx}     = TargetCoverageMap{PlayerLeftIdx}(LocationListY{PlayerLeftIdx}(i,j)-TargetSize/2:LocationListY{PlayerLeftIdx}(i,j)+TargetSize/2,LocationListX{PlayerLeftIdx}(i,j)-TargetSize/2:LocationListX{PlayerLeftIdx}(i,j)+TargetSize/2);
            TempCoverageMap{PlayerRightIdx}    = TargetCoverageMap{PlayerRightIdx}(LocationListY{PlayerRightIdx}(i,j)-TargetSize/2:LocationListY{PlayerRightIdx}(i,j)+TargetSize/2,LocationListX{PlayerRightIdx}(i,j)-TargetSize/2:LocationListX{PlayerRightIdx}(i,j)+TargetSize/2);
            while ( sum(TempCoverageMap{PlayerLeftIdx}(:))>0 )
                LocationListY{PlayerLeftIdx}(i,j)  = round(TargetSize+(HalfScrRes(2)-2*TargetSize)*rand(1,1));
                LocationListY{PlayerRightIdx}(i,j) = round(TargetSize+(HalfScrRes(2)-2*TargetSize)*rand(1,1));
                LocationListX{PlayerLeftIdx}(i,j)  = round(TargetSize+(HalfScrRes(1)-2*TargetSize)*rand(1,1));     
                LocationListX{PlayerRightIdx}(i,j) = round(TargetSize+(HalfScrRes(1)-2*TargetSize)*rand(1,1));
                leftX1 = LocationListX{PlayerLeftIdx}(i,j)-TargetSize/2;
                leftX2 = LocationListX{PlayerLeftIdx}(i,j)+TargetSize/2;
                leftY1 = LocationListY{PlayerLeftIdx}(i,j)-TargetSize/2;
                leftY2 = LocationListY{PlayerLeftIdx}(i,j)+TargetSize/2;
                TempCoverageMap{PlayerLeftIdx}     = TargetCoverageMap{PlayerLeftIdx}(leftY1:leftY2,leftX1:leftX2);
                TempCoverageMap{PlayerRightIdx}    = TargetCoverageMap{PlayerRightIdx}(LocationListY{PlayerRightIdx}(i,j)-TargetSize/2:LocationListY{PlayerRightIdx}(i,j)+TargetSize/2,LocationListX{PlayerRightIdx}(i,j)-TargetSize/2:LocationListX{PlayerRightIdx}(i,j)+TargetSize/2);
            end
            while ( sum(TempCoverageMap{PlayerRightIdx}(:))>0 )
                LocationListY{PlayerLeftIdx}(i,j)  = round(TargetSize+(HalfScrRes(2)-2*TargetSize)*rand(1,1));
                LocationListY{PlayerRightIdx}(i,j) = round(TargetSize+(HalfScrRes(2)-2*TargetSize)*rand(1,1));
                LocationListX{PlayerLeftIdx}(i,j)  = round(TargetSize+(HalfScrRes(1)-2*TargetSize)*rand(1,1));     
                LocationListX{PlayerRightIdx}(i,j) = round(TargetSize+(HalfScrRes(1)-2*TargetSize)*rand(1,1));                
                TempCoverageMap{PlayerLeftIdx}     = TargetCoverageMap{PlayerLeftIdx}(LocationListY{PlayerLeftIdx}(i,j)-TargetSize/2:LocationListY{PlayerLeftIdx}(i,j)+TargetSize/2,LocationListX{PlayerLeftIdx}(i,j)-TargetSize/2:LocationListX{PlayerLeftIdx}(i,j)+TargetSize/2);
                TempCoverageMap{PlayerRightIdx}    = TargetCoverageMap{PlayerRightIdx}(LocationListY{PlayerRightIdx}(i,j)-TargetSize/2:LocationListY{PlayerRightIdx}(i,j)+TargetSize/2,LocationListX{PlayerRightIdx}(i,j)-TargetSize/2:LocationListX{PlayerRightIdx}(i,j)+TargetSize/2);
            end                
            TargetCoverageMap{PlayerLeftIdx}(LocationListY{PlayerLeftIdx}(i,j)-TargetSize/2:LocationListY{PlayerLeftIdx}(i,j)+TargetSize/2,LocationListX{PlayerLeftIdx}(i,j)-TargetSize/2:LocationListX{PlayerLeftIdx}(i,j)+TargetSize/2) = TargetCoverageMap{PlayerLeftIdx}(LocationListY{PlayerLeftIdx}(i,j)-TargetSize/2:LocationListY{PlayerLeftIdx}(i,j)+TargetSize/2,LocationListX{PlayerLeftIdx}(i,j)-TargetSize/2:LocationListX{PlayerLeftIdx}(i,j)+TargetSize/2)+TargetCoverageNum;
            TargetCoverageMap{PlayerRightIdx}(LocationListY{PlayerRightIdx}(i,j)-TargetSize/2:LocationListY{PlayerRightIdx}(i,j)+TargetSize/2,LocationListX{PlayerRightIdx}(i,j)-TargetSize/2:LocationListX{PlayerRightIdx}(i,j)+TargetSize/2) = TargetCoverageMap{PlayerRightIdx}(LocationListY{PlayerRightIdx}(i,j)-TargetSize/2:LocationListY{PlayerRightIdx}(i,j)+TargetSize/2,LocationListX{PlayerRightIdx}(i,j)-TargetSize/2:LocationListX{PlayerRightIdx}(i,j)+TargetSize/2)+TargetCoverageNum;
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
    TimeStampTrackerRight   = data(2,2)-1;
    
    vbl = Screen('Flip', window);
    
    targetFeedback = [];
    
    tStart          = GetSecs;
    dataCount       = 0;
    targetNum       = ones(2,MaxTargetsOnScreen);
    targetHit       = zeros(2,MaxTargetsOnScreen);
    playerHit       = zeros(2,MaxTargetsOnScreen);
    targetShown     = zeros(2,MaxTargetsOnScreen);
    while ( (GetSecs-tStart < TrialLength) && ~KbCheck)
        
        Screen('FillRect', window, BGCol); % draw background
        Screen('FillRect', woff1, [0 0 0 0]); % clear bg for pane 1
        Screen('FillRect', woff2, [0 0 0 0]); % clear bg for feedback pane 2
        Screen('FrameRect',woff1);
        Screen('FrameRect',woff2);
        
        tFrame = GetSecs;
        while GetSecs-tFrame < (1/ScrHz)
            
            % present or remove targets from screen
            for i = 1:MaxTargetsOnScreen
                tElapsed = (GetSecs-tStart)*1000;
                TimeDiffL = round((tElapsed-TrialList{PlayerLeftIdx}(i,targetNum(PlayerLeftIdx,i))));
                TimeDiffR = round((tElapsed-TrialList{PlayerRightIdx}(i,targetNum(PlayerRightIdx,i))));

                % select next target for presentation after a target hit
                if targetHit(PlayerLeftIdx,i) > 0 
                    HitList_t{PlayerLeftIdx}(i,targetNum(PlayerLeftIdx,i)) = tElapsed/1000;
                    HitList_p{PlayerLeftIdx}(i,targetNum(PlayerLeftIdx,i)) = playerHit(PlayerLeftIdx,i);
                    targetNum(PlayerLeftIdx,i)   = targetNum(PlayerLeftIdx,i)+1;
                    targetHit(PlayerLeftIdx,i)   = 0;
                    playerHit(PlayerLeftIdx,i)   = 0;
                    targetShown(PlayerLeftIdx,i) = 0;
                elseif TimeDiffL >= TargetPresTime % target is missed
                    targetNum(PlayerLeftIdx,i)   = targetNum(PlayerLeftIdx,i)+1;
                    targetShown(PlayerLeftIdx,i) = 0;
                elseif TimeDiffL > 0 && TimeDiffL < TargetPresTime % show target
                    tempColor = TargetColors(MoleTypeList{PlayerLeftIdx}(i,targetNum(PlayerLeftIdx,i)),:);
                    tempColor = round(tempColor.*((TargetPresTime/2)-abs(TimeDiffL-(TargetPresTime/2)))/(TargetPresTime/2));
                    Screen('FrameRect', woff1, tempColor, [LocationListX{PlayerLeftIdx}(i,targetNum(PlayerLeftIdx,i))-TargetSize/2 LocationListY{PlayerLeftIdx}(i,targetNum(PlayerLeftIdx,i))-TargetSize/2 LocationListX{PlayerLeftIdx}(i,targetNum(PlayerLeftIdx,i))+TargetSize/2 LocationListY{PlayerLeftIdx}(i,targetNum(PlayerLeftIdx,i))+TargetSize/2], TargetSize+2);
                    targetShown(PlayerLeftIdx,i) = 1;
                else
                    targetShown(PlayerLeftIdx,i) = 0;
                end
                
                % select next target for presentation after a target hit
                if targetHit(PlayerRightIdx,i) > 0 
                    HitList_t{PlayerRightIdx}(i,targetNum(PlayerRightIdx,i)) = tElapsed/1000;
                    HitList_p{PlayerRightIdx}(i,targetNum(PlayerRightIdx,i)) = playerHit(PlayerRightIdx,i);
                    targetNum(PlayerRightIdx,i) = targetNum(PlayerRightIdx,i)+1;
                    targetHit(PlayerRightIdx,i)   = 0;
                    playerHit(PlayerRightIdx,i)   = 0;
                    targetShown(PlayerRightIdx,i) = 0;
                elseif TimeDiffR >= TargetPresTime % target is missed
                    targetNum(PlayerRightIdx,i) = targetNum(PlayerRightIdx,i)+1;
                    targetShown(PlayerRightIdx,i) = 0;
                elseif TimeDiffR > 0 && TimeDiffR < TargetPresTime % show target
                    tempColor = TargetColors(MoleTypeList{PlayerRightIdx}(i,targetNum(PlayerRightIdx,i)),:);
                    tempColor = round(tempColor.*((TargetPresTime/2)-abs(TimeDiffR-(TargetPresTime/2)))/(TargetPresTime/2));
                    Screen('FrameOval', woff2, tempColor, [LocationListX{PlayerRightIdx}(i,targetNum(PlayerRightIdx,i))-TargetSize/2 LocationListY{PlayerRightIdx}(i,targetNum(PlayerRightIdx,i))-TargetSize/2 LocationListX{PlayerRightIdx}(i,targetNum(PlayerRightIdx,i))+TargetSize/2 LocationListY{PlayerRightIdx}(i,targetNum(PlayerRightIdx,i))+TargetSize/2], TargetSize+2);
                    targetShown(PlayerRightIdx,i) = 1;
                else
                    targetShown(PlayerRightIdx,i) = 0;
                end

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
                [xPos1, yPos1, zPos1, xPos2, yPos2, zPos2] = TransformTrackerData(data,calcorners,ScrRes,fitval);
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
                
                % check whether target is hit
                for i = 1:MaxTargetsOnScreen
                    LeftPlayerHit=0;
                    RightPlayerHit=0;
                    if ( targetShown(PlayerLeftIdx,i) == 1 ) % only if target is really presented
                        %%% TODO checkout this maxZ strategy!!!
                        LeftPlayerHit   = zPos1 < maxZ & LocationListX{PlayerLeftIdx}(i,targetNum(PlayerLeftIdx,i)) > xPos1-HitSize/2 & LocationListX{PlayerLeftIdx}(i,targetNum(PlayerLeftIdx,i)) < xPos1+HitSize/2 & LocationListY{PlayerLeftIdx}(i,targetNum(PlayerLeftIdx,i)) > yPos1-HitSize/2 & LocationListY{PlayerLeftIdx}(i,targetNum(PlayerLeftIdx,i)) < yPos1+HitSize/2;
                    end
                    if ( targetShown(PlayerRightIdx,i)== 1 )
                        RightPlayerHit  = zPos2 < maxZ & LocationListX{PlayerRightIdx}(i,targetNum(PlayerRightIdx,i)) > xPos2-HitSize/2 & LocationListX{PlayerRightIdx}(i,targetNum(PlayerRightIdx,i)) < xPos2+HitSize/2 & LocationListY{PlayerRightIdx}(i,targetNum(PlayerRightIdx,i)) > yPos2-HitSize/2 & LocationListY{PlayerRightIdx}(i,targetNum(PlayerRightIdx,i)) < yPos2+HitSize/2;
                    end
                        if ( LeftPlayerHit )
                            targetHit(PlayerLeftIdx,i) = 1; % 1 for player left, 2 for player right, 0 if not hit
                            playerHit(PlayerLeftIdx,i) = PlayerLeftIdx;
                            targetFeedback(1:2,end+1) = [LocationListX{PlayerLeftIdx}(i,targetNum(PlayerLeftIdx,i)) LocationListY{PlayerLeftIdx}(i,targetNum(PlayerLeftIdx,i))];
                            targetFeedback(3,end) = GetSecs;
                            targetFeedback(4,end) = targetHit(PlayerLeftIdx,i);
                            targetFeedback(5,end) = targetNum(PlayerLeftIdx,i);
                            targetFeedback(6,end) = i;
                        else
                            targetHit(PlayerLeftIdx,i) = 0;
                        end
                        if ( RightPlayerHit )
                            targetHit(PlayerRightIdx,i) = 2; % 1 for player left, 2 for player right, 0 if not hit
                            playerHit(PlayerRightIdx,i) = PlayerRightIdx;
                            targetFeedback(1:2,end+1) = [LocationListX{PlayerRightIdx}(i,targetNum(PlayerRightIdx,i)) LocationListY{PlayerRightIdx}(i,targetNum(PlayerRightIdx,i))];
                            targetFeedback(3,end) = GetSecs;
                            targetFeedback(4,end) = targetHit(PlayerRightIdx,i);
                            targetFeedback(5,end) = targetNum(PlayerRightIdx,i);
                            targetFeedback(6,end) = i;
                        else
                            targetHit(PlayerRightIdx,i) = 0;
                        end
                        % if target is hit, change score
                        if ( targetHit(i) > 0 ) %%%%%%%%%%%%%%%%%ASK SASEN%%%%%%%%%%%%%%%%
                            ScorePlayers(playerHit(i),TrlNum) = ScorePlayers(playerHit(i),TrlNum)+OutComePlayers(1,MoleTypeList(i,targetNum(i)));
                            ScorePlayers(mod(playerHit(i),2)+1,TrlNum) = ScorePlayers(mod(playerHit(i),2)+1,TrlNum)+OutComePlayers(2,MoleTypeList(i,targetNum(i)));
                        end
                end
            else
                xPos1orig=0; yPos1orig=0; xPos2orig=0; yPos2orig=0;
            end   % processing of valid tracker data
        end   % 1/ScrHz while loop

        if ( xPos1orig < HalfScrRes(1) )    % PlayerLeft has strayed across the line
            Screen('FrameOval', window, [0 0 255], CenterSq(xPos1orig,yPos1orig,HitSize) );
        else
            Screen('FrameOval', window, [255 255 255], CenterSq(xPos1orig,yPos1orig,HitSize) );
            Screen('FrameOval', window, [255 255 255], CenterSq(xPos1orig,yPos1orig,10) );
    %    	DrawText(window,{num2str(zPos1)},{[255 255 255]},20,25,0,0); 
        end
        if ( xPos2orig > HalfScrRes(1) )    % PlayerRight has strayed across the line
            Screen('FrameOval', window, [255 0 0], CenterSq(xPos2orig,yPos2orig,HitSize) );
        else
            Screen('FrameOval', window, [255 255 255], CenterSq(xPos2orig,yPos2orig,HitSize) );
            Screen('FrameOval', window, [255 255 255], CenterSq(xPos2orig,yPos2orig,10) );
    %		DrawText(window,{num2str(zPos2)},{[255 255 255]},20,125,0,0);
        end

        % check whether feedback should be presented about target hit
        i = 1;
        while i <= size(targetFeedback,2)
            if ( GetSecs-targetFeedback(3,i) > FeedBackDuration ) % remove because feedback is over
                targetFeedback = [targetFeedback(:,1:i-1) targetFeedback(:,i+1:end)];
            elseif ( GetSecs-targetFeedback(3,i) <= FeedBackDuration && targetFeedback(3,i)~= 0 ) % show feedback

                targetArea = [targetFeedback(1,i)-fbsc*TargetSize/2 targetFeedback(2,i) targetFeedback(1,i)+fbsc*TargetSize/2 targetFeedback(2,i)+fbsc*TargetSize/2; 
                              targetFeedback(1,i)-fbsc*TargetSize/2 targetFeedback(2,i)-fbsc*TargetSize/2 targetFeedback(1,i)+fbsc*TargetSize/2 targetFeedback(2,i)];

                % Select FeedbackArrow parts
                P1rect = fbArrowRect(targetFeedback(4,i),:,MoleTypeList(targetFeedback(6,i),targetFeedback(5,i))); %%%%%%%%%%%%%%%QUESTION%%%%%%%%%%%%%%%%
                P2rect = fbArrowRect(mod(targetFeedback(4,i),2)+1,:,MoleTypeList(targetFeedback(6,i),targetFeedback(5,i)));
                fbAngle = 0;
                if (targetFeedback(4,i) == 2)
                    fbAngle = 180;
                end
                % add to feedback pane #1
                Screen('DrawTexture', woff1, winfb, P1rect, targetArea(1,:),0+fbAngle);
                Screen('DrawTexture', woff1, winfb, P2rect, targetArea(2,:),0+fbAngle);
                % add to feedback pane #2
                Screen('DrawTexture', woff2, winfb, P2rect, targetArea(1,:),180+fbAngle);
                Screen('DrawTexture', woff2, winfb, P1rect, targetArea(2,:),180+fbAngle);
                i = i + 1;
            end
        end
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
            [xPos1, yPos1, zPos1, xPos2, yPos2, zPos2] = TransformTrackerData(data,calcorners,ScrRes,fitval);
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
