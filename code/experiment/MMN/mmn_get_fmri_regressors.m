function regressors = mmn_get_fmri_regressors( MMN )
%MMN_PLOT_EVENTS Summary of this function goes here
%   Detailed explanation goes here

load('design/MMN_conditions.mat');

% triggerCodes
scanTrig = MMN.scanner.trigger;

% collect auditory events
regressors.toneTimes = MMN.stimuli.audTimes;
regressors.toneTypes = MMN.stimuli.audSequence;
regressors.toneTypes(end) = [];

% get condition labels from design file
regressors.roving = conditions.roving;
regressors.phases = conditions.phases;

% collect visual events
regressors.visualTimes = MMN.stimuli.visTimes(MMN.stimuli.visSequence ~= 0);

% collect button press events
regressors.buttonTimes = MMN.responses.times(MMN.responses.keys ~= scanTrig)/1000;
stopPressTime = (MMN.stopScreen.Serial - MMN.startScan.Serial)/1000;
regressors.buttonTimes = [regressors.buttonTimes; stopPressTime]';

save(['COMPA_' MMN.subject.ID '_regressors.mat'], 'regressors');

end