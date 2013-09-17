function [replayHitList_t, replayHitList_p] = ReplayWAM(trl)
% REPLAYWAM   Replay a (fullscreen) trial of Whac-a-mole
%   Summer 2013 // Created by Sasen
%   [replayHitList_t, replayHitList_p] = ReplayWAM(trl)
%   trl: (workspace) trl.VARNAME accesses all the saved variables
%   replayHitList (arrays): _t = time mole was hit, _p = hitting player #

KbName('UnifyKeyNames');

%% Screen Settings
[window, ~] = Screen('OpenWindow', 0, trl.BGCol,[0 0 trl.ScrRes]);
Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
InitializeTextPref(window,16,'Helvetica',1);
% HideCursor;
woff = Screen('OpenOffScreenWindow',window,[0 0 0], [trl.ScrRes(1)/2 0 trl.ScrRes]);
InitializeTextPref(woff,16,'Helvetica',1);

%% convenience definitions
tgt = trl.TargetSize;
halftgt = tgt/2;

%% predraw arrow parts
fbsc = 1.0;   %% target feedback size (sidelength) scale factor. 1 = TargetSize
winfb = Screen('OpenOffscreenWindow', window, [0 0 0 0], [0 0 fbsc*tgt 1.5*fbsc*tgt]);
Screen('FillRect', winfb, [255 255 255], [fbsc*tgt/3 0 fbsc*2*tgt/3 fbsc*halftgt]);  % arrowshaft
Screen('FillPoly', winfb, [255 255 255], [0 fbsc*halftgt; fbsc*tgt fbsc*halftgt; fbsc*halftgt fbsc*tgt], 1);  % arrowhead (downward)
Screen('FillRect', winfb, [255 255 255], [0 fbsc*tgt fbsc*tgt 1.5*fbsc*tgt]);  % hammerhead
rect_arrowshaft = [0 0 fbsc*tgt fbsc*halftgt];
rect_arrowhead = [0 fbsc*halftgt fbsc*tgt fbsc*tgt];
rect_hammerhead = [0 fbsc*tgt fbsc*tgt 1.5*fbsc*tgt];

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


%% Welcome/Instructions
tSize=Screen('TextSize',woff,20);
DrawText(woff,{'WELCOME TO WHAC-A-MOLE!'},trl.TextColors,20,20,0,0);
Screen('TextSize',woff,tSize);

DrawText(woff,{'POINTS'},trl.TextColors,20,100,0);
DrawText(woff,{'MOLE TYPE'},trl.TextColors,125,100,0);

iconLEdge = 200-halftgt;
iconREdge = 200+halftgt;

% Table of Mole Types and Points
Screen('DrawLine',woff,[255 255 255], 20, halftgt+100, 250, halftgt+100);
for moleTypeNum = 1:6
    myPts = trl.OutComePlayers(1,moleTypeNum);
    myOffset = 100+moleTypeNum*tgt;
    DrawText(woff,{num2str(myPts)},{trl.PointColor(myPts+2,:)},50,myOffset,0,0);
    Screen('FillOval',woff,trl.TargetColors(moleTypeNum,:),[iconLEdge myOffset-halftgt iconREdge myOffset+halftgt]);
    Screen('DrawLine',woff,[255 255 255], 20, halftgt+myOffset, 250, halftgt+myOffset);
end

% Table of feedback symbols
bottomY = (2/3)*trl.ScrRes(2);
Screen('DrawLine',woff,[255 255 255], 20, bottomY-halftgt-2, 250, bottomY-halftgt-2);
DrawText(woff,{'POINT GAINED'},trl.TextColors,20,bottomY,0,0);
Screen('DrawTexture',woff,winfb,rect_arrowshaft,[iconLEdge bottomY-halftgt iconREdge bottomY]);
Screen('DrawTexture',woff,winfb,rect_arrowhead,[iconLEdge bottomY iconREdge bottomY+halftgt]);
Screen('DrawLine',woff,[255 255 255], 20, bottomY+halftgt+2, 250, bottomY+halftgt+2);
bottomY = bottomY+tgt+4;
DrawText(woff,{'POINT LOST'},trl.TextColors,20,bottomY,0,0);
Screen('DrawTexture',woff,winfb,rect_arrowshaft,[iconLEdge bottomY-halftgt iconREdge bottomY]);
Screen('DrawTexture',woff,winfb,rect_hammerhead,[iconLEdge bottomY iconREdge bottomY+halftgt]);
Screen('DrawLine',woff,[255 255 255], 20, bottomY+halftgt+2, 250, bottomY+halftgt+2);
DrawText(woff,{'spacebar to start'},{[127 127 127]},75,trl.ScrRes(2)-75,0,0);


