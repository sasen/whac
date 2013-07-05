screen('FillRect',woff,[0 0 0]);

Screen('FillRect', window, BGCol); % draw background
Screen('Flip', window);

%if ( ExpMode > 0 )
%    data = tracker(5,RecordHz);
%end

Screen('FillRect', window, BGCol); % draw background

DrawText(window,{'PLAYERS SHOULD NOW SWITCH:','','SIDES,','AND TOUCH DEVICES','','CALL THE EXPERIMENTER'},TextColors,20,20,0,0);

screen('FillRect',woff,[0 0 0]);
DrawText(woff,{'PLAYERS SHOULD NOW SWITCH:','','SIDES,','AND TOUCH DEVICES','','CALL THE EXPERIMENTER'},TextColors,20,20,0,0);
Screen('DrawTexture', window, woff, [], [ScrRes(1)/2 0 ScrRes(1) ScrRes(2)], 180);

AreaOfInterest = [20 ScrRes(2)-50 ScrRes(1)-20 ScrRes(2)-10];

DrawText(window,{'Press SPACE to continue!'},TextColors,AreaOfInterest(1)+50,AreaOfInterest(2)+10,0,0);

Screen('Flip', window);

%if ( ExpMode > 0 )
%    tracker(0,RecordHz);
    
    
%end

WaitForKeyPress({'SPACE'});

Screen('FillRect', window, BGCol); % draw background
Screen('Flip', window);

%if ( ExpMode > 0 )
%    data = tracker(5,RecordHz);
%end