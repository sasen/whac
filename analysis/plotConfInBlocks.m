function plotConfInBlocks(stat,structure)
% function plotConfInBlocks(stat,structure)
%  stat is 2xNumTrials. [player 1; player 2]
% structure is trials per block, eg [3 6 6 6 6 6 6]

ymin = min(stat(:));
ymax = max(stat(:));
dividers = cumsum(structure(1:end-1))+.5;

figure;
subplot(2,1,1),plot(stat(1,:),'rs-'); hold on;
subplot(2,1,1),stem(dividers, max(stat(1,:))*ones(size(dividers)),'k.-');
subplot(2,1,1),stem(dividers, min(stat(1,:))*ones(size(dividers)),'k.-');
axis tight;
%axis([1 sum(structure) ymin ymax]);

subplot(2,1,2),plot(stat(2,:),'bs-'); hold on;
subplot(2,1,2),stem(dividers, max(stat(2,:))*ones(size(dividers)),'k.-');
subplot(2,1,2),stem(dividers, min(stat(2,:))*ones(size(dividers)),'k.-');
axis tight;
%axis([1 sum(structure) ymin ymax]);
xlabel('\fontsize{20}Trial Number');