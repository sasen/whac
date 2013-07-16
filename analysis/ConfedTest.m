function Velocity = ConfedTest
%ConfedTest Basic analysis of confederate effectiveness
%   Detailed explanation goes here

load /Users/eshayer/Desktop/Whac-a-mole/ss1717_zb1717_t3_e1.mat

MoleInfoFull=NaN(6,320);
for i=1:40
    for j=1:8
        MoleInfoFull(1,40*j+i-40) = MoleTypeList(j,i); %Color of target (1=green, 2=yellow, 3-6=distractors)
        MoleInfoFull(2,40*j+i-40) = HitList_p(j,i); %Which player hit (0=no hit, 1=player 1, 2=player 2)
        MoleInfoFull(3,40*j+i-40) = (TrialList(j,i)/1000); %Time stamp of target appearence in seconds
        MoleInfoFull(4,40*j+i-40) = HitList_t(j,i); %Time stamp of target hit in seconds
        MoleInfoFull(5,40*j+i-40) = LocationListX(j,i); %X Location of target (pixels)
        MoleInfoFull(6,40*j+i-40) = LocationListY(j,i); %Y Location of target (pixels)
    end
end

%%Preallocation
MovementStart=cell(1,2);

%%Player Hits
k=1;
m=1;
for i=1:40
    for j=1:8
        if (MoleInfoFull(2,40*j+i-40)==1)
            MovementStart{1}(k,:)=[40*j+i-40, MoleInfoFull(3,40*j+i-40), MoleInfoFull(4,40*j+i-40)]; %{player ID} [Mole ID, Time stamp of appearence, time stamp of hit]
            k=k+1;
        end
        if (MoleInfoFull(2,40*j+i-40)==2)
            MovementStart{2}(m,:)=[40*j+i-40, MoleInfoFull(3,40*j+i-40), MoleInfoFull(4,40*j+i-40)];
            m=m+1;
        end
    end
end

%%Direct Movement Distance
for i=1:size(MovementStart{1},1) %Player 1
    XPosInitial1(i,:)=TrackList{1}(1,round(240*MovementStart{1}(i,2)));
    XPosFinal1(i,:)=MoleInfoFull(5,MovementStart{1}(i,1));
    YPosInitial1(i,:)=TrackList{1}(2,round(240*MovementStart{1}(i,2)));
    YPosFinal1(i,:)=MoleInfoFull(6,MovementStart{1}(i,1));
    ZPosInitial1(i,:)=TrackList{1}(3,round(240*MovementStart{1}(i,2)));
    ZPosFinal1(i,:)=TrackList{1}(3,round(240*MovementStart{1}(i,3)));
    LinPosChange1(i,:)=sqrt(((XPosFinal1(i)-XPosInitial1(i))^2)+((YPosFinal1(i)-YPosInitial1(i))^2)+((ZPosFinal1(i)-ZPosInitial1(i))^2)); %Direct distance between initial position and final position
end
for i=1:size(MovementStart{2},1) %Player 2
    XPosInitial2(i,:)=TrackList{2}(1,round(240*MovementStart{2}(i,2)));
    XPosFinal2(i,:)=MoleInfoFull(5,MovementStart{2}(i,1));
    YPosInitial2(i,:)=TrackList{2}(2,round(240*MovementStart{2}(i,2)));
    YPosFinal2(i,:)=MoleInfoFull(6,MovementStart{2}(i,1));
    ZPosInitial2(i,:)=TrackList{2}(3,round(240*MovementStart{2}(i,2)));
    ZPosFinal2(i,:)=TrackList{2}(3,round(240*MovementStart{2}(i,3)));
    LinPosChange2(i,:)=sqrt(((XPosFinal2(i)-XPosInitial2(i))^2)+((YPosFinal2(i)-YPosInitial2(i))^2)+((ZPosFinal2(i)-ZPosInitial2(i))^2)); %Direct distance between initial position and final position
end

