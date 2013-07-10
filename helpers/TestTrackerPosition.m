WaitSecs(1);
recording = 1;
fighandle = figure;
axis([0 35 -15 0 8 14])
hold on;
grid on;

hz = 200;
dt = 1/hz;
while recording
    tstart = tic;
    now = GetSecs;
    [data, ~, bytes_read] = ReadPnoRTAllML_ver4(5);
    [keyIsDown,secs,keyCode] = KbCheck;
    
%    plot(1,data(3,1),'ro')
%    text(1,data(3,1),['z: ' num2str(data(3,1))])
    plot3(data(4,1),data(5,1),data(3,1),'ro')
    plot3(data(4,2),data(5,2),data(3,2),'bo')
%     text(17,-6,['x: ' num2str(data(4,1))])
%     text(17,-7,['y: ' num2str(data(5,1))])
%     text(17,-8,['z: ' num2str(data(3,1))])
    
    if ( keyIsDown )
        recording = 0; 
        disp(keyCode)
    else
        wakeup = WaitSecs('UntilTime', now+dt);
    end
    toc(tstart)
end
drawnow;
ReadPnoRTAllML_ver4(0);