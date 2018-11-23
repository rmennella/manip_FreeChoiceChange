close all
% Grey screen
subplot(5,1,1)
plot(tstimcheck.greyscreen)
title('Grey screen (0.5s)') 


% Jitter
subplot(5,1,2)
plot(tstimcheck.progrJitter, 'b')
hold on
plot(tstimcheck.realJitter, 'r')
hold off
title('Jitter Fixation') 

% scene
subplot(5,1,3)
plot(tstimcheck.scene)
title('Scene duration (1.5s)')

% 1stRT
subplot(5,1,4)
plot(simulate_respCheck.firstRT, 'b')
hold on
plot(cresponse.timeFirstChoice, 'r')
hold off
title('1st RT')

% 2ndtRT
subplot(5,1,4)
plot(simulate_respCheck.firstRT, 'b')
hold on
plot(simulate_respCheck.secondRT, 'ro','LineWidth', 3)
hold off
title('2nd RT')

% RT differences
subplot(5,1,5)
plot(abs(simulate_respCheck.firstRT - cresponse.timeFirstChoice), 'b')
hold on
plot(abs(simulate_respCheck.secondRT - cresponse.timeSecondChoice), 'ro', 'LineWidth', 3)
hold off
title('Difference in Response Time (VRAI - CODED)')
legend({'1st','2nd'})