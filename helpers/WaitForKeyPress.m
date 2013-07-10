function [Response,RT] = WaitForKeyPress(Buttons,MaxRespTime);
% 
% [Response,RT] = WaitForKeyPress(Buttons,MaxRespTime);
% 
% Buttons is a cell array of all the buttons the function will listen to
% 
% MaxRespTime is the maximum time allowed to give a respons
% Response & RT are NaN if nothing is responded within time

switch nargin,
    case 0
        Buttons = {};
        MaxRespTime = 0;
    case 1
        MaxRespTime = 0;
end

if ~iscell(Buttons)
    error('Input should be a cell');
end
    
%%

RT = NaN;
if length(Buttons) > 0 % % wait for specific button 
    
    if ~MaxRespTime % only wait for depress if no reaction time is requested
        [keyIsDown,secs,keyCode] = KbCheck;
        while keyIsDown
            [keyIsDown,secs,keyCode] = KbCheck;
        end
    end
    
    CheckKeys = zeros(1,length(Buttons));
    
    [keyIsDown,secs,keyCode] = KbCheck;
    
    Stop = 0;
    StartTime = GetSecs();
    while ~logical(sum(CheckKeys)) && ~Stop
        [keyIsDown,secs,keyCode] = KbCheck;
        
        for KeyI = 1:length(Buttons)
            if ( sum(keyCode>0) == 1 ) % only allow one button
                CheckKeys(KeyI) = strcmp(lower(Buttons{KeyI}),lower(KbName(keyCode)));
            end
        end
        
        if logical(MaxRespTime)
            if GetSecs()-StartTime >= MaxRespTime
                Stop = 1;
            end
        end
    end
    RT = GetSecs()-StartTime;
    
    if Stop
        Response = NaN;
    else
        Response = KbName(keyCode);
    end
    
else % wait for all buttons
%     disp('else'); 
    
    if ~MaxRespTime % only wait for depress if no reaction time is requested
        [keyIsDown,secs,keyCode] = KbCheck;
        while keyIsDown
            [keyIsDown,secs,keyCode] = KbCheck;
        end
    end
    
    [keyIsDown,secs,keyCode] = KbCheck;
    Stop = 0;
    StartTime = GetSecs;
    while ~keyIsDown && ~Stop
        [keyIsDown,secs,keyCode] = KbCheck;
        
        if logical(MaxRespTime)
            if GetSecs()-StartTime >= MaxRespTime
                Stop = 1;
            end
        end
    end
    RT = GetSecs()-StartTime;
    
    if Stop
        Response = NaN;
    else
        Response = KbName(keyCode);
    end

end