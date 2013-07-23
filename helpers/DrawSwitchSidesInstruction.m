Screen('FillRect',woff,[0 0 0]);
DrawText(woff,{'TIME TO SWITCH SIDES!','','Put your stick down on your side of the board.'},TextColors,20,20,0,0);
DrawText(woff,{'Player near the door: summon the researcher.'},{[127 127 127]},20,ScrRes(2)/2-50);
Screen('DrawLine',woff,[255 255 255],0,ScrRes(2)/2,ScrRes(1)/2,ScrRes(2)/2,4)

Screen('FillRect',window,BGCol);
DrawMirrored(window, woff, woff, ScrRes);
Screen('Flip', window);
WaitForKeyPress({'SPACE'});

Screen('FillRect', window, BGCol); % draw background
Screen('Flip', window);
