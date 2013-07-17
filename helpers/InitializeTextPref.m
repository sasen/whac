function InitializeTextPref(window,TextSize,TextFont,RenderOn)

Screen('Preference', 'TextRenderer', RenderOn); % smooth text

Screen('TextFont', window, TextFont); % define text font
Screen('TextSize', window, TextSize); % define text font