function  M=DataReadonetrial3d

clear all
clc
close all

dataframerate=240;
tablez=9;
maxz=20;
screenresx=1024;
screenresy=768;

MatData = load('Data_Onetrial/mj_cd_t1_e1.mat');
data_s1=(MatData.TrackList{1})';
data_s2=(MatData.TrackList{2})';
time=0:1/dataframerate:length(data_s1)*1/dataframerate;
inddefined=~isnan(data_s1(:,1));

ts_s1=timeseries(data_s1(inddefined,:),time(inddefined));
ts_s2=timeseries(data_s2(inddefined,:),time(inddefined));
ts_s1_resamp=resample(ts_s1,1/240:1/dataframerate:ts_s1.time(end));
ts_s2_resamp=resample(ts_s2,1/240:1/dataframerate:ts_s1.time(end));

MatData.Targetstarttime=MatData.TrialList/1000;
for itarg1=1:(size(MatData.TrialList,1));
    for itarg2=1:(size(MatData.TrialList,2));
        if MatData.HitList_t(itarg1,itarg2)
            MatData.Targetendtime(itarg1,itarg2)=MatData.HitList_t(itarg1,itarg2);
            MatData.feedbackendtime(itarg1,itarg2)=MatData.HitList_t(itarg1,itarg2)+0.75;
        else
            MatData.Targetendtime(itarg1,itarg2)=(MatData.TrialList(itarg1,itarg2)+1250)/1000;
            MatData.feedbackendtime(itarg1,itarg2)=0;
        end;
    end;
end;



nframes=length(ts_s1_resamp.time);
rotationAngle = (1+sin(linspace(0,30*pi,length(ts_s1_resamp.data))))*15 +20;
elevation=(1+sin(linspace(30,30*pi,length(ts_s1_resamp.data))))*15 +20;
ifr=1;
for iframe=500:3:nframes
    %clear data from graph
    %cla
    
    % Draw older dots faded
    %                     fadePct = 0.20;
    %                     for n=max([1 iframe-5]):iframe
    %                         scatter3(ts_a_resamp.data(n,3), ts_a_resamp.data(n,1),ts_a_resamp.data(n,2), 25, fade([0,0,1],fadePct), 'filled');
    %                         scatter3(ts_b_resamp.data(n,3), ts_b_resamp.data(n,1),ts_b_resamp.data(n,2), 25, fade([1,0,0],fadePct), 'filled');
    %                         fadePct = fadePct+0.15;
    %                     end
    
    % Draw current dot at full opacity
    %percent=-ifr*5;
    scatter3(ts_s1_resamp.data(iframe-40:iframe-1,1),ts_s1_resamp.data(iframe-40:iframe-1,2),ts_s1_resamp.data(iframe-40:iframe-1,3) ,60,[0,1,1],'filled');
    hold on
    scatter3(ts_s2_resamp.data(iframe-40:iframe-1,1),ts_s2_resamp.data(iframe-40:iframe-1,2),ts_s2_resamp.data(iframe-40:iframe-1,3) ,60,[1,1,0],'filled');
    hold on
    scatter3(ts_s1_resamp.data(iframe,1),ts_s1_resamp.data(iframe,2),ts_s1_resamp.data(iframe,3) ,60,[0,1,1]*0.5,'filled');
    hold on
    scatter3(ts_s2_resamp.data(iframe,1),ts_s2_resamp.data(iframe,2),ts_s2_resamp.data(iframe,3) ,60,[1,1,0]*0.5,'filled');
    hold on
    
    tinds=find(ts_s1_resamp.time(iframe)>=MatData.Targetstarttime & ts_s1_resamp.time(iframe)<=MatData.Targetendtime);
    
    ang=(1:360)';
    if ~isempty(tinds)
        for itarg=1:length(tinds)
            curtarg=tinds(itarg);
            targetx=MatData.LocationListX(curtarg)+20*sind(ang);
            targety=MatData.LocationListY(curtarg)+20*cosd(ang);
            targetz=ones(length(ang),1)*tablez;
            targetcol=MatData.TargetColors(MatData.MoleTypeList(curtarg),:)/255;
            patch(targetx,targety,targetz,targetcol);
            hold on
            
        end;
        
    end;
    
    tindsfeedbk=find(ts_s1_resamp.time(iframe)>=MatData.Targetendtime & ts_s1_resamp.time(iframe)<=MatData.feedbackendtime);
    ang=(1:360)';
    if ~isempty(tindsfeedbk)
        for itarg=1:length(tindsfeedbk)
            curtarg=tindsfeedbk(itarg);
            targetx=MatData.LocationListX(curtarg)+40*sind(ang);
            targety=MatData.LocationListY(curtarg)+40*cosd(ang);
            targetz=ones(length(ang),1)*tablez;
            if MatData.HitList_p(curtarg)==1
                targetcol=[0,1,1];
            elseif MatData.HitList_p(curtarg)==2
                targetcol=[1,1,0];
            end;
            patch(targetx,targety,targetz,targetcol);
            hold on
            
        end;
        
    end;
    
    
    
    
    hold off
    %scatter3([1,1],[-5.2,5.8],[21.5,21.5],50,[0,1,0],'filled');
    text(0,0,8,sprintf('%5.3f',ts_s2_resamp.time(iframe)),'BackgroundColor',[.7 .9 .7]);
    xlabel('X Position');
    ylabel('Y Position ');
    zlabel('Z Position');
    title('Z,X and Y Positions');
    % Ensure axis limits remain fixed
    xlim([0 screenresx]);ylim([0 screenresy]);zlim([tablez maxz]);
    grid on
    % Rotate view
    view(rotationAngle(iframe),10);%elevation(iframe));
    %view(90,30);
    % Draw and pause for animation
    drawnow;
    %M(ifr)=getframe();
    ifr1=ifr+1;
    pause(0.001);
end;

%    h2=figure(2);

end

% Takes an RGB color and fades it
function c = fade(color, percent)
if isnan(percent)
    percent = 0.01;
end
colorHSV = rgb2hsv(color);
colorHSV(2) = colorHSV(2).*percent;
colorHSV(3) = colorHSV(3)+(1-percent)/3.5;
c = hsv2rgb(colorHSV);
c(c<0) = 0;
c(c>1) = 1;
end