%%Curved Movement Distance, each hit target
for i=1:size(MovementStart{1},1) %for each target hit by player one
    j=round(240*MovementStart{1}(i,2)); %j=the first appearence time stamp of a target hit by player one
    k=j;
    XPositionInitial1(1,:)=TrackList{1}(1,k); %Initial X Position of the sensor
    YPositionInitial1(1,:)=TrackList{1}(2,k); %Initial Y Position of the sensor
    ZPositionInitial1(1,:)=TrackList{1}(3,k); %Initial Z Position of the sensor
    for k=j:(round(240*MovementStart{1}(i,3))) %From the appearence time stamp to the hit timestamp
        if isnan(TrackList{1}(1,k+1)) %If the timestamp has no location data, move on
            continue;
        else
            XPositionFinal1(1,:)=TrackList{1}(1,k+1); %Next X Position of the sensor
            YPositionFinal1(1,:)=TrackList{1}(2,k+1); %Next Y Position of the sensor
            ZPositionFinal1(1,:)=TrackList{1}(3,k+1); %Next Z Position of the sensor
            CurvedPositionChange1(k-j+1,:)=sqrt(((XPositionFinal1(1,:)-XPositionInitial1(1,:))^2)+((YPositionFinal1(1,:)-YPositionInitial1(1,:))^2)+((ZPositionFinal1(1,:)-ZPositionInitial1(1,:))^2)); %Distance Formula
            XPositionInitial1(1,:)=XPositionFinal1(1,:); %Former X final goes to initial
            YPositionInitial1(1,:)=YPositionFinal1(1,:); %Former Y final goes to initial
            ZPositionInitial1(1,:)=ZPositionFinal1(1,:); %Former Z final goes to initial
        end
    end
    CurvedPositionChangeOverall1(i,:)=nansum(CurvedPositionChange1(1:end));
    CurvedPositionChange1(1:end)=NaN;
end
for i=1:size(MovementStart{2},1) %for each target hit by player one
    j=round(240*MovementStart{2}(i,2)); %j=the first appearence time stamp of a target hit by player one
    k=j;
    XPositionInitial2(1,:)=TrackList{2}(1,k);
    YPositionInitial2(1,:)=TrackList{2}(2,k);
    ZPositionInitial2(1,:)=TrackList{2}(3,k);
    for k=j:(round(240*MovementStart{2}(i,3)))
        if isnan(TrackList{2}(1,k+1))
            continue;
        else
            XPositionFinal2(1,:)=TrackList{2}(1,k+1);
            YPositionFinal2(1,:)=TrackList{2}(2,k+1);
            ZPositionFinal2(1,:)=TrackList{2}(3,k+1);
            CurvedPositionChange2(k-j+1,:)=sqrt(((XPositionFinal2(1,:)-XPositionInitial2(1,:))^2)+((YPositionFinal2(1,:)-YPositionInitial2(1,:))^2)+((ZPositionFinal2(1,:)-ZPositionInitial2(1,:))^2));
            XPositionInitial2(1,:)=XPositionFinal2(1,:);
            YPositionInitial2(1,:)=YPositionFinal2(1,:);
            ZPositionInitial2(1,:)=ZPositionFinal2(1,:);
        end
    end
    CurvedPositionChangeOverall2(i,:)=nansum(CurvedPositionChange2(1:end));
    CurvedPositionChange2(1:end)=NaN;
end
%%Curved Movement Distance, entire game, Player 1

j=1;
k=1;
XFullPositionInitial1(1,:)=TrackList{1}(1,k);
YFullPositionInitial1(1,:)=TrackList{1}(2,k);
ZFullPositionInitial1(1,:)=TrackList{1}(3,k);
for k=j:size(TrackList{1}(1,:),2)-1
    if isnan(TrackList{1}(1,k+1))
        continue;
    else
        XFullPositionFinal1(1,:)=TrackList{1}(1,k+1);
        YFullPositionFinal1(1,:)=TrackList{1}(2,k+1);
        ZFullPositionFinal1(1,:)=TrackList{1}(3,k+1);
        CurvedFullPositionChange1(k-j+1,:)=sqrt(((XFullPositionFinal1(1,:)-XFullPositionInitial1(1,:))^2)+((YFullPositionFinal1(1,:)-YFullPositionInitial1(1,:))^2)+((ZFullPositionFinal1(1,:)-ZFullPositionInitial1(1,:))^2));
        XFullPositionInitial1(1,:)=XFullPositionFinal1(1,:);
        YFullPositionInitial1(1,:)=YFullPositionFinal1(1,:);
        ZFullPositionInitial1(1,:)=ZFullPositionFinal1(1,:);
    end
