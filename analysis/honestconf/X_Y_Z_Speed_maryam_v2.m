clear all
close all
clc


subj1='rim';
subj2='kd1';

cd ..
[D,Db] = LoadGame(subj1,subj2,1,1);

moveinddif=24;
pixinch=18.189/1024;
% [datalaunchhita,datalaunchhitb]=gethitlaunch(D,Db,1);
figon=1;
for trial=1%:length(D)
    trial
    close all
    colorlist='gyrmbk';
    datasubj1=D{trial}.TrackList{1};
    datasubj2=D{trial}.TrackList{2};
    time=D{trial}.TrackList{3};
    triallist=Db{trial};
    trackrate=240;
    Xa=datasubj1(1,:);
    Xb=datasubj2(1,:);
    Ya=datasubj1(2,:);
    Yb=datasubj2(2,:);
    Za=datasubj1(3,:);
    Zb=datasubj2(3,:);
    
    moleregnumbera=find(triallist(7,:)>0&triallist(6,:)==1);
    hitgamerega=round(triallist(7,moleregnumbera).*trackrate);
    moletypea=triallist(3,moleregnumbera);
    
    moleregnumberb=find(triallist(7,:)>0&triallist(6,:)==2);
    hitgameregb=round(triallist(7,moleregnumberb).*trackrate);
    moletypeb=triallist(3,moleregnumberb);
    
    %get the hits as registered by the computer
    for ihitgame=1:length(hitgamerega)
        [~,lochitgamerega(ihitgame)]=min(abs(time-hitgamerega(ihitgame)));
    end;
    for ihitgame=1:length(hitgameregb)
        [~,lochitgameregb(ihitgame)]=min(abs(time-hitgameregb(ihitgame)));
    end;
    
    %calculate the speed of motion
    Sa=(smooth(sqrt(diff(Xa*pixinch).^2+diff(Ya*pixinch).^2+diff(Za).^2)./diff(time),10))';
    Sb=(smooth(sqrt(diff(Xb*pixinch).^2+diff(Yb*pixinch).^2+diff(Zb).^2)./diff(time),10))';
    
    
    %plot the x,time and y,time and z,time and speed,time
    if figon
        figure(1)
        
        subplot(2,2,1);
        plot(time,Xa,'.-r',time,Xb,'.b');
        hold on
        for ihitgame=1:length(hitgamerega)
            plot(time(lochitgamerega(ihitgame)),Xa(lochitgamerega(ihitgame)),'o','MarkerSize',7,'MarkerEdgeColor',[0.7,0,0],'MarkerFaceColor',colorlist(moletypea(ihitgame)));
        end;
        for ihitgame=1:length(hitgameregb)
            plot(time(lochitgameregb(ihitgame)),Xb(lochitgameregb(ihitgame)),'o','MarkerSize',7,'MarkerEdgeColor',[0,0,0.7],'MarkerFaceColor',colorlist(moletypeb(ihitgame)));
        end;
        xlabel('Time');
        ylabel('X Position');
        title('Time and X Position');
        
        
        subplot(2,2,2);
        hold on
        plot(time,Ya,'.-r',time,Yb,'.b');
         for ihitgame=1:length(hitgamerega)
            plot(time(lochitgamerega(ihitgame)),Ya(lochitgamerega(ihitgame)),'o','MarkerSize',7,'MarkerEdgeColor',[0.7,0,0],'MarkerFaceColor',colorlist(moletypea(ihitgame)));
        end;
        for ihitgame=1:length(hitgameregb)
            plot(time(lochitgameregb(ihitgame)),Yb(lochitgameregb(ihitgame)),'o','MarkerSize',7,'MarkerEdgeColor',[0,0,0.7],'MarkerFaceColor',colorlist(moletypeb(ihitgame)));
        end;
        xlabel('Time');
        ylabel('Y Position');
        title('Time and Y Position');
        
        
        subplot(2,2,3);
        hold on
        plot(time,Za,'.-r',time,Zb,'.b');
        hold on
        for ihitgame=1:length(hitgamerega)
            plot(time(lochitgamerega(ihitgame)),Za(lochitgamerega(ihitgame)),'o','MarkerSize',7,'MarkerEdgeColor',[0.7,0,0],'MarkerFaceColor',colorlist(moletypea(ihitgame)));
            text(time(lochitgamerega(ihitgame)),Za(lochitgamerega(ihitgame)),num2str(moleregnumbera(ihitgame)),'VerticalAlignment','bottom');
       end;
        for ihitgame=1:length(hitgameregb)
            plot(time(lochitgameregb(ihitgame)),Zb(lochitgameregb(ihitgame)),'o','MarkerSize',7,'MarkerEdgeColor',[0,0,0.7],'MarkerFaceColor',colorlist(moletypeb(ihitgame)));
            text(time(lochitgameregb(ihitgame)),Zb(lochitgameregb(ihitgame)),num2str(moleregnumberb(ihitgame)),'VerticalAlignment','bottom');
        end;
        xlabel('Time');
        ylabel('Z Position');
        title('Time and Z Position');
        subplot(2,2,4);
        hold on
        
        
        plot(time(2:end),Sa,'.-r',time(2:end),Sb,'.-b');
        hold on
        for ihitgame=1:length(hitgamerega)
            plot(time(lochitgamerega(ihitgame)),Sa(lochitgamerega(ihitgame)),'o','MarkerSize',7,'MarkerEdgeColor',[0.7,0,0],'MarkerFaceColor',colorlist(moletypea(ihitgame)));
            text(time(lochitgamerega(ihitgame)),Sa(lochitgamerega(ihitgame)),num2str(moleregnumbera(ihitgame)),'VerticalAlignment','bottom');
        end;
        for ihitgame=1:length(hitgameregb)
            plot(time(lochitgameregb(ihitgame)),Sb(lochitgameregb(ihitgame)),'o','MarkerSize',7,'MarkerEdgeColor',[0,0,0.7],'MarkerFaceColor',colorlist(moletypeb(ihitgame)));
            text(time(lochitgameregb(ihitgame)),Sb(lochitgameregb(ihitgame)),num2str(moleregnumberb(ihitgame)),'VerticalAlignment','bottom');
        end;
        xlabel('Time');
        ylabel('Speed');
        title('Time and Speed');
        
    end;
    
    
    
    
    nback=10;
    multmxbacka=zeros(length(Sa),length(Sa));
    multmxbackb=zeros(length(Sb),length(Sb));
    for iback=1:nback
        multmxbacka(iback*length(Sa)+1:length(Sa)+1:end)=1;
        multmxbackb(iback*length(Sb)+1:length(Sb)+1:end)=1;
    end
    %     nfwd=10;
    %     multmxfwda=zeros(length(Sa),length(Sa));
    %     multmxfwdb=zeros(length(Sb),length(Sb));
    %     for ifwd=1:nfwd
    %         multmxfwda(ifwd+1:length(Sa)+1:end)=1;
    %         multmxfwdb(ifwd+1:length(Sb)+1:end)=1;
    %     end
    
    %calculate the hit pints according to a speed and z threshold
    hitpointsInda=find(Za(2:end)<0.5 & Sa<pixinch*2 & ~((Za(2:end)<0.5 & Sa<pixinch*2)*multmxbacka));
    hitpointsIndb=find(Zb(2:end)<0.5 & Sb<pixinch*2 & ~((Zb(2:end)<0.5 & Sb<pixinch*2)*multmxbackb));
    clear multmxbacka
    
    %the time range to check before hit for the launch point
    
    size(hitpointsInda)
    launchpointsInda=NaN(size(hitpointsInda));
    molelistinda=NaN(length(hitpointsInda),7);
    datalaunchhita{trial}=NaN(length(hitpointsInda),17);
    %subject a
    %determining target hit and launch point for each hit
    for ihit =1:length(hitpointsInda)
        
        
        curhitind=hitpointsInda(ihit);
        framesbeforehit=240;
        framesbeforehit=min(framesbeforehit,curhitind-1);
        
        %determining for each hit which mole was hit
        distancexy=sqrt((triallist(4,:)-Xa(curhitind)).^2+(triallist(5,:)-Ya(curhitind)).^2);
        newtriallist=triallist(:,(time(curhitind)/trackrate-triallist(2,:))>0 & distancexy<100);
        moledistance=sqrt((newtriallist(2,:)-time(curhitind)).^2+(newtriallist(4,:)-Xa(curhitind)).^2+(newtriallist(5,:)-Ya(curhitind)).^2);
        [~,molehitind]=min(moledistance);
        
        %determining the launch point for each hit point based on peak z position
        if ~isempty(molehitind) && (ihit==1 || (ihit>1 && ~any(molelistinda(ihit,1)==molelistinda(1:ihit-1,1))))
            
            molelistinda(ihit,:)=newtriallist(:,molehitind);
            molehitnumber=find(triallist(1,:)==molelistinda(ihit,1));
            
            Zacurhit=Za(curhitind-framesbeforehit:curhitind-1);
            
            if ~isempty(findpeaks(Zacurhit,'MINPEAKHEIGHT',0.5))
                [PKS,LOCS]=findpeaks(Zacurhit,'MINPEAKHEIGHT',0.5);
            elseif ~isempty(findpeaks(Zacurhit))
                [PKS,LOCS]=findpeaks(Zacurhit);
            else
                LOCS=NaN;
            end;
            launchpointsInda(ihit)=max(LOCS)+curhitind-framesbeforehit;
            %plotting the hit points and launch points as determined by
            %this
            %code and as determined originally during the game
            if ~isnan(launchpointsInda(ihit)) && hitpointsInda(ihit)-launchpointsInda(ihit)>moveinddif 
                if figon
                    subplot(2,2,3);
                    plot([time(curhitind),time(curhitind)],[0,10],'r');
                    plot(time(curhitind),Za(curhitind),'s','MarkerSize',5,'MarkerEdgeColor','r','MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                    plot([time(launchpointsInda(ihit)),time(launchpointsInda(ihit))],[0,10],'m');
                    plot(time(launchpointsInda(ihit)),Za(launchpointsInda(ihit)),'s','MarkerSize',5,'MarkerEdgeColor','r','MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                    text(time(curhitind),Za(curhitind),num2str(molehitnumber),'VerticalAlignment','bottom');
                    
                    subplot(2,2,2);
                    plot(time(curhitind),Ya(curhitind),'s','MarkerSize',5,'MarkerEdgeColor','r','MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                    plot(time(curhitind),Ya(curhitind),'s','MarkerSize',5,'MarkerEdgeColor','r','MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                    
                    subplot(2,2,1);
                    plot(time(curhitind),Xa(curhitind),'s','MarkerSize',5,'MarkerEdgeColor','r','MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                    plot(time(curhitind),Xa(curhitind),'s','MarkerSize',5,'MarkerEdgeColor','r','MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                    
                end;
                    datalaunchhita{trial}(ihit,:)= [launchpointsInda(ihit),time(launchpointsInda(ihit)),Xa(launchpointsInda(ihit)),Ya(launchpointsInda(ihit)),Za(launchpointsInda(ihit)),...
                        hitpointsInda(ihit),time(hitpointsInda(ihit)),Xa(hitpointsInda(ihit)),Ya(hitpointsInda(ihit)),Za(hitpointsInda(ihit)),molelistinda(ihit,:)];
            end;
        end;
    end;
    
    launchpointsIndb=NaN(size(hitpointsIndb));
    molelistindb=NaN(length(hitpointsIndb),7);
    datalaunchhitb{trial}=NaN(length(hitpointsIndb),17);
    %subject b
    %determining target hit and launch point for each hit
    
    for ihit =1:length(hitpointsIndb)
        
        
        framesbeforehit=240;
        curhitind=hitpointsIndb(ihit);
        framesbeforehit=min(framesbeforehit,curhitind-1);
        
        %determining for each hit which mole was hit
        distancexy=sqrt((triallist(4,:)-Xb(curhitind)).^2+(triallist(5,:)-Yb(curhitind)).^2);
        newtriallist=triallist(:,(time(curhitind)/trackrate-triallist(2,:))>0 & distancexy<100);
        moledistance=sqrt((newtriallist(2,:)-time(curhitind)).^2+(newtriallist(4,:)-Xb(curhitind)).^2+(newtriallist(5,:)-Yb(curhitind)).^2);
        [~,molehitind]=min(moledistance);
        
        %determining the launch point for each hit point based on peak z position
        if ~isempty(molehitind) && (ihit==1 || (ihit>1 && ~any(molelistindb(ihit,1)==molelistindb(1:ihit-1,1))))
            
            molelistindb(ihit,:)=newtriallist(:,molehitind);
            molehitnumber=find(triallist(1,:)==molelistindb(ihit,1))
            Zbcurhit=Zb(curhitind-framesbeforehit:curhitind-1);
            
            if ~isempty(findpeaks(Zbcurhit,'MINPEAKHEIGHT',0.5))
                [PKS,LOCS]=findpeaks(Zbcurhit,'MINPEAKHEIGHT',0.5);
            elseif ~isempty(findpeaks(Zbcurhit))
                [PKS,LOCS]=findpeaks(Zbcurhit);
            else
                LOCS=NaN;
            end;
            launchpointsIndb(ihit)=max(LOCS)+curhitind-framesbeforehit;
            %plotting the hit points and launch points as determined by this
            %code and as determined originally during the game
            if ~isnan(launchpointsIndb(ihit)) && hitpointsIndb(ihit)-launchpointsIndb(ihit)>moveinddif
                if figon
                    subplot(2,2,3);
                    plot([time(curhitind),time(curhitind)],[0,10],'b');
                    plot(time(curhitind),Zb(curhitind),'s','MarkerSize',5,'MarkerEdgeColor','b','MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                    plot([time(launchpointsIndb(ihit)),time(launchpointsIndb(ihit))],[0,10],'c');
                    plot(time(launchpointsIndb(ihit)),Zb(launchpointsIndb(ihit)),'s','MarkerSize',5,'MarkerEdgeColor','b','MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                    text(time(curhitind),Zb(curhitind),num2str(molehitnumber),'VerticalAlignment','bottom');
                
                    subplot(2,2,2);
                    plot(time(curhitind),Yb(curhitind),'s','MarkerSize',5,'MarkerEdgeColor','b','MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                    plot(time(curhitind),Yb(curhitind),'s','MarkerSize',5,'MarkerEdgeColor','b','MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                    
                    subplot(2,2,1);
                    plot(time(curhitind),Xb(curhitind),'s','MarkerSize',5,'MarkerEdgeColor','b','MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                    plot(time(curhitind),Xb(curhitind),'s','MarkerSize',5,'MarkerEdgeColor','b','MarkerFaceColor',colorlist(newtriallist(3,molehitind)));
                
                end;
                    datalaunchhitb{trial}(ihit,:)= [launchpointsIndb(ihit),time(launchpointsIndb(ihit)),Xb(launchpointsIndb(ihit)),Yb(launchpointsIndb(ihit)),Zb(launchpointsIndb(ihit)),...
                        hitpointsIndb(ihit),time(hitpointsIndb(ihit)),Xb(hitpointsIndb(ihit)),Yb(hitpointsIndb(ihit)),Zb(hitpointsIndb(ihit)),molelistindb(ihit,:)];
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
end;

save(['DatahitLaunch/','datalaunch_v2_',subj1,'_',subj2],'datalaunchhita','datalaunchhitb')