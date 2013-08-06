clear all

subj1list={'35','m7r','eli','rim','jkc','rim','sasen','sts','rim','94s','teb','233'};
subj2list={'sasen','ss','3u1','lml','sasen','143','ttb','sasen','kd1','eli','eli','ss5'};
confederate=[2,2,1,1,2,1,1,2,1,2,2,2];

directory='../RunFullscreen/HonestConfederate/';

slowfastorder={[0 0 0 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2],...
               [0 0 0 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1],...
               [0 0 0 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2],...
               [0 0 0 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2],...
               [0 0 0 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2],...
               [0 0 0 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2],...
               [0 0 0 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2],...
               [0 0 0 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2],...
               [0 0 0 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1],...
               [0 0 0 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1],...
               [0 0 0 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2],...
               [0 0 0 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1]};  %condition 1 is slow and condition 2 is fast 0 is practice


ASconfederate=NaN(39,2,10);
ASplayer=NaN(39,2,10);
for isubject=1:length(subj1list)
    subj1=subj1list{isubject};
    subj2=subj2list{isubject};
    if confederate(isubject)==1
        colora='.-r';
        colorb='.-b';
    elseif confederate(isubject)==2
        colora='.-b';
        colorb='.-r';
    end;
    
    for itrial=[4:39];
        trial=num2str(itrial);
        cond=slowfastorder{isubject}(itrial);
        filename=[directory,'/',subj1,'_',subj2,'/',subj1,'_',subj2,'_t',num2str(trial),'_e1.mat'];
        load(filename)
        datasubj1=TrackList{1};
        datasubj2=TrackList{2};
        time=TrackList{3};
        Xa=datasubj1(1,:);
        Xb=datasubj2(1,:);
        Ya=datasubj1(2,:);
        Yb=datasubj2(2,:);
        Za=datasubj1(3,:);
        Zb=datasubj2(3,:);
        
        figure(cond)
        plot(time,Za,colora,time,Zb,colorb);
        xlim([500,7200]);
        ylim([0,6]);
           xlabel('Time');
        ylabel('Z Position');
        title('Time and Z Position');
    end;
    end
%         plot(time,Xa,colora,time,Xb,colorb);
%         xlim([500,7200]);
%         ylim([0,1240]);
%         xlabel('Time');
%         ylabel('X Position');
%         title('Time and X Position');
%         subplot(2,2,2);
%         plot(time,Ya,colora,time,Yb,colorb);
%         xlim([500,7200]);
%         ylim([0,800]);
%         xlabel('Time');
%         ylabel('Y Position');
 %         title('Time and Y Position');
 %         subplot(2,2,3);
%          figure(1)
%         plot(time,Za,colora,time,Zb,colorb);
%         xlim([500,7200]);
%         ylim([0,6]);
%         
%         xlabel('Time');
%         ylabel('Z Position');
%         title('Time and Z Position');
%          
%         Sa=sqrt(diff(Xa).^2+diff(Ya).^2+diff(Za).^2)./diff(time);
%         Sb=sqrt(diff(Xb).^2+diff(Yb).^2+diff(Zb).^2)./diff(time);
%         
%         subplot(2,2,4);
%         plot(time(2:end),Sa,colora,time(2:end),Sb,colorb);
%         xlim([500,7200]);
%         ylim([0,20]);
%         xlabel('Time');
%         ylabel('Speed');
%         title('Time and Speed');
%         
%         %           Acceleration
%         %         Aa=diff(Sa)./diff(time(2:end));
%         %         Ab=diff(Sb)./diff(time(2:end));
%         %         figure(2)
%         %         plot(time(3:end),Aa,'.-r',time(3:end),Ab,'.-b');
%         %         xlabel('Time');
%         %         ylabel('Acceleration');
%         %         title('Time and Acceleration');
%         
%         if confederate(isubject)==1
%             ASconfederate(itrial,cond,isubject)=nanmean(Sa);
%             ASplayer(itrial,cond,isubject)=nanmean(Sb);
%         elseif confederate(isubject)==2
%             ASconfederate(itrial,cond,isubject)=nanmean(Sb);
%             ASplayer(itrial,cond,isubject)=nanmean(Sa);
%         end;
%         
%         %     aAa(itrial,cond,isubject)=nanmean(Aa); % The Average of the acceleration=
%         %     aAb(itrial,cond,isubject)=nanmean(Ab);
%         %
%     end;
%     
%     
%    figure(3)
% 
%    plot(ASconfederate(4:39,1,isubject),ASplayer(4:39,1,isubject),'.r',ASconfederate(4:39,2,isubject),ASplayer(4:39,2,isubject),'.b');
%  xlabel('AS confederate');
%  ylabel('AS Player');
%  title('AS confederate and player');
%  
%  set(gcf, 'PaperUnits', 'inches');
%             set(gcf, 'PaperSize', [8 8]);
%             set(gcf, 'PaperPositionMode', 'manual');
%             set(gcf, 'PaperPosition', [0 0 8 8]);
%             
%           
%  print(gcf, '-dpdf', ['ASconfederate&player/',subj1,'_',subj2,'.pdf']);
%  
%  clear slowdatawithnan slowdata fastdatawithnan fastdata
%  slowdatawithnan(:,1)=ASconfederate(4:39,1,isubject);
%  slowdatawithnan(:,2)=ASplayer(4:39,1,isubject);
%  slowdata(:,1)=slowdatawithnan(~isnan(slowdatawithnan(:,1)),1);
%  slowdata(:,2)=slowdatawithnan(~isnan(slowdatawithnan(:,2)),2);
% 
%  corr=corrcoef(slowdata);
%  correlation(1,isubject)=corr(2,1);
%  
%  fastdatawithnan(:,1)=ASconfederate(4:39,2,isubject);
%  fastdatawithnan(:,2)=ASplayer(4:39,2,isubject);
%  fastdata(:,1)=fastdatawithnan(~isnan(fastdatawithnan(:,1)),1);
%  fastdata(:,2)=fastdatawithnan(~isnan(fastdatawithnan(:,2)),2);
% 
%  corr=corrcoef(fastdata);
%  correlation(2,isubject)=corr(2,1);
%  
%  end;
% meanspeed(:,:)=[nanmean(ASconfederate,1),nanmean(ASplayer,1)]
% correlation
% save AverageSpeeds ASconfederate ASplayer
% 
% 
% end; 
