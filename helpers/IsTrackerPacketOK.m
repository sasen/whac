function ok = IsTrackerPacketOK(data, bytes_read)
% IsTrackerPacketOK  Paranoid checking of a tracker data packet.
%     function ok = IsTrackerPacketOK(data, bytes_read)
%     data: data packet from ReadPnoRTAllML_ver4(5)
%     bytes_read: also returned from ReadPnoRTAllML_ver4(5)
%     ok: 0-> bad data!, 1-> good-looking data

checkdata = zeros(1,13);
if (bytes_read ~= 48)
    ok = 0;
else
    for i = 1:2 % check for correctness of data
        for j = 1:5
            checkdata((i-1)*5+j) = ~isnumeric(data(j,i));
        end
    end
    checkdata(11) = data(2,1)<=0;
    checkdata(12) = data(2,2)<=0;
    checkdata(13) = data(2,2)~=data(2,1);   % ensure timestamp same on each col
    ok = ~(sum(checkdata)>0);        
end