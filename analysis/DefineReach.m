function [ output_args ] = DefineReach(D)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

load '/Users/eshayer/whac-a-mole/whac/analysis/Results/RunSplitgame/jlp_ss/jlp_ss_t10_e3.mat'

Reach    = cell(1,2);
Reach{1} = NaN(size(TrackList{1},2),1);
Reach{2} = NaN(size(TrackList{1},2),1); % End in column 1. 1 indicates reach starts

for p = [1 2]
    for i=1:8
        for j=1:30
            if HitList_t{p}(i,j) >0 %If a hit
                Reach{p}((find(TrackList{3}==(round(200*HitList_t{p}(i,j))))),1)=1; %Stamps hits in TrackList-sized matrix with a one
            end
        end
    end
    n=1;
    for i=1:size(Reach{p},1)
        if Reach{p}(i,:)==1
            HitStamps{p}(n,:)=i;
            n=n+1;
        end
    end
end

MoleLocTarget      = cell(1,2);
MoleLocTarget{1}   = NaN(8,30,5);
MoleLocTarget{2}   = NaN(8,30,5);
MoleLocDistract    = cell(1,2);
MoleLocDistract{1} = NaN(8,30,5);
MoleLocDistract{2} = NaN(8,30,5);

for p = [1 2]
    for i=1:8
        for j=1:30
            if TrialList{p}(i,j)/1000<30
                if MoleTypeList{p}(i,j)<=2
                   MoleLocTarget{p}(i,j,:)=[round(((TrialList{p}(i,j)/1000)*200));LocationListX{p}(i,j);LocationListY{p}(i,j);0;HitList_t{p}(i,j)];
                else
                    MoleLocDistract{p}(i,j,:)=[round(((TrialList{p}(i,j)/1000)*200));LocationListX{p}(i,j);LocationListY{p}(i,j);0;HitList_t{p}(i,j)];
                end
            end
        end
    end
end


figure
m=1;
for k=2:min(size(HitStamps{1},1),size(HitStamps{2},1))
    for p = [2]
        hold off
        plot3(TrackList{p}(1,HitStamps{p}(m):HitStamps{p}(k)),TrackList{p}(2,HitStamps{p}(m):HitStamps{p}(k)),TrackList{p}(3,HitStamps{p}(m):HitStamps{p}(k)),'b-'); hold on
%         plot3(TrackList{p}(1,HitStamps{p}(k)),TrackList{p}(2,HitStamps{p}(k)),TrackList{p}(3,HitStamps{p}(k)),'r*'); hold on
%         plot3(TrackList{2}(1,HitStamps{2}(m):HitStamps{2}(k)),TrackList{2}(2,HitStamps{2}(m):HitStamps{2}(k)),TrackList{2}(3,HitStamps{2}(m):HitStamps{2}(k)),'b-'); hold on
%         plot3(TrackList{2}(1,HitStamps{2}(k)),TrackList{2}(2,HitStamps{2}(k)),TrackList{2}(3,HitStamps{2}(k)),'r*'); hold off
        xlabel('X Position')
        ylabel('Y Position')
        zlabel('Z Position')
        title(['Path from hit to hit, t=' num2str(HitStamps{p}(m)) 'to t=' num2str(HitStamps{p}(k))])
        axis([0 512 0 768 0 12])
        for i=1:8
            for j=1:30
                if MoleLocTarget{p}(i,j,5)>HitStamps{p}(m) && MoleLocTarget{p}(i,j,5)<HitStamps{p}(k)
                    plot3(MoleLocTarget{p}(i,j,2),MoleLocTarget{p}(i,j,3),MoleLocTarget{p}(i,j,4),'.g'); hold on
                elseif (MoleLocTarget{p}(i,j,1)+250)>HitStamps{p}(m) && (MoleLocTarget{p}(i,j,1)+250)<HitStamps{p}(k)
                    plot3(MoleLocTarget{p}(i,j,2),MoleLocTarget{p}(i,j,3),MoleLocTarget{p}(i,j,4),'og'); hold on
                elseif MoleLocTarget{p}(i,j,1)>HitStamps{p}(m) && MoleLocTarget{p}(i,j,1)<HitStamps{p}(k)
                    plot3(MoleLocTarget{p}(i,j,2),MoleLocTarget{p}(i,j,3),MoleLocTarget{p}(i,j,4),'og'); hold on
                end
                if MoleLocDistract{p}(i,j,5)>HitStamps{p}(m) && MoleLocDistract{p}(i,j,5)<HitStamps{p}(k)
                    plot3(MoleLocDistract{p}(i,j,2),MoleLocDistract{p}(i,j,3),MoleLocDistract{p}(i,j,4),'.r'); hold on
                elseif (MoleLocDistract{p}(i,j,1)+250)>HitStamps{p}(m) && (MoleLocDistract{p}(i,j,1)+250)<HitStamps{p}(k)
                    plot3(MoleLocDistract{p}(i,j,2),MoleLocDistract{p}(i,j,3),MoleLocDistract{p}(i,j,4),'or'); hold on
                elseif MoleLocDistract{p}(i,j,1)>HitStamps{p}(m) && MoleLocDistract{p}(i,j,1)<HitStamps{p}(k)
                    plot3(MoleLocDistract{p}(i,j,2),MoleLocDistract{p}(i,j,3),MoleLocDistract{p}(i,j,4),'or'); hold on
                end
            end
        end
    end
    waitforbuttonpress
    m=m+1;    
end



% for i=1:size(HitStamps{p},1)
%     for j=Reach{p}
end