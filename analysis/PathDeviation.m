function [ output_args ] = PathDeviation( input_args )
%PathDeviation, Find the deviation taken from a straight-line path to a target
%   Random reach begin and end points are chosen, as well as a point that
%   is between the start and finish for both X and Y. The slope is found,
%   and used to find the linear deviation. The closest point on the
%   straight-line path is found (IntX/Y). When used with multiple points,
%   the integral will be found through a Riemann sum.


%%Beginning and End Points, random
OnsetX=round(rand(1)*1024)
OnsetY=round(rand(1)*768)
EndX=round(rand(1)*1024)
EndY=round(rand(1)*768)

%%Random point along a made-up path
MidX=(min(OnsetX,EndX))+rand(1)*abs(OnsetX-EndX)
MidY=(min(OnsetY,EndY))+rand(1)*abs(OnsetY-EndY)

%%Slope, deviation from straight path, and closest point on the line
m=((EndY-OnsetY)/(EndX-OnsetX))

Dev=(abs(MidX*m-MidY-EndX*m+EndY)/sqrt(m^2+1))

IntX=((MidY-EndY+m*EndY+(MidX/m))/(m+(1/m)))
IntY=(m*(IntX-EndX))+EndY

%%Graphs
plot(OnsetX,OnsetY,'bo'); hold on
plot(EndX,EndY,'ro'); hold on
plot(MidX,MidY,'mo');hold on
plot(IntX,IntY,'ko')

%%Integral


end