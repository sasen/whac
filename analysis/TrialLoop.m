function [ output_args ] = TrialLoop(~)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

for ExpType=1:3
    if ExpType==1
        ExpNum=3; %Paired Splitgame
        Files = dir('../../WAM/RunSplitgamePaired/');
        for i=4:size(Files,1)
            us=find(Files(i,1).name=='_');
            s1=Files(i,1).name(1:us-1);
            s2=Files(i,1).name(us+1:end);
            for pl=1:2
                disp(Files(i,1).name)
                disp(pl)
                [reaches AErr Dev D Db] = EliReaches(s1,s2,ExpNum,pl);
            end
        end       
    elseif ExpType==2
        ExpNum=3; %Solo Splitgame
        Files = dir('../../WAM/RunSplitgameSolo/');
        for i=4:size(Files,1)
            us=find(Files(i,1).name=='_');
            s1=Files(i,1).name(1:us-1);
            s2=Files(i,1).name(us+1:end);
            for pl=1:2
                [reaches AErr Dev D Db] = EliReaches(s1,s2,ExpNum,pl);
            end
        end
    elseif ExpType==3
        ExpNum=4; %Solo Targetless
        Files = dir('../../WAM/RunDistractors/');
        for i=4:size(Files,1)
            us=find(Files(i,1).name=='_');
            s1=Files(i,1).name(1:us-1);
            s2=Files(i,1).name(us+1:end);
            for pl=1:2
                [reaches AErr Dev D Db] = EliReaches(s1,s2,ExpNum,pl);
            end
        end
    end
end

end

