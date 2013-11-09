%% loading up all trajectories for all conditions of Splitgame experiments
% clear all;
% 
% [DistCond, DistSubjects] = LoadCondition('RunDistractors');
% [SoloCond, SoloSubjects] = LoadCondition('RunSplitgameSolo');
[PairedCond, PairedSubjects] = LoadCondition('RunSplitgamePaired');

for n = 1:length(DistSubjects{1,1})
    myOrder = [];
    name = DistSubjects{1,1}{n};
    sI = findSubject(name,SoloSubjects);
    if strcmp(name,'finaltest')
        name = 'ss';
        pI = findSubject(name,PairedSubjects);
    end
    myOrder(1) = PairedCond{pI,1}.ExptStartTime;
    myOrder(2) = SoloCond{sI,1}.ExptStartTime;
    myOrder(3) = DistCond{n,1}.ExptStartTime;
    showme{n,1} = sprintf('%s Pair %s Solo Dist',name,datestr(myOrder(1)));    
end
showme
%save('all3conditions.mat');