function plotccor(sig1,sig2,ylabelstr)
% function plotccor(sig1,sig2)
% Plot cross-correlation of 2 signals, and the signals

[R11none,tau] = xcorr(sig1,99);
R11coeff = xcorr(sig1,99,'coeff');
R22none = xcorr(sig2,99);
R22coeff = xcorr(sig2,99,'coeff');

R12none = xcorr(sig1,sig2,99);
[rmaxnone,imaxnone]=max(R12none);
tmaxnone = tau(imaxnone);

R12coeff = xcorr(sig1,sig2,99,'coeff');
[rmaxcoeff,imaxcoeff]=max(R12coeff);
tmaxcoeff = tau(imaxcoeff);

figure;
subplot(2,2,1),plot(tau,R11none,'r'); hold on;
subplot(2,2,1),plot(tau,R22none,'b');
subplot(2,2,1),plot(tau,R12none,'g.-');
subplot(2,2,1),plot(tmaxnone,rmaxnone,'ko'); axis tight;
title(['Unnormalized crosscorr: Max \tau  at ' num2str(tmaxnone)]);

subplot(2,2,2),plot(tau,R11coeff,'r'); hold on;
subplot(2,2,2),plot(tau,R22coeff,'b');
subplot(2,2,2),plot(tau,R12coeff,'g.-');
subplot(2,2,2),plot(tmaxcoeff,rmaxcoeff,'ko'); axis tight;
title(['Normalized crosscorr: Max \tau  at ' num2str(tmaxcoeff)]);

subplot(2,1,2),plot(sig1,'r.-'); hold on;
subplot(2,1,2),plot(sig2,'b.-'); axis tight;
ylabel(ylabelstr); legend('player1','player2');
