%% This script plots a player's hit coordinates (x,y) compared to
%%   the target center. 
%% Requires: analyze_xHitErr must precede.

game = 1;  % Change this for different conditions
trials = [4:21]; % Splitgame-specific

%% Access the right condition & player
if game==1
  CondGames = EPair;
  plottitle = 'Condition 3: Paired (subject)';
elseif game==0
  CondGames = EValidate;
  trials = [7 9 11];   % [4:21]; % Splitgame-specific
  player = 2;
  plottitle = ['Midline: Player ' num2str(player) ' Trl [7 9 11] Sens [1 1 2]'];
  game = player;
elseif game==2
  CondGames = EPair;
  plottitle = 'Condition 3: Paired (confed)';
elseif game==3
  CondGames = ESolo;
  plottitle = 'Condition 2: Solo Splitgame';
elseif game==4
  CondGames = EDist;
  plottitle = 'Condition 1: Distractor-free';
end


%% Setup figure 
%    Sets axis scaling on the compass plots
%    Black up/down arrow points toward player
%    Black left/right arrow points toward midline
figure;
subplot(2,2,2),compass([0],[-42],'k'); hold on
subplot(2,2,2),compass([-42],[0],'k');
subplot(2,2,4),compass([0],[42],'k'); hold on
subplot(2,2,4),compass([42],[0],'k');
subplot(1,2,1),title(plottitle);

for trl = trials
  myg = CondGames{trl};
  xRes = myg.ScrRes(1)/2; yRes = myg.ScrRes(2);  %% splitgame-specific
  myt = myg.t; %[1:800]; %myg.t;
  
  hits = hitXYZs{trl,game};
  mCtrs = moleXYs{trl,game};
  nHits = length(hits);
  
  ss = myg.SwitchSides; %% 1=side1, -1=side2
  if game==2  % player2
    ss = -ss; %% p2 starts on side2, etc
  end
  if ss==-1        % side1 transform
    hits(1,:) = hits(1,:) + xRes;
    mCtrs(1,:) = mCtrs(1,:) + xRes;
    col = 'm';
  elseif ss==1     % side2 transform
    hits(1,:) = xRes - hits(1,:);
    hits(2,:) = yRes - hits(2,:);
    mCtrs(1,:) = xRes - mCtrs(1,:);
    mCtrs(2,:) = yRes - mCtrs(2,:);
    col = 'c';
  end
  
  subplot(1,2,1), hold on;
  % -Y = like psychtoolbox screen coordinates
  %  plot(myg.p1x(myt),-myg.p1y(myt),col);
  hits(2,:) = -hits(2,:);  
  mCtrs(2,:) = -mCtrs(2,:);
  axis([0 xRes*2 -yRes 0])  
  for hh = 1:nHits 
    plot([hits(1,hh) mCtrs(1,hh)], [hits(2,hh) mCtrs(2,hh)],'b','LineWidth',2)
    plot(hits(1,hh),hits(2,hh),[col 'x'],'MarkerSize',8,'LineWidth',2)
    plot(mCtrs(1,hh),mCtrs(2,hh),'kp','MarkerSize',10)
  end  
  %%% HEREHEREHERE take means of deltaX for sides separately
  deltaX = hits(1,1:nHits) - mCtrs(1,1:nHits);
  deltaY = hits(2,1:nHits) - mCtrs(2,1:nHits);

  subplot(2,2,3+ss), compass(deltaX,deltaY,col); hold on
end