function X_Y_Z_Speed_maryam_v3(subj1,subj2,minz)


% clear all
close all
clc

if nargin<1
    subj1='35';
    subj2='sasen';
    minz=0;
end;

cd .. 
[D,Db] = LoadExpt(subj1,subj2,1);
cd honestconf

moveinddif=15;
pixinch=18.189/1024;
figon=1;
savedata=0;
for trial=1%:length(D)
    trial
    close all
    colorlist='gyrmbk';
    colorplayer='rbmc';
    datasubj1=D{trial}.TrackList{1};
    datasubj2=D{trial}.TrackList{2};
    time=D{trial}.TrackList{3};
    triallist=Db{trial};
    trackrate=240;
    X{1}=datasubj1(1,:);
    X{2}=datasubj2(1,:);
    Y{1}=datasubj1(2,:);
    Y{2}=datasubj2(2,:);
    Z{1}=datasubj1(3,:)-minz;
    Z{2}=datasubj2(3,:)-minz;
    
    for isubj=1:2
        %get the hits as registered by the computer
        moleregnumber{isubj}=find(triallist(7,:)>0&triallist(6,:)==isubj);
        hitgamereg{isubj}=round(triallist(7,moleregnumber{isubj}).*trackrate);
        moletype{isubj}=triallist(3,moleregnumber{isubj});
        for ihitgame=1:length(hitgamereg{isubj})
            [~,lochitgamereg{isubj}(ihitgame)]=min(abs(time-hitgamereg{isubj}(ihitgame)));
        end;
        %calculate the speed of motion
        S{isubj}=(smooth(sqrt(diff(X{isubj}*pixinch).^2+diff(Y{isubj}*pixinch).^2+diff(Z{isubj}).^2)./diff(time),10))';
        %plot the x,time and y,time and z,time and speed,time
        if figon
            figure(1)
            colp=colorplayer(isubj);
            colp2=colorplayer(isubj+2);
            subplot(2,2,1);
            plot(time,X{isubj},['.',colp]);
            hold on
            for ihitgame=1:length(hitgamereg{isubj})
                plot(time(lochitgamereg{isubj}(ihitgame)),X{isubj}(lochitgamereg{isubj}(ihitgame)),'o','MarkerSize',7,'MarkerEdgeColor',colp,'MarkerFaceColor',colorlist(moletype{isubj}(ihitgame)));
            end;
            xlabel('Time');
            ylabel('X Position');
            title('Time and X Position');
            
            subplot(2,2,1);
            plot(time,Y{isubj},['.',colp]);
            hold on
            for ihitgame=1:length(hitgamereg{isubj})
                plot(time(lochitgamereg{isubj}(ihitgame)),Y{isubj}(lochitgamereg{isubj}(ihitgame)),'o','MarkerSize',7,'MarkerEdgeColor',colp,'MarkerFaceColor',colorlist(moletype{isubj}(ihitgame)));
            end;
            xlabel('Time');
            ylabel('Y Position');
            title('Time and X Position');
            
            
            
            subplot(2,2,3);
            hold on
            plot(time,Z{isubj},['.',colp]);
            hold on
            for ihitgame=1:length(hitgamereg{isubj})
                plot(time(lochitgamereg{isubj}(ihitgame)),Z{isubj}(lochitgamereg{isubj}(ihitgame)),'o','MarkerSize',7,'MarkerEdgeColor',colp,'MarkerFaceColor',colorlist(moletype{isubj}(ihitgame)));
                text(time(lochitgamereg{isubj}(ihitgame)),Z{isubj}(lochitgamereg{isubj}(ihitgame)),num2str(moleregnumber{isubj}(ihitgame)),'VerticalAlignment','bottom');
            end;
            xlabel('Time');
            ylabel('Z Position');
            title('Time and Z Position');
            
            subplot(2,2,4);
            hold on
            
            plot(time(2:end),S{isubj},['.',colp]);
            hold on
            for ihitgame=1:length(hitgamereg{isubj})
                plot(time(lochitgamereg{isubj}(ihitgame)),S{isubj}(lochitgamereg{isubj}(ihitgame)),'o','MarkerSize',7,'MarkerEdgeColor',colp,'MarkerFaceColor',colorlist(moletype{isubj}(ihitgame)));
                text(time(lochitgamereg{isubj}(ihitgame)),S{isubj}(lochitgamereg{isubj}(ihitgame)),num2str(moleregnumber{isubj}(ihitgame)),'VerticalAlignment','bottom');
            end;
            xlabel('Time');
            ylabel('Speed');
            title('Time and Speed');
            
            
        end;
        
        
        
        nback=10;
        multmxback=zeros(length(S{isubj}),length(S{isubj}));
        for iback=1:nback
            multmxback(iback*length(S{isubj})+1:length(S{isubj})+1:end)=1;
        end
        %the time range to check before hit for the launch point
        hitpointsInd{isubj}=find(Z{isubj}(2:end)<0.5 & S{isubj}<pixinch*2 & ~((Z{isubj}(2:end)<0.5 & S{isubj}<pixinch*2)*multmxback));
        clear multmxback
        
        size(hitpointsInd{isubj})
        launchpointsInd{isubj}=NaN(size(hitpointsInd{isubj}));
        molelistind{isubj}=NaN(length(hitpointsInd{isubj}),7);
        datalaunchhit{isubj,trial}=NaN(length(hitpointsInd{isubj}),17);
        
        %subject a
        %determining target hit and launch point for each hit
        for ihit =1:length(hitpointsInd{isubj})
            
            
            curhitind=hitpointsInd{isubj}(ihit);
            framesbeforehit=240;
            framesbeforehit=min(framesbeforehit,curhitind-1);
            
            %determining for each hit which mole was hit
            distancexy=sqrt((triallist(4,:)-X{isubj}(curhitind)).^2+(triallist(5,:)-Y{isubj}(curhitind)).^2);
            newtriallist=triallist(:,(time(curhitind)/trackrate-triallist(2,:))>0 & distancexy<100);
            moledistance=sqrt((newtriallist(2,:)-time(curhitind)).^2+(newtriallist(4,:)-X{isubj}(curhitind)).^2+(newtriallist(5,:)-Y{isubj}(curhitind)).^2);
            [~,molehitind]=min(moledistance);
            
            %determining the launch point for each hit point based on peak z position
            if ~isempty(molehitind) && (ihit==1 || (ihit>1 && ~any(molelistind{isubj}(ihit,1)==molelistind{isubj}(1:ihit-1,1))))
                
                molelistind{isubj}(ihit,:)=newtriallist(:,molehitind);
                molehitnumber=find(triallist(1,:)==molelistind{isubj}(ihit,1));
                
                
                Zcurhit=Z{isubj}(curhitind-framesbeforehit:curhitind-1);
                
                if ~isempty(findpeaks(Zcurhit,'MINPEAKHEIGHT',0.5))
                    [PKS,LOCS]=findpeaks(Zcurhit,'MINPEAKHEIGHT',0.5);
                elseif ~isempty(findpeaks(Zcurhit))
                    [PKS,LOCS]=findpeaks(Zcurhit);
                else
                    LOCS=NaN;
                end;
                launchpointsInd{isubj}(ihit)=max(LOCS)+curhitind-framesbeforehit;
                %plotting the hit points and launch points as determined by
                %this
                %code and as determined originally during the game
                if ~isnan(launchpointsInd{isubj}(ihit)) && hitpointsInd{isubj}(ihit)-launchpointsInd{isubj}(ihit)>moveinddif
                    if figon
                        subplot(2,2,3);
                        plot([time(curhitind),time(curhitind)],[0,10],colp);
                        plot(time(curhitind),Z{isubj}(curhitind),'s','MarkerSize',5,'MarkerEdgeColor',colp,'MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                        plot([time(launchpointsInd{isubj}(ihit)),time(launchpointsInd{isubj}(ihit))],[0,10],colp2);
                        plot(time(launchpointsInd{isubj}(ihit)),Z{isubj}(launchpointsInd{isubj}(ihit)),'s','MarkerSize',5,'MarkerEdgeColor',colp,'MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                        text(time(curhitind),Z{isubj}(curhitind),num2str(molehitnumber),'VerticalAlignment','bottom');
                        
                        subplot(2,2,2);
                        plot(time(curhitind),Y{isubj}(curhitind),'s','MarkerSize',5,'MarkerEdgeColor',colp,'MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                        plot(time(curhitind),Y{isubj}(curhitind),'s','MarkerSize',5,'MarkerEdgeColor',colp,'MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                        
                        subplot(2,2,1);
                        plot(time(curhitind),X{isubj}(curhitind),'s','MarkerSize',5,'MarkerEdgeColor',colp,'MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                        plot(time(curhitind),X{isubj}(curhitind),'s','MarkerSize',5,'MarkerEdgeColor',colp,'MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                        
                    end;
                    datalaunchhit{isubj,trial}(ihit,:)= [launchpointsInd{isubj}(ihit),time(launchpointsInd{isubj}(ihit)),X{isubj}(launchpointsInd{isubj}(ihit)),Y{isubj}(launchpointsInd{isubj}(ihit)),Z{isubj}(launchpointsInd{isubj}(ihit)),...
                        hitpointsInd{isubj}(ihit),time(hitpointsInd{isubj}(ihit)),X{isubj}(hitpointsInd{isubj}(ihit)),Y{isubj}(hitpointsInd{isubj}(ihit)),Z{isubj}(hitpointsInd{isubj}(ihit)),molelistind{isubj}(ihit,:)];
                end;
            end;
        end;
        
        
    end;
end;
%plotting the mole type onset and ofset
if figon
    subplot(2,2,3);
    for imole=1:length(triallist)
        moletype=triallist(3,imole);
        molestarttime=triallist(2,imole);
        moleendtime=triallist(7,imole);
        if ~moleendtime
            moleendtime=molestarttime+1.25;
        end;
        plot([molestarttime*trackrate,moleendtime*trackrate],[moletype*-0.1,moletype*-0.1],['.-',colorlist(moletype)]);
    end;
    subplot(2,2,3);
    hold off
end;
%pause


if savedata
save(['DatahitLaunch/','datalaunch_v2_',subj1,'_',subj2],'datalaunchhit')
end;