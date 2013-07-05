function [window, windowRect] = InitializeScreens(scrnNum,BGCol,BlendFunct)

nScreens = length(scrnNum);
if nScreens>1
    window = cell(1,nScreens);
    windowRect = cell(1,nScreens);
    for i = 1:nScreens
        [window{i}, windowRect{i}] = Screen('OpenWindow', scrnNum(i));
        Screen('FillRect', window{i}, BGCol); %draw background
        if BlendFunct == 1
            Screen('Blendfunction', window{i}, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        end
    end
else
    [window, windowRect] = Screen('OpenWindow', scrnNum);
    Screen('FillRect', window, BGCol); %draw background
    if BlendFunct == 1
        Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    end
end
ShowHideWinTaskbarMex(0)
