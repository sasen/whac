function [ output_args ] = WhacAnalysis
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

SubjectName{1}={'jlp','jlp'};
SubjectName{2}={'null','ss'};
for s=1:length(SubjectName{1})
    for trialNum=1:21
        load(['/Users/eshayer/whac-a-mole/whac/analysis/Results/RunSplitgame/' SubjectName{1}{s} '_' SubjectName{2}{s} '/' SubjectName{1}{s} '_' SubjectName{2}{s} '_t' num2str(trialNum) '_e3.mat']);
    
        %%Performance, percent of targets hit
        for p = [1 2]
            for i=1:8
                for j=1:30
                    if MoleTypeList{p}(i,j)<=2
                        if (TrialList{p}(i,j)/1000)<30
                            TargetAppear{p}(i,j)=1;
                        else
                            TargetAppear{p}(i,j)=0;
                        end
                        if HitList_p{p}(i,j)>0
                            TargetHit{p}(i,j)=1;
                        else
                            TargetHit{p}(i,j)=0;
                        end
                    end
                end
            end
            TargetPercent{s}(p,trialNum,:)=(sum(sum(TargetHit{p})')/sum(sum(TargetAppear{p})'));
        end
    
        %%Mean X Value, entire game
        for p = [1 2]
            MeanXPos{s}(p,trialNum,:)=nanmean(TrackList{p}(1,:));
            if MeanXPos{s}(p,trialNum,:)>512
                MeanXPos{s}(p,trialNum,:)=1024-MeanXPos{s}(p,trialNum,:);
            end                
        end
    end
end

MeanXPosDiff=MeanXPos{2}(1,:)-MeanXPos{2}(2,:);
figure
hist(MeanXPosDiff,6)

figure
plot(TargetPercent{1}(1,:,:),'b.-')
hold on
plot(TargetPercent{2}(1,:,:),'g.-')
hold on
plot(TargetPercent{2}(2,:,:),'r.-')
xlabel('Trial Number')
ylabel('Hit Percent of Green/Yellow Targets')
legend('subject solo','subject paired','sasen paired','Location','SouthEast')

end