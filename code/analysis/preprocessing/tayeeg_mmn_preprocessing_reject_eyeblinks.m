function D = tayeeg_mmn_preprocessing_reject_eyeblinks(id, options)
% Preprocesses one subject from the TAYEEG study.
%   IN:     id      - subject identifier, e.g '0001'
%           optionally:
%           options - the struct that holds all analysis options
%   OUT:    D       - preprocessed data set

% general analysis options
if nargin < 2
    options = tayeeg_analysis_options;
end

% paths and files
details = tayeeg_subjects(id, options);

% record what we're doing
diary(details.eeg.logfile);
tnueeg_display_analysis_step_header('preprocessing', 'compi_mmn', id, options.eeg.preproc);

% check destination folder
if ~exist(details.eeg.preproot, 'dir')
    mkdir(details.eeg.preproot);
end
cd(details.eeg.preproot);

try
    % check for previous preprocessing
    D = spm_eeg_load(details.eeg.prepfile);
    disp(['Subject ' id ' has been preprocessed before.']);
    if options.preproc.overwrite
        clear D;
        disp('Overwriting...');
        error('Continue to preprocessing script');
    else
        disp('Nothing is being done.');
    end
catch
    disp(['Preprocessing subject ' id ' ...']);
    
    %-- preparation -------------------------------------------------------------------------------%
    spm('defaults', 'eeg');
    spm_jobman('initcfg');
    
    % convert .eeg file
    D = tnueeg_convert(details.eeg.files);
    fprintf('\nConversion done.\n\n');
    
    % set channel types (EEG, EOG)
    if ~exist(details.eeg.channeldef, 'file')
        chandef = tayeeg_channel_definition(details);
    else
        load(details.eeg.channeldef);
    end
    D = tnueeg_set_channeltypes(D, chandef, options);
    fprintf('\nChanneltypes done.\n\n');
    
    %-- create montage file -------------------------------------------------------------------------------%
    montage.labelorg = D.chanlabels;
    montage.labelnew = [montage.labelorg(1:64), 'HEOG', 'VEOG']';
    tra = eye(64);
    % Create the average reference montage
    tra = detrend(tra, 'constant');
    
    % HEOG
    tra(65, options.eeg.preproc.montage.heog) = [1 -1];
    % VEOG
    tra(66, options.eeg.preproc.montage.veog) = [1 -1];
    tra = [tra, zeros(size(tra,1),1)];
    montage.tra = tra;
    save(fullfile(details.eeg.montage.file),'montage');
    
    %-- do montage (rereferencing, but keep EOG channel)---------------------------------------------------------%
    if ~exist(details.eeg.montage.file, 'file')
        error('Please create a montage file first.');
    end
    D = tnueeg_do_montage(D, details.eeg.montage.file, options);
    fprintf('\nMontage done.\n\n');
    
    
    %-- filtering ---------------------------------------------------------------------------------%
    D = tnueeg_filter(D, 'high', options);
    switch options.eeg.preproc.downsample
        case 'yes'
            D = tnueeg_downsample(D, options);
    end
    D = tnueeg_filter(D, 'low', options);
    fprintf('\nFilters & Downsampling done.\n\n');
    
    %-- eye blink detection -----------------------------------------------------------------------%
    [Dm, trialStats.numEyeblinks] = tnueeg_eyeblink_detection_spm(D, options);
    savefig(details.eeg.eyeblinkfig);
    fprintf('\nEye blink detection done.\n\n');
    
    %-- eye blink rejection -----------------------------------------------------------------------%
    trialdef = tayeeg_mmn_trial_definition(options, details);
    
    [Dc, ~, trialStats.numEyeartefacts, trialStats.idxEyeartefacts, trialStats.nTrialsNoBlinks, fh] = ...
        tnueeg_eyeblink_rejection_on_continuous_eeg(Dm, trialdef, options);
    savefig(fh, details.eeg.eyeblinkoverlapfigure)
    fprintf('\nevEye blink rejection done.\n\n');
    
    %-- experimental epoching ---------------------------------------------------------------------%
    D = tnueeg_epoch_experimental(Dc, trialdef, options);
    fprintf('\nExperimental epoching done.\n\n');
    
    % keep only description of tone events in data
    % but note that we make the very strong assumption here that the first
    % of the events within each epoch is the tone (could in principle also
    % be a trigger!)
    toneevents = cellfun(@(x) x(1), D.events, 'UniformOutput', false);
    D = events(D, 1:numel(toneevents), toneevents);
    save(D);
    
    
    %-- headmodel ---------------------------------------------------------------------------------%
    fid     = details.eeg.fid;
    hmJob   = tnueeg_headmodel_job(D, fid, details, options);
    spm_jobman('run', hmJob);
    D       = reload(D);
    fprintf('\nHeadmodel done.\n\n');
    
    %-- final artefact rejection ------------------------------------------------------------------%
    [D, trialStats.numArtefacts, trialStats.idxArtefacts, trialStats.badChannels] = ...
        tnueeg_artefact_rejection_threshold(D, options);
    fprintf('\nArtefact rejection done.\n\n');
    
    %-- finish ------------------------------------------------------------------------------------%
    D = move(D, details.eeg.prepfilename);
    trialStats.nTrialsFinal = tnueeg_count_good_trials(D);
    save(details.eeg.goodtrials, 'trialStats');
    
     %--remove events that occurred before the start of the tone sequence,
     % if those are present
    D = spm_eeg_load(details.eeg.prepfile);
    nInitial = length(D.events);
    nEyeblinktrials = numel(trialStats.idxEyeartefacts.tone);
    
    if nInitial+nEyeblinktrials ~= 1800
        warning('Design does not hold 1800 trials - check first trials');
        warning('Marking the first triggered events before the start of the task as bad');
        badInitiTrialIndex = [1:(nInitial+nEyeblinktrials-1800)];
        D = badtrials(D, badInitiTrialIndex, 1);
    end
    
    disp('   ');
    disp(['Detected ' num2str(trialStats.numEyeblinks) ' eye blinks for subject ' id]);
    disp(['Excluded ' num2str(trialStats.numEyeartefacts.all) ' trials due to eye blinks.']);
    disp(['Rejected ' num2str(trialStats.numArtefacts) ' additional bad trials.']);
    disp(['Marked ' num2str(trialStats.badChannels.numBadChannels) ' channels as bad.']);
    disp([num2str(trialStats.nTrialsFinal.all) ' remaining good trials in D.']);
    fprintf('\nPreprocessing done: subject %s in task TAYEEG-MMN.\n', id);
    disp('   ');
    disp('*----------------------------------------------------*');
    disp('   ');
end

cd(options.root);
close all

diary OFF
end
