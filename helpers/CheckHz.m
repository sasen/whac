function CheckHz(ScrNum,ExpScreenHz)

% function CheckHz(ScrNum,ExpScreenHz)
% ScrnNum       = Screen Number
% ExpScreenHz   = the Framerate you would like to check
% Note: currently rounding to the nearest Hz!

RealScreenHz        = Screen('FrameRate', ScrNum, 1);

% some graphics cards report garbage, so measure the frame rate directly.
if (RealScreenHz < 10)
   RealFlipInt	  = Screen('GetFlipInterval',ScrNum);
   RealScreenHz   = round(1/RealFlipInt);

if ( RealScreenHz ~= ExpScreenHz )
    error(['WRONG Screen HZ! Actual HZ:' num2str(RealScreenHz) ' - Expected HZ:' num2str(ExpScreenHz)]);
end

end