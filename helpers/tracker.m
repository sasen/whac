function data = tracker(code,recordhz)
% code 0 = stop tracker (do this when you save files or do something that
% requires much memory) .... the tracker is not stable
% 
% code 5 = get data of the first 2 trackers
% 
% recordhz = put as much time between each tracker data request because if
% the buffer is empty and you request data, the tracker crashes.

if ( code == 0 )
    ReadPnoRTAllML_ver4(code);
else
    bytes_read = 0;
    checkdata = zeros(1,12);
    dt = 1/recordhz;
    while bytes_read ~= 48 | sum(checkdata)>0
        now = GetSecs;
        [data, cols, bytes_read] = ReadPnoRTAllML_ver4(code);        
        for i = 1:2 % check for correctness of data
            for j = 1:5
                checkdata((i-1)*5+j) = ~isnumeric(data(j,i));
            end
        end
        checkdata(11) = data(2,1)<=0;
        checkdata(12) = data(2,2)<=0;
        WaitSecs('UntilTime', now+dt);  % want to put this in expt code
    end
end