Screen('FillRect', window, trl.BGCol); % draw background
DrawMirrored(window, woff,woff, trl.ScrRes);  % draw instructions on both sides
Screen('Flip', window);
WaitForKeyPress({'SPACE'});

%% play trial
Screen('FillRect', window, trl.BGCol); % draw background
Screen('Flip', window);

for i = 3:-1:1
    Text = {'',...
        'Get ready!',...
        '',...
        };

    Screen('FillRect', woff, trl.BGCol); % draw background        
    DrawText(woff,Text,trl.TextColors,20,trl.ScrRes(2)/4,0,0);
    DrawText(woff,{num2str(i)},trl.TextColors,50,trl.ScrRes(2)/3,0);
    DrawMirrored(window,woff,woff,trl.ScrRes);
    Screen('Flip', window);
    WaitSecs(0.5);
end

vbl = Screen('Flip', window);
trackedNow = GetSecs;
tStart     = trackedNow;
targetFeedback  = [];    
targetNum       = ones(1,trl.MaxTargetsOnScreen);
targetHit       = zeros(1,trl.MaxTargetsOnScreen);
playerHit       = zeros(1,trl.MaxTargetsOnScreen);
targetShown     = zeros(1,trl.MaxTargetsOnScreen);
replayHitList_t   = zeros(trl.MaxTargetsOnScreen,trl.nTargetOnsets);
replayHitList_p   = zeros(trl.MaxTargetsOnScreen,trl.nTargetOnsets);
replayScore = [0 0];  % [p1 p2]
while ( (GetSecs-tStart < trl.TrialLength))         

    tFrame = GetSecs;
    while GetSecs-tFrame < (1/trl.ScrHz)

        % present or remove targets from screen
        for i = 1:trl.MaxTargetsOnScreen
            TimeDifference = round((((GetSecs-tStart)*1000)-trl.TrialList(i,targetNum(i))));

            % select next target for presentation after a target hit
            if targetHit(i) > 0 
                replayHitList_t(i,targetNum(i)) = GetSecs-tStart;
                replayHitList_p(i,targetNum(i)) = playerHit(i);
                targetNum(i) = targetNum(i)+1;
                targetHit(i) = 0;
                playerHit(i) = 0;
                targetShown(i) = 0;
            elseif TimeDifference >= trl.TargetPresTime % target is missed
                targetNum(i) = targetNum(i)+1;
                targetShown(i) = 0;
            elseif TimeDifference > 0 && TimeDifference < trl.TargetPresTime % show target
                tempColor = trl.TargetColors(trl.MoleTypeList(i,targetNum(i)),:);
                tempColor = round(tempColor.*((trl.TargetPresTime/2)-abs(TimeDifference-(trl.TargetPresTime/2)))/(trl.TargetPresTime/2));
                Screen('FillOval', window, tempColor, [trl.LocationListX(i,targetNum(i))-halftgt trl.LocationListY(i,targetNum(i))-halftgt trl.LocationListX(i,targetNum(i))+halftgt trl.LocationListY(i,targetNum(i))+halftgt], tgt+2);
                targetShown(i) = 1;
            else
                targetShown(i) = 0;
            end

        end

        % check whether feedback should be presented about target hit
        i = 1;
        while i <= size(targetFeedback,2)
            if ( GetSecs-targetFeedback(3,i) > trl.FeedBackDuration ) % remove because feedback is over
                targetFeedback = [targetFeedback(:,1:i-1) targetFeedback(:,i+1:end)];
            elseif ( GetSecs-targetFeedback(3,i) <= trl.FeedBackDuration && targetFeedback(3,i)~= 0 ) % show feedback

                targetArea = [targetFeedback(1,i)-fbsc*halftgt targetFeedback(2,i) targetFeedback(1,i)+fbsc*halftgt targetFeedback(2,i)+fbsc*halftgt; 
                              targetFeedback(1,i)-fbsc*halftgt targetFeedback(2,i)-fbsc*halftgt targetFeedback(1,i)+fbsc*halftgt targetFeedback(2,i)];

                % Select FeedbackArrow parts
                P1rect = fbArrowRect(targetFeedback(4,i),:,trl.MoleTypeList(targetFeedback(6,i),targetFeedback(5,i)));
                P2rect = fbArrowRect(mod(targetFeedback(4,i),2)+1,:,trl.MoleTypeList(targetFeedback(6,i),targetFeedback(5,i)));
                fbAngle = 0;
                if (targetFeedback(4,i) == 2)
                    fbAngle = 180;
                end
                % add to feedback pane #1
                Screen('DrawTexture', window, winfb, P1rect, targetArea(1,:),0+fbAngle);
                Screen('DrawTexture', window, winfb, P2rect, targetArea(2,:),0+fbAngle);
                i = i+1;
            end
        end
        WaitSecs('UntilTime', trackedNow+1/trl.RecordHz);  % avoid buffer underflow
        trackedNow = GetSecs;
        TrackStamp = Secs2Track(max(trackedNow-tStart,trl.TrackList{3}(1)/240),trl.TrackList{3});  % prior to 1st received tracker frame, use that first frame anyway
        Pos1 = trl.TrackList{trl.PlayerLeftIdx}(:,TrackStamp);
        Pos2 = trl.TrackList{trl.PlayerRightIdx}(:,TrackStamp);

        if ( isfinite(Pos1) )   % don't process invalid data
            xPos1 = Pos1(1); yPos1 = Pos1(2); zPos1 = Pos1(3);
            xPos2 = Pos2(1); yPos2 = Pos2(2); zPos2 = Pos2(3);

            % check whether target is hit
            for i = 1:trl.MaxTargetsOnScreen
                if ( targetShown(i) == 1 ) % only if target is really presented
                    %%% TODO checkout this maxZ strategy!!!
                    LeftPlayerHit   = zPos1 < trl.maxZ && trl.LocationListX(i,targetNum(i)) > xPos1-trl.HitSize/2 && trl.LocationListX(i,targetNum(i)) < xPos1+trl.HitSize/2 && trl.LocationListY(i,targetNum(i)) > yPos1-trl.HitSize/2 && trl.LocationListY(i,targetNum(i)) < yPos1+trl.HitSize/2;
                    RightPlayerHit  = zPos2 < trl.maxZ && trl.LocationListX(i,targetNum(i)) > xPos2-trl.HitSize/2 && trl.LocationListX(i,targetNum(i)) < xPos2+trl.HitSize/2 && trl.LocationListY(i,targetNum(i)) > yPos2-trl.HitSize/2 && trl.LocationListY(i,targetNum(i)) < yPos2+trl.HitSize/2;

                    if ( LeftPlayerHit && RightPlayerHit )
                        if ( zPos1 < zPos2 )
                            targetHit(i) = 1; % 1 for player left, 2 for player right, 0 if not hit
                            playerHit(i) = trl.PlayerLeftIdx;
                        elseif ( zPos1 > zPos2 )
                            targetHit(i) = 2; % 1 for player left, 2 for player right, 0 if not hit
                            playerHit(i) = trl.PlayerRightIdx;
                        else    % randomly assign the point to someone
                            targetHit(i) = round(rand(1,1))+1;
                            if ( targetHit(i) == 1 )
                                playerHit(i) = trl.PlayerLeftIdx;
                            else
                                playerHit(i) = trl.PlayerRightIdx;
                            end
                        end
                        targetFeedback(1:2,end+1) = [trl.LocationListX(i,targetNum(i)) trl.LocationListY(i,targetNum(i))];
                        targetFeedback(3,end) = GetSecs;
                        targetFeedback(4,end) = targetHit(i);
                        targetFeedback(5,end) = targetNum(i);
                        targetFeedback(6,end) = i;
                    elseif ( LeftPlayerHit )
                        targetHit(i) = 1; % 1 for player left, 2 for player right, 0 if not hit
                        playerHit(i) = trl.PlayerLeftIdx;
                        targetFeedback(1:2,end+1) = [trl.LocationListX(i,targetNum(i)) trl.LocationListY(i,targetNum(i))];
                        targetFeedback(3,end) = GetSecs;
                        targetFeedback(4,end) = targetHit(i);
                        targetFeedback(5,end) = targetNum(i);
                        targetFeedback(6,end) = i;
                    elseif ( RightPlayerHit )
                        targetHit(i) = 2; % 1 for player left, 2 for player right, 0 if not hit
                        playerHit(i) = trl.PlayerRightIdx;
                        targetFeedback(1:2,end+1) = [trl.LocationListX(i,targetNum(i)) trl.LocationListY(i,targetNum(i))];
                        targetFeedback(3,end) = GetSecs;
                        targetFeedback(4,end) = targetHit(i);
                        targetFeedback(5,end) = targetNum(i);
                        targetFeedback(6,end) = i;
                    else
                        targetHit(i) = 0;
                    end

                        % if target is hit, change score
                        if ( targetHit(i) > 0 )
			  replayScore(playerHit(i)) = replayScore(playerHit(i))+trl.OutComePlayers(1,trl.MoleTypeList(i,targetNum(i)));
			  replayScore(mod(playerHit(i),2)+1) = replayScore(mod(playerHit(i),2)+1)+trl.OutComePlayers(2,trl.MoleTypeList(i,targetNum(i)));
			end
                end
            end
        else
            xPos1 = 1; yPos1 = 1; zPos1 = 100;
            xPos2 = 1; yPos2 = 1; zPos2 = 100;
        end   % processing of valid tracker data
     end   % 1/ScrHz while loop

    Screen('FrameOval', window, [255 255 255], CenterSq(xPos1,yPos1,10) );                
    Screen('FrameOval', window, [255 255 255], CenterSq(xPos1,yPos1,trl.HitSize) );                
    Screen('FrameOval', window, [255 255 255], CenterSq(xPos2,yPos2,10) );                
    Screen('FrameOval', window, [255 255 255], CenterSq(xPos2,yPos2,trl.HitSize) );                
