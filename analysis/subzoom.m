function [] = subzoom(i,j,xlow,xhigh) 
% function [] = subzoom(i,j,xlow,xhigh) 

for ii = 1:i
  for jj = 1:j
    kk = sub2ind([i j],ii,jj);
    subplot(i,j,kk), xlim([xlow xhigh]);
  end
end