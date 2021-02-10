function mmn_plot_events( MMN )
%MMN_PLOT_EVENTS Summary of this function goes here
%   Detailed explanation goes here

% triggerCodes
scanTrig = MMN.scanner.trigger;
rightTrig = MMN.keys.right;
leftTrig = MMN.keys.left;

% collect auditory events
aTimes = MMN.stimuli.audTimes;

% collect trigger events
tTimes = MMN.responses.times(MMN.responses.keys == scanTrig)/1000;

% collect visual events
vTimes = MMN.stimuli.visTimes(MMN.stimuli.visSequence ~= 0);
vRightTimes = MMN.stimuli.visTimes(MMN.stimuli.visSequence == 1);
vLeftTimes = MMN.stimuli.visTimes(MMN.stimuli.visSequence == 2);

% collect button press events
rTimes = MMN.responses.times(MMN.responses.keys ~= scanTrig)/1000;
rKeys = MMN.responses.keys(MMN.responses.keys ~= scanTrig); 
bRightTimes = rTimes(rKeys == rightTrig);
bLeftTimes = rTimes(rKeys == leftTrig);

stopPressTime = (MMN.stopScreen.Serial - MMN.startScan.Serial)/1000;

% plot
figure; hold on;
ylim([-1 4]);
xlim([0 stopPressTime]);

stem(tTimes, ones(numel(tTimes), 1), 'b');
stem(aTimes, repmat(0.5, numel(aTimes), 1), 'k');

stem(vRightTimes, repmat(2, numel(vRightTimes), 1), 'r');
stem(vLeftTimes, repmat(2, numel(vLeftTimes), 1), 'g');

stem(bRightTimes, repmat(3, numel(bRightTimes), 1), 'm');
stem(bLeftTimes, repmat(3, numel(bLeftTimes), 1), 'y');

stem(stopPressTime, 3, 'c');

legend('Scanner Triggers', 'Auditory Events', ...
    'Visual Events Right', 'Visual Events Left', ...
    'Button Presses Right', 'Button Presses Left', ...
    'End Button Press');

xlabel('Time [s]');
ylabel('Trigger Events');

savefig(['COMPI_' MMN.subject.ID '_events.fig']);

end

