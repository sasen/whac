function SensorToDotGrid()
ResInfo 	    = Screen('Resolution',0);
ScrRes		    = [ResInfo.width ResInfo.height];
ScrHz               =   60;             % framerate of screen (frames/second)
RecordHz                    = 150;          % at which speed should the tracker record?
TrialLength = 90;
%HoriScrDist         =   400;            % (mm)

calcorners(:,:,1) = [    
    4.8078   13.9688   23.1681
    5.0142   14.2244   23.5174
    5.2643   14.4456   23.8417];
calcorners(:,:,2) = [    
    0.5527    0.8864    1.2118
   -6.2717   -5.9730   -5.6018
  -13.3088  -13.0224  -12.7822];
calcorners(:,:,3) = [
    8.9273    8.8635    8.5339
    9.2165    9.0977    8.7652
    9.5305    9.3808    8.8094];
fitval = [];
fitval(1,:) = (regress((nanmean(calcorners(:,:,2)))',[(nanmean(calcorners(:,:,1)))',[1;1;1]]))';
fitval(2,:) = (regress(nanmean(calcorners(:,:,1),2),[nanmean(calcorners(:,:,2),2),[1;1;1]]))';

%% Initialization
TrackList           = cell(1,3);
TrackList{1}        = NaN(3,TrialLength*RecordHz);
TrackList{2}        = NaN(3,TrialLength*RecordHz);
TrackList{3}        = NaN(1,TrialLength*RecordHz);

win = ShowGrid(ScrRes);   % Draw dots!
tracker(0); 
data = tracker(5,RecordHz);   % turn on
data = tracker(5,RecordHz);
trackedNow = GetSecs;
TimeStampTrackerLeft    = data(2,1)-1;

vbl = Screen('Flip', win,[],1);
dataCount       = 0;
tStart = GetSecs;
while (trackedNow-tStart < TrialLength)
  tFrame = GetSecs;
  while GetSecs-tFrame < (1/ScrHz)
    WaitSecs('UntilTime', trackedNow+1/RecordHz);  % avoid buffer underflow
    [data, cols, bytes_read] = ReadPnoRTAllML_ver4(5);
    trackedNow = GetSecs;

    if ( IsTrackerPacketOK(data, bytes_read) )   % don't process invalid data
      dataCount = dataCount + 1;
      [xPos1, yPos1, zPos1, xPos2, yPos2, zPos2] = TransformTrackerData(data,calcorners,ScrRes,fitval);
      TrackList{1}(:,dataCount) = [xPos1; yPos1; zPos1];
      TrackList{2}(:,dataCount) = [xPos2; yPos2; zPos2];
      TrackList{3}(1,dataCount) = data(2,1)-TimeStampTrackerLeft;
    end   % processing of valid tracker data
  end   % 1/ScrHz while loop

  if (trackedNow-tStart < TrialLength/4)
    Screen('FillRect',win,[0 255 0],[0 0 40 40]);
  elseif (trackedNow-tStart < TrialLength/2)
    Screen('FillRect',win,[255 255 0],[0 0 30 30]);
  elseif (trackedNow-tStart < TrialLength*3/4)
    Screen('FillRect',win,[255 0 0],[0 0 25 25]);
  else
    Screen('FillRect',win,[255 255 255],[0 0 20 20]);
  end
  
  Screen('FrameOval', win, [255 0 0], CenterSq(xPos1,yPos1,4));
  Screen('FrameOval', win, [0 0 255], CenterSq(xPos2,yPos2,4));
  vbl = Screen('Flip', win, vbl+0.5*(1/ScrHz), 1, 1); 
end 
tracker(0,RecordHz);
ppname='crayons';
save('dotGridCrayons.mat');
Screen CloseAll;


% WaitSecs(1);
% recording = 1;
% hz = 200;
% dt = 1/hz;
% while recording
%     tstart = tic;
%     now = GetSecs;
%     [data, ~, bytes_read] = ReadPnoRTAllML_ver4(5);
%     [keyIsDown,secs,keyCode] = KbCheck;
%     if ( keyIsDown )
%         recording = 0;
%         disp(keyCode)
%     else
%         wakeup = WaitSecs('UntilTime', now+dt);
%     end
%     toc(tstart)
% end
% ReadPnoRTAllML_ver4(0);