%    DrawText(window,{num2str(zPos1)},{[255 255 255]},20,25,0,0); 
%    DrawText(window,{num2str(zPos2)},{[255 255 255]},20,125,0,0);

    vbl = Screen('Flip', window, vbl+0.5*(1/trl.ScrHz), [], 1); % update screen
end  %%% timepoints loop (for M timepoints within a trial)
    
Screen('FillRect', window, trl.BGCol); % draw background
Screen('Flip', window);

Screen('FillRect', woff, [0 0 0]); % black bg for feedback pane
PlayerLeftScore = trl.PlayerLeftScore;
PlayerRightScore = trl.PlayerRightScore;
replayLeftScore = replayScore(trl.PlayerLeftIdx);
replayRightScore = replayScore(trl.PlayerRightIdx);

if (PlayerLeftScore > PlayerRightScore )
    DrawText(window,{'YOU WIN!'},{[0 255 0]},0.5*trl.ScrRes(1)/6,trl.ScrRes(2)/6,0);
    DrawText(woff,{'YOU LOSE!'},{[255 0 0]},0.5*trl.ScrRes(1)/6,trl.ScrRes(2)/6,0);        
    DrawText(window,{['YOUR SCORE IS  ' num2str(PlayerLeftScore) ' redo ' num2str(replayLeftScore)]},{[0 255 0]},0.5*trl.ScrRes(1)/6,trl.ScrRes(2)/3,0);
    DrawText(window,{['YOUR OPPONENT GOT  ' num2str(PlayerRightScore) ' redo ' num2str(replayRightScore)]},{[255 0 0]},0.5*trl.ScrRes(1)/6,2*trl.ScrRes(2)/3,0);
    DrawText(woff,{['YOUR SCORE IS  ' num2str(PlayerRightScore) ' redo ' num2str(replayRightScore)]},{[255 0 0]},0.5*trl.ScrRes(1)/6,trl.ScrRes(2)/3,0);
    DrawText(woff,{['YOUR OPPONENT GOT  ' num2str(PlayerLeftScore) ' redo ' num2str(replayLeftScore)]},{[0 255 0]},0.5*trl.ScrRes(1)/6,2*trl.ScrRes(2)/3,0);
