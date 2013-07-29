% GetHits.m  sasen's analysis script

s1 = 'jlp'; s2 = 'ss'; ExpNum = 3; tr=21;
% s1 = '35'; s2 = 'sasen'; ExpNum = 1; tr=39;

[D,Db] = LoadExpt(s1,s2,ExpNum);
pl=2;
if ExpNum==1
  mole = Db{tr};
else
  mole = Db{pl,tr};
end

clr = D{tr}.TargetColors/255;
trackt = D{tr}.TrackList{3}/240;  % time in s
xyz = cell(1,2);
figure
for pl=[1 2]
    xyz{pl} = D{tr}.TrackList{pl};
    mole = Db{pl,tr};

    lo=0; hi=30;  % bounds in s
    mIdx = find((mole(2,:) >lo) & (mole(2,:) < hi));  % select moles in bounds
    mHit = mole(7,mIdx);
    mType = mole(3,mIdx);

    subplot(2,1,pl),plot(trackt,xyz{pl}(3,:),'k.--')
    hold on
    %plot(trackt/240,xyz2(3,:),'b.--')
    xlabel('time (s)')
    ylabel('z position')

    for m=mIdx
        mOn = mole(2,m);
        if mole(7,m)
            mOff=mole(7,m);
        else
            mOff=mOn+1.25;
        end
        type = mole(3,m);
        plot([mOn;mOff], [type;type]/20, 'LineWidth',2, 'Color',clr(type,:));
        switch mole(6,m)
            case 1
                subplot(2,1,pl),plot(mole(7,m),type/20,'k^','MarkerSize',6);
            case 2
                subplot(2,1,pl),plot(mole(7,m),type/20,'kv','MarkerSize',6);     
        end
    end
end