end
CurvedFullPositionChangeOverall1(1,:)=nansum(CurvedFullPositionChange1(1:end));

%%Curved Movement Distance, every target
for i=1:size(MoleInfoFull,2) %for each target
    if MoleInfoFull(3,i)>TrialLength
        continue
    else
        j=round(240*MoleInfoFull(3,i)); %j=the appearence time stamp of the target
        k=j;
        if MoleInfoFull(4,i)==0
            if j+TargetPresTime<=size(TrackList{1}(1,:),2)
                m=j+TargetPresTime;
            else
                m=size(TrackList{1}(1));
            end
        else
            if round(240*MoleInfoFull(4,i))>size(TrackList{1}(1,:),2)
                m=size(TrackList{1}(1,:),2);
            else
                m=round(240*MoleInfoFull(4,i));
            end
        end
        XEachPositionInitial1(1,:)=TrackList{1}(1,k);
        YEachPositionInitial1(1,:)=TrackList{1}(2,k);
        ZEachPositionInitial1(1,:)=TrackList{1}(3,k);
        for k=j:m-1
            if isnan(TrackList{1}(1,k+1))
                continue;
            else
                XEachPositionFinal1(1,:)=TrackList{1}(1,k+1);
                YEachPositionFinal1(1,:)=TrackList{1}(2,k+1);
                ZEachPositionFinal1(1,:)=TrackList{1}(3,k+1);
                CurvedSinglePositionChange1(k,:)=sqrt(((XEachPositionFinal1(1,:)-XEachPositionInitial1(1,:))^2)+((YEachPositionFinal1(1,:)-YEachPositionInitial1(1,:))^2)+((ZEachPositionFinal1(1,:)-ZEachPositionInitial1(1,:))^2));
                XEachPositionInitial1(1,:)=XEachPositionFinal1(1,:);
                YEachPositionInitial1(1,:)=YEachPositionFinal1(1,:);
                ZEachPositionInitial1(1,:)=ZEachPositionFinal1(1,:);
            end            
        end
        CurvedEachPositionChange1(i,:)=nansum(CurvedSinglePositionChange1,1);
        CurvedSinglePositionChange1(1:end)=NaN;
    end
end
for i=1:size(MoleInfoFull,2)
    if MoleInfoFull(3,i)>=TrialLength
        EachTargetHitTime(i,:)=NaN;
    elseif MoleInfoFull(2,i)==0;
        EachTargetHitTime(i,:)=(TargetPresTime/1000);
    else
        EachTargetHitTime(i,:)=((MoleInfoFull(4,i)-MoleInfoFull(3,i)));
    end
end

CurvedEachTargetHitVelo1=NaN(size(CurvedEachPositionChange1,1),1);
CurvedEachTargetMissVelo1=NaN(size(CurvedEachPositionChange1,1),1);
CurvedEachDistractorHitVelo1=NaN(size(CurvedEachPositionChange1,1),1);
CurvedEachDistractorMissVelo1=NaN(size(CurvedEachPositionChange1,1),1);

for i=1:size(CurvedEachPositionChange1,1)
    if MoleInfoFull(1,i)<=2
        if MoleInfoFull(2,i)~=0
            CurvedEachTargetHitVelo1(i,:)=(CurvedEachPositionChange1(i,1)/EachTargetHitTime(i,:));
        else
            CurvedEachTargetMissVelo1(i,:)=(CurvedEachPositionChange1(i,:)/EachTargetHitTime(i,:));
        end
    else
        if MoleInfoFull(2,i)~=0
            CurvedEachDistractorHitVelo1(i,:)=(CurvedEachPositionChange1(i,1)/EachTargetHitTime(i,:));
        else
            CurvedEachDistractorMissVelo1(i,:)=(CurvedEachPositionChange1(i,:)/EachTargetHitTime(i,:));
        end
    end