elseif ( PlayerLeftScore < PlayerRightScore )
    DrawText(window,{'YOU LOSE!'},{[255 0 0]},0.5*trl.ScrRes(1)/6,trl.ScrRes(2)/6,0);
    DrawText(woff,{'YOU WIN!'},{[0 255 0]},0.5*trl.ScrRes(1)/6,trl.ScrRes(2)/6,0);      
    DrawText(window,{['YOUR SCORE IS  ' num2str(PlayerLeftScore) ' redo ' num2str(replayLeftScore)]},{[255 0 0]},0.5*trl.ScrRes(1)/6,trl.ScrRes(2)/3,0);
    DrawText(window,{['YOUR OPPONENT GOT  ' num2str(PlayerRightScore) ' redo ' num2str(replayRightScore)]},{[0 255 0]},0.5*trl.ScrRes(1)/6,2*trl.ScrRes(2)/3,0);
    DrawText(woff,{['YOUR SCORE IS  ' num2str(PlayerRightScore) ' redo ' num2str(replayRightScore)]},{[0 255 0]},0.5*trl.ScrRes(1)/6,trl.ScrRes(2)/3,0);
    DrawText(woff,{['YOUR OPPONENT GOT  ' num2str(PlayerLeftScore) ' redo ' num2str(replayLeftScore)]},{[255 0 0]},0.5*trl.ScrRes(1)/6,2*trl.ScrRes(2)/3,0);
