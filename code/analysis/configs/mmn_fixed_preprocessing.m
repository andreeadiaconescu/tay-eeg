function fix_proproc = mmn_fixed_preprocessing
fix_proproc.trialdef                = 'tone'; % tone, oddball
fix_proproc.downsamplefreq          = 256;
fix_proproc.rereferencing           = 'avref'; % avref, noref
fix_proproc.highpassfreq            = 0.5;
fix_proproc.eyeCorrection           = true;
fix_proproc.keepotherchannels       = 1;
fix_proproc.badTrialsThreshold      = 100;
fix_proproc.baselinecorrection      = 1;
fix_proproc.smoothing               = 'yes';

% Additional Bad Trial/Bad Channel definition options
fix_proproc.artifact.badtrialthresh = 500;
fix_proproc.artifact.lowPassFilter  = 10;
fix_proproc.artifact.badchanthresh  = 0.2;

% Additional Eyeblink Correction correction options
fix_proproc.windowForEyeblinkdetection = 3; % first event of interest (and optionally last)
% NOTE: This sets the default index of the first even of interest in the EEG file, however, this 
% will be adjusted individually for subjects if their EEG file requires a different value. For all
% adjustments, see mnket_subjects.
fix_proproc.eyeblinkthreshold   = 3; % for SD thresholding: in standard deviations, for amp in uV
% NOTE: This sets the default threshold for detecting eye blink events in the EOG, however, this 
% will be adjusted individually for subjects if their EOG requires a different threshold. For all
% adjustments, see mnket_subjects.
fix_proproc.eyeDetectionThresholdDefault = 3; % number of SDs needed to automatically detect an eyeblink
fix_proproc.epochwin                = [-100 450]; % choose the range in which artefacts would be an issue for the statistics
fix_proproc.eyeblinkwin             = [-500 500];
fix_proproc.eyeblinkchannels        = {'VEOG'};
fix_proproc.eyeblinkEEGchannel      = 'AFz';

% options needed for EB rejection
fix_proproc.eyeblinkmode            = 'eventbased'; % uses EEG triggers for trial onsets
fix_proproc.eyeblinkwindow          = 1; % in s around blink events
fix_proproc.eyeblinktrialoffset     = 0.05; % in s: window to discard at beg. of trial
fix_proproc.eyeblinkEOGchannel      = 'VEOG'; % EOG channel (name/idx) to plot

end