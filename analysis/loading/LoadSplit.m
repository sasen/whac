%% loading up all trajectories for all conditions of Splitgame experiments
clear all;

[DistCond, DistSubjects] = LoadCondition('RunDistractors');
[SoloCond, SoloSubjects] = LoadCondition('RunSplitgameSolo');
[PairedCond, PairedSubjects] = LoadCondition('RunSplitgamePaired');

save('all3conditions.mat');