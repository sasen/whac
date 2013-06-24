function InitializeScreenPref(scrnNum,ExpMode,ExpScrHz,ExpScrRes)

if ExpMode > 0
    ScrSynch = 1;
    SuppressWarning = 1;
    Verbosity = 0;
    VBLTimeStampingMode = 1;
else
    ScrSynch = 0;
    SuppressWarning = 1;
    Verbosity = 1;
    VBLTimeStampingMode = 0;
end
 
if ~ScrSynch
    Screen('Preference', 'SkipSyncTests', 1);
end

if Verbosity
    Screen('Preference','Verbosity', 1)
end

Screen('Preference', 'VBLTimestampingMode', VBLTimeStampingMode);
Screen('Preference', 'SuppressAllWarnings', SuppressWarning);

% check
nScreens = length(scrnNum);
if nScreens>1
    for i = 1:nScreens
        CheckHz(scrnNum(i),ExpScrHz);
        CheckRes(scrnNum(i),ExpScrRes); 
    end
else
    CheckHz(scrnNum,ExpScrHz);
    CheckRes(scrnNum,ExpScrRes);    
end