[data, ~, bytes_read]   = ReadPnoRTAllML_ver4(5);

calcorners = NaN(3,3,3);
tempDataX = NaN(3,3);
tempDataY = NaN(3,3);
tempDataZ = NaN(3,3);

[window, windowRect] = InitializeScreens(0,[0 0 0],1);
InitializeTextPref(window,10,'Helvetica',1);

Corners = [0 0; 0 ScrRes(2)/2; 0 ScrRes(2); ScrRes(1)/2 0; ScrRes(1)/2 ScrRes(2)/2; ScrRes(1)/2 ScrRes(2); ScrRes(1) 0; ScrRes(1) ScrRes(2)/2; ScrRes(1) ScrRes(2)];


Screen('FillRect', window, [0 0 0]); % draw background

Text = {'9 RED CALIBRATION POINT WILL BE SHOWN IN SEQUENCE AT SEVERAL LOCATIONS',...
    'HIT EACH OF THE RED POINTS WITH THE SENSOR TIP AND HOLD IT IN POSITION,',...
    'UNTIL IT CHANGES ITS POSITION',...
    '',...
    'USE THE TEAR DROP SHAPED SENSOR LOCATED NEAR TO THE COMPUTER',...
    'DO NOT USE THE OTHER SQUARE SENSOR',...
    '',...
    'THE FIRST CALIBRATION POINT WILL BE SHOWN IN THE TOP LEFT CORNER',...
    '',...
    'PRESS SPACE TO START AND BE READY!!!'};

DrawText(window,Text,{[255 255 255]},'center',round(ScrRes(2)/3.5),0);
        
Screen('Flip', window);

WaitForKeyPress({'SPACE'});

Screen('FillRect', window, [0 0 0]); % draw background
Screen('Flip', window);

WaitSecs(5);

for i = 1:9
    Screen('FillRect', window, [0 255 0]); % draw background
    Screen('Flip', window);
    WaitSecs(1);
    
    tStart = GetSecs;
    while GetSecs-tStart < 10
        [data, ~, bytes_read]   = ReadPnoRTAllML_ver4(5);
        tempDataX(i) = data(4,1);
        tempDataY(i) = data(5,1);
        tempDataZ(i) = data(3,1);
        
        Screen('FillRect', window, [0 0 0]); % draw background

        Text = {'HIT THE RED POINT AND HOLD IT THERE!'};

        DrawText(window,Text,{[255 255 255]},'center',round(ScrRes(2)/3.5),0);
        DrawText(window,{num2str(GetSecs-tStart)},{[255 255 255]},'center',round(ScrRes(2)/1.5),0);
        
        Screen('FillOval', window, [255 0 0], [Corners(i,1)-5 Corners(i,2)-5 Corners(i,1)+5 Corners(i,2)+5]);
        
        Screen('Flip', window);
    end
    
end

calcorners(:,:,1) = tempDataX;
calcorners(:,:,2) = tempDataY;
calcorners(:,:,3) = tempDataZ;

save('calcorners.mat','calcorners');

fitval = [];
% fitval(1,:) = polyfit(nanmean(calcorners(:,:,1)),nanmean(calcorners(:,:,2)),1);
% fitval(2,:) = polyfit(nanmean(calcorners(:,:,2),2),nanmean(calcorners(:,:,1),2),1);
fitval(1,:) = (regress((nanmean(calcorners(:,:,2)))',[(nanmean(calcorners(:,:,1)))',[1;1;1]]))';
fitval(2,:) = (regress(nanmean(calcorners(:,:,1),2),[nanmean(calcorners(:,:,2),2),[1;1;1]]))';


ReadPnoRTAllML_ver4(0);
sa;

