function [calcorners, fitval] = CalibWAM(sensNum,playerID,ScrRes,comment)
% CALIBRATEWAM  Calibrate a Liberty sensor to a player
% function [calcorners, fitval] = CalibrateWAM(sensNum,playerID)
%   sensNum: sensor number, 1 or 2
%   playerID: string, must match the playerID used in expts
%   comment: string, eg 'vertical' or 'tilted'
%   calcorners: matrix of average readings at each corner
%   fitval: matrix of linear fit values

if nargin == 3
    comment = '';
end

fname = [playerID '_sensor' num2str(sensNum) comment '.mat'];
if exist(fname,'file')   % we've already done this calibration, so load it.
    oldCalib = load(fname);
    calcorners = oldCalib.calcorners;
    fitval = oldCalib.fitval;
else   % do a new calibration for this sensor/player/comment combination
    Hz = 120;
    calLength = 3;  % in seconds

    window = ShowGrid(ScrRes);
    WaitForKeyPress({'SPACE'});

    tracker(0);  % turn tracker off
    [~, ~, ~]   = ReadPnoRTAllML_ver4(5);  % turn tracker on

    tempDataX = NaN(9,Hz*calLength);
    tempDataY = NaN(9,Hz*calLength);
    tempDataZ = NaN(9,Hz*calLength);
    calcorners = NaN(3,3,3);
    Corners = [0 0; 0 ScrRes(2)/2; 0 ScrRes(2); ScrRes(1)/2 0; ScrRes(1)/2 ScrRes(2)/2; ScrRes(1)/2 ScrRes(2); ScrRes(1) 0; ScrRes(1) ScrRes(2)/2; ScrRes(1) ScrRes(2)];
    trackedNow = GetSecs;
    for i = 1:9
        Screen('FillRect', window, [0 255 0]); % draw green
        Screen('Flip', window);
        WaitSecs(0.25);
        [~, ~, ~]   = ReadPnoRTAllML_ver4(5);

        Screen('FillRect', window, [0 0 0 0]); % draw background
        Screen('FillOval', window, [255 0 0], CenterSq(Corners(i,1),Corners(i,2),10));
        Screen('Flip', window);
        for q=1:10
            WaitSecs(.25);
            [~, ~, ~]   = ReadPnoRTAllML_ver4(5);
        end
        dataCount = 0;
        tStart = GetSecs;
        while (GetSecs-tStart < 3)
            WaitSecs('UntilTime', trackedNow+1/Hz);  % avoid buffer underflow
            trackedNow = GetSecs;
            [data, ~, bytes_read] = ReadPnoRTAllML_ver4(5);
            if ( IsTrackerPacketOK(data, bytes_read) )   % don't process invalid data
                dataCount = dataCount + 1;
                tempDataX(i,dataCount) = data(4,sensNum);
                tempDataY(i,dataCount) = data(5,sensNum);
                tempDataZ(i,dataCount) = data(3,sensNum);
            end
        end

    end
    tracker(0);  % turn tracker off
    Screen CloseAll;

    subplot(3,1,1),plot(tempDataX');
    subplot(3,1,2),plot(tempDataY');
    subplot(3,1,3),plot(tempDataZ');
    
    xmu = nanmean(tempDataX(:,end-Hz:end),2);
    ymu = nanmean(tempDataY(:,end-Hz:end),2);
    zmu = nanmean(tempDataZ(:,end-Hz:end),2);

    calcorners(:,:,1) = reshape(xmu,3,3);
    calcorners(:,:,2) = reshape(ymu,3,3);
    calcorners(:,:,3) = reshape(zmu,3,3);

    fitval = [];
    fitval(1,:) = (regress((nanmean(calcorners(:,:,2)))',[(nanmean(calcorners(:,:,1)))',[1;1;1]]))';
    fitval(2,:) = (regress(nanmean(calcorners(:,:,1),2),[nanmean(calcorners(:,:,2),2),[1;1;1]]))';

    save([playerID '_sensor' num2str(sensNum) comment '.mat'],'-mat');
end


