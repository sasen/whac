function [ output_args ] = PathDeviation(tOnset,tEnd)
%PathDeviation, Find the deviation taken from a straight-line path to a target
%   Random reach begin and end points are chosen, as well as a point that
%   is between the start and finish for both X and Y. The slope is found,
%   and used to find the linear deviation. The closest point on the
%   straight-line path is found (IntX/Y). When used with multiple points,
%   the integral will be found through a Riemann sum.

SubjectName{1}={'jlp','jlp'};
SubjectName{2}={'null','ss'};
s=1;
trialNum=10;
load(['/Users/eshayer/whac-a-mole/whac/analysis/Results/RunSplitgame/' SubjectName{1}{s} '_' SubjectName{2}{s} '/' SubjectName{1}{s} '_' SubjectName{2}{s} '_t' num2str(trialNum) '_e3.mat']);



%%Redefining Time into TrackList format
On  = find(TrackList{3}==(round(240*tOnset)))
End = find(TrackList{3}==(round(240*tEnd)))
if 1==isempty(On)
    On  = find(TrackList{3}==(round(240*tOnset)+1));
end
if 1==isempty(End)
    End = find(TrackList{3}==(round(240*tEnd)+1));
end

%%Beginning and End Points
OnsetX = TrackList{1}(1,On);
OnsetY = TrackList{1}(2,On);
EndX   = TrackList{1}(1,End);
EndY   = TrackList{1}(2,End);

%%Slope
m=((EndY-OnsetY)/(EndX-OnsetX));

for i=On:End
    i
    MidX=TrackList{1}(1,i);
    MidY=TrackList{1}(2,i);
    IntX=(((m*EndX)-EndY+(MidX/m)+MidY)/(m+(1/m)));
    IntY=(m)*(IntX-EndX)+EndY;
    Dev(1,i)=sqrt(((MidX-IntX)^2)+((MidY-IntY)^2))
end

[MaxDev,tMax]=max(Dev)

MidX=TrackList{1}(1,tMax);
MidY=TrackList{1}(2,tMax);
IntX=(((m*EndX)-EndY+(MidX/m)+MidY)/(m+(1/m)));
IntY=((m)*(IntX-EndX))+EndY;



%%Graphs
figure
plot([OnsetX,EndX],[OnsetY,EndY],'r.-'); hold on
plot(TrackList{1}(1,On:End),TrackList{1}(2,On:End),'b.-'); hold on
plot([MidX,IntX],[MidY,IntY],'k-')


end