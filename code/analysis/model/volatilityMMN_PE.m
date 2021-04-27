function [lowIdcs,highIdcs,trajectory] = volatilityMMN_PE(traj,mode)

percentPE = 15;
nTrials   = size(traj,1);
switch mode
    case 'bayesSurprise'
        trajectory = abs(traj);
    case 'volatilityPE'
        trajectory = traj;
end

peValues = trajectory;
nLow    = round(percentPE/100 *nTrials);
nHigh   = nLow -1;

[sortedPE, sortIdx] = sort(peValues);

lowIdcs     = sortIdx(1: nLow);
highIdcs    = sortIdx(end-nHigh: end);

% figure
lowValues   = sortedPE(1: nLow);
highValues  = sortedPE(end-nHigh: end);

figure; plot(peValues, '.k');
hold on;
plot([1 nTrials], [max(lowValues) max(lowValues)], '-g');
plot([1 nTrials], [min(highValues) min(highValues)], '-r');
legend('All PE values', ['Lowest ' num2str(percentPE) '%'],...
    ['Highest ' num2str(percentPE) '%']);
title(['Low and high ' mode]);

end