else % draw
    DrawText(window,{'DRAW!'},{[0 0 255]},0.5*trl.ScrRes(1)/6,trl.ScrRes(2)/6,0);
    DrawText(woff,{'DRAW!'},{[0 0 255]},0.5*trl.ScrRes(1)/6,trl.ScrRes(2)/6,0);       
    DrawText(window,{['YOUR SCORE IS  ' num2str(PlayerLeftScore) ' redo ' num2str(replayLeftScore)]},{[0 0 255]},0.5*trl.ScrRes(1)/6,trl.ScrRes(2)/3,0);
    DrawText(window,{['YOUR OPPONENT GOT  ' num2str(PlayerRightScore) ' redo ' num2str(replayRightScore)]},{[0 0 255]},0.5*trl.ScrRes(1)/6,2*trl.ScrRes(2)/3,0);
    DrawText(woff,{['YOUR SCORE IS  ' num2str(PlayerRightScore) ' redo ' num2str(replayRightScore)]},{[0 0 255]},0.5*trl.ScrRes(1)/6,trl.ScrRes(2)/3,0);
    DrawText(woff,{['YOUR OPPONENT GOT  ' num2str(PlayerLeftScore) ' redo ' num2str(replayLeftScore)]},{[0 0 255]},0.5*trl.ScrRes(1)/6,2*trl.ScrRes(2)/3,0);
end

Screen('DrawTexture', window, woff, [], [trl.ScrRes(1)/2 0 trl.ScrRes], 180);
Screen('Flip', window);
WaitSecs(5);
%ShowCursor('Arrow');
Screen CloseAll;
replayRightScore
replayLeftScore