end

for i=1:size(MoleInfoFull,2) %for each target
    if MoleInfoFull(3,i)>TrialLength
        continue
    else
        j=round(240*MoleInfoFull(3,i)); %j=the appearence time stamp of the target
        k=j;
        if MoleInfoFull(4,i)==0
            if j+TargetPresTime<=size(TrackList{2}(1,:),2)
                m=j+TargetPresTime;
            else
                m=size(TrackList{2}(1));
            end
        else
            if round(240*MoleInfoFull(4,i))>size(TrackList{2}(1,:),2)
                m=size(TrackList{2}(1,:),2);
            else
                m=round(240*MoleInfoFull(4,i));
            end
        end
        XEachPositionInitial2(1,:)=TrackList{2}(1,k);
        YEachPositionInitial2(1,:)=TrackList{2}(2,k);
        ZEachPositionInitial2(1,:)=TrackList{2}(3,k);
        for k=j:m-1
            if isnan(TrackList{2}(1,k+1))
                continue
            else
                XEachPositionFinal2(1,:)=TrackList{2}(1,k+1);
                YEachPositionFinal2(1,:)=TrackList{2}(2,k+1);
                ZEachPositionFinal2(1,:)=TrackList{2}(3,k+1);
                CurvedSinglePositionChange2(k,:)=sqrt(((XEachPositionFinal2(1,:)-XEachPositionInitial2(1,:))^2)+((YEachPositionFinal2(1,:)-YEachPositionInitial2(1,:))^2)+((ZEachPositionFinal2(1,:)-ZEachPositionInitial2(1,:))^2));
                XEachPositionInitial2(1,:)=XEachPositionFinal2(1,:);
                YEachPositionInitial2(1,:)=YEachPositionFinal2(1,:);
                ZEachPositionInitial2(1,:)=ZEachPositionFinal2(1,:);
            end            
        end
        CurvedEachPositionChange2(i,:)=nansum(CurvedSinglePositionChange2,1);
        CurvedSinglePositionChange2(1:end)=NaN;
    end
end

%%Defining Reach Starts
for i=1:size(MoleInfoFull,2)
    ReachOrder1((2*i-1),:)=[i 1 MoleInfoFull(3,i)];
    if MoleInfoFull(4,i)==0
        ReachOrder1(2*i,:)=[i 2 NaN];
    else
        ReachOrder1(2*i,:)=[i 2 MoleInfoFull(4,i)];
    end
end
ReachOrder1
sort(ReachOrder1,3)
ReachOrder1

%%Time of Hit
for i=1:size(MovementStart{1},1)
    HitTime1(i,:)=((MoleInfoFull(4,MovementStart{1}(i,1)))-MoleInfoFull(3,MovementStart{1}(i,1)));
end
for i=1:size(MovementStart{2},1)
    HitTime2(i,:)=((MoleInfoFull(4,MovementStart{2}(i,1)))-MoleInfoFull(3,MovementStart{2}(i,1)));
end

%%Calculate Linear Velocity
for i=1:size(MovementStart{1},1)
    LinVelocity1(i,:)=(LinPosChange1(i)/HitTime1(i));
end
for i=1:size(MovementStart{2},1)
    LinVelocity2(i,:)=(LinPosChange2(i)/HitTime2(i));
end

%%Calculate Curved Velocity
for i=1:size(MovementStart{1},1) 
    CurvedVelocity1(i,:)=(CurvedPositionChangeOverall1(i)/HitTime1(i));
end
for i=1:size(MovementStart{2},1)
    CurvedVelocity2(i,:)=(CurvedPositionChangeOverall2(i)/HitTime2(i));
end

%%Calculate Every Target Velocity
for i=1:size(CurvedEachPositionChange1,1)
    if MoleInfoFull(4,i)~=0
        TotalTime1(i,:)=MoleInfoFull(4,i)-MoleInfoFull(3,i);
    else
        TotalTime1(i,:)=TargetPresTime/1000;
    end
    CurvedEachVelocity1(i,:)=CurvedEachPositionChange1(i,:)/TotalTime1(i,:);
