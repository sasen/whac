%% This script (& game=0 of plotHitMap) helps visualize the direction of
%% the pattern we might expect.

if ~exist('EValidate','var')
  s1 = 'oddmidline'; s2 = 'evensedges'; ExpNum = 3;
  [EValidate,~] = LoadExpt(s1,s2,ExpNum,'all');
  for trl = 1:length(EValidate)
    [hOns,hMole,hXYZ,moleXY,diffX] = getHitInfo(EValidate{trl});
    for pl = 1:2
      hitOnsets{trl,pl} = hOns{pl};
      hitMoles{trl,pl} = hMole{pl};
      hitXYZs{trl,pl} = hXYZ{pl};
      moleXYs{trl,pl} = moleXY{pl};
      hitXErr{trl,pl} = diffX{pl};
    end
  end
end  %% accumulate EValidate

%%-------- Done Loading & Accumulating Conditions
%% Analyze & Plot

edges = [-inf,linspace(-80,80,17),inf];

p1s1mid = [1 3];
p1s1edg = [2];
p1s2edg = [4 6];
p1s2mid = [5];
p2s1mid = [7 9];
p2s1edg = [8];
p2s2egd = [10 12];
p2s2mid = [11];

figure();
iWasPlayer = [];
for trl = 1:length(EValidate)
  if length(hitXErr{trl,1}) > length(hitXErr{trl,2})
    p = 1;
  else
    p = 2;
  end
  iWasPlayer(trl) = p;

  xErrs = hitXErr{trl,p};
  counts(:,trl) = histc(xErrs, edges);
  subplot(2,6,trl),bar([-100 edges(2:end-1) 100],counts(:,trl),'histc');
  title(num2str(trl));
  axis tight; hold on; 
  plot(0,0,'y+','MarkerSize',15,'LineWidth',2);
  summary(trl,:) = [p trl mean(xErrs) median(xErrs) std(xErrs) skewness(xErrs,0) kurtosis(xErrs,0)];
end
summary

figure();
MidS1 = [1 3 19 21];    MidS2 = [5 23];
OutS1 = [2 20];    OutS2 = [4 6 22 24];
CondList = {MidS1; MidS2; OutS1; OutS2};
for cnd = 1:4
  xErrs = [hitXErr{CondList{cnd}}];
  errCond{cnd} = xErrs;
  histCnd(:,cnd) = histc(xErrs, edges);
  subplot(1,4,cnd),bar([-100 edges(2:end-1) 100],histCnd(:,cnd),'histc');
  axis tight; hold on; 
  plot(0,0,'y+','MarkerSize',15,'LineWidth',2);
  cndsummary(cnd,:) = [cnd mean(xErrs) median(xErrs) std(xErrs) skewness(xErrs,0) kurtosis(xErrs,0)];
end
cndsummary

subplot(1,4,1),title('Midline Sensor 1');
subplot(1,4,2),title('Midline Sensor 2');
subplot(1,4,3),title('Outer Sensor 1');
subplot(1,4,4),title('Outer Sensor 2');


