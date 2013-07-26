function [D] = Performance(s1,s2,ExpNum)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if ExpNum==3
    gameType='RunSplitgame';
elseif ExpNum==4
    gameType='RunDistractors';
end

for t=1:21
    D{t}=load(['Results/' gameType '/' s1 '_' s2 '/' s1 '_' s2 '_t' num2str(t) '_e' num2str(ExpNum) '.mat']);
    %%Performance, percent of targets hit
        for p = [1 2]
            [maxI, maxJ] = size(D{t}.MoleTypeList{p});
            for i=1:maxI
                for j=1:maxJ
                    if D{t}.MoleTypeList{p}(i,j)<=2
                        if (D{t}.TrialList{p}(i,j)/1000)<30
                            TargetAppear{p,t}(i,j)=1;
                        else
                            TargetAppear{p,t}(i,j)=0;
                        end
                        if D{t}.HitList_p{p}(i,j)>0
                            TargetHit{p,t}(i,j)=1;
                        else
                            TargetHit{p,t}(i,j)=0;
                        end
                    end
                end
            end
            TargetPercent{p}(t,:)=(sum(sum(TargetHit{p,t})')/sum(sum(TargetAppear{p,t})'));
        end
    
        %%Mean X Value, entire game
        for p = [1 2]
            MeanXPos{p}(t,:)=nanmean(D{t}.TrackList{p}(1,:));
            if MeanXPos{p}(t,:)>512
                MeanXPos{p}(t,:)=1024-MeanXPos{p}(t,:);
            end
        end
end

end