end
for i=1:size(CurvedEachPositionChange2,1)
    if MoleInfoFull(4,i)~=0
        TotalTime2(i,:)=MoleInfoFull(4,i)-MoleInfoFull(3,i);
    else
        TotalTime2(i,:)=TargetPresTime/1000;
    end
    CurvedEachVelocity2(i,:)=CurvedEachPositionChange2(i,:)/TotalTime2(i,:);
end

%%Velocity and Acceleration Tracking
j=1;
for i=1:(size(TrackList{1}(1,:),2)-j) %Player 1
    XTrackingChange1(1,:)=(TrackList{1}(1,i)-TrackList{1}(1,(i+j)));
    YTrackingChange1(1,:)=(TrackList{1}(2,i)-TrackList{1}(2,(i+j)));
    ZTrackingChange1(1,:)=(TrackList{1}(3,i)-TrackList{1}(3,(i+j)));
    TrackingVelocity1(i,:)=(sqrt(XTrackingChange1^2+YTrackingChange1^2+ZTrackingChange1^2))*(RecordHz/(j+1));
end
k=1;
for i=1:(size(TrackList{1}(1,:),2)-j-k)
    TrackingAccel1(i,:)=((TrackingVelocity1(i+k,:)-TrackingVelocity1(i,:))*RecordHz);
end
j=1;
for i=1:(size(TrackList{2}(1,:),2)-j) %Player 2
    XTrackingChange2(1,:)=(TrackList{2}(1,i)-TrackList{2}(1,(i+j)));
    YTrackingChange2(1,:)=(TrackList{2}(2,i)-TrackList{2}(2,(i+j)));
    ZTrackingChange2(1,:)=(TrackList{2}(3,i)-TrackList{2}(3,(i+j)));
    TrackingVelocity2(i,:)=(sqrt(XTrackingChange2^2+YTrackingChange2^2+ZTrackingChange2^2))*(RecordHz/(j+1));
end
k=1;
for i=1:(size(TrackList{2}(1,:),2)-j-k)
    TrackingAccel2(i,:)=((TrackingVelocity2(i+k,:)-TrackingVelocity2(i,:))*RecordHz);
end

%%Ratio of Curved to Linear
for i=1:size(MovementStart{1},1) %Each target hit by player 1
    RatioCurveLin1(i,:)=(CurvedPositionChangeOverall1(i,:)/LinPosChange1(i,:)); %Ratio of curved over linear (always >=1)
end
for i=1:size(MovementStart{2},1)
    RatioCurveLin2(i,:)=(CurvedPositionChangeOverall2(i,:)/LinPosChange2(i,:));
end


%%Graphing

% figure
% plot(LinVelocity1,'b.')
% hold on
% plot(CurvedVelocity1,'r.')
% title('Velocity of Player 1')
% xlabel('Order of targets hit')
% ylabel('Velocity (pixels/second)')
% figure
% plot(LinVelocity2,'b.')
% hold on
% plot(CurvedVelocity2,'r.')
% title('Velocity of Player 2')
% xlabel('Order of targets hit')
% ylabel('Velocity (pixels/second)')
% figure
% plot(CurvedEachDistractorHitVelo1,'b.')
% hold on
% plot(CurvedEachDistractorMissVelo1,'b*')
% hold on
% plot(CurvedEachTargetHitVelo1,'r.')
% hold on
% plot(CurvedEachTargetMissVelo1,'r*')
% xlabel('MoleID')
% ylabel('Velocity (Pixels/second)')
% legend('Distractor Hit','Distractor Miss','Target Hit','Target Miss')
% figure
% plot(TrackingVelocity1,'b.-')
% hold on
% plot(TrackingAccel1,'r.')
% figure
% plot(TrackingVelocity2,'b.-')
% hold on
% plot(TrackingAccel2,'r.')
% figure
% plot(RatioCurveLin1,'b.')
% hold on
% plot(RatioCurveLin2,'r.')
end