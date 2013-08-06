 load('AverageSpeeds.mat')
 subj1list={'35'};
subj2list={'sasen'};
confederate=[2];
slowfastorder={[0 0 0 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2]};  %condition 1 is slow and condition 2 is fast 0 is practice
 ASconfederate=NaN(39,2,10);
 ASplayer=NaN(39,2,10);

        
    for isubject=1:length(subj1list)
    subj1=subj1list{isubject};
    subj2=subj2list{isubject};
    
    for itrial=[4:39];
        trial=num2str(itrial);
        cond=slowfastorder{isubject}(itrial);
         
      
          if confederate(isubject)==1
            ASconfederate(itrial,cond,isubject)=nanmean(Sa);
            ASplayer(itrial,cond,isubject)=nanmean(Sb);

        elseif confederate(isubject)==2
            ASconfederate(itrial,cond,isubject)=nanmean(Sb);
            ASplayer(itrial,cond,isubject)=nanmean(Sa);
        end;
       
        figure(1)
        subplot(2,5,1)
        
    
 plot(ASconfederate(4:39,1,1),ASplayer(4:39,1,1),'.r',ASconfederate(4:93,1,1),ASplayer(4:39,1,1),'.b');


  
    end;  
    end;
 