function D = compi_mmn_preprocessing_reject_eyeblinks(id, options)
% Preprocesses one subject from the COMPI study.
%   IN:     id      - subject identifier, e.g '0001'
%           optionally:
%           options - the struct that holds all analysis options
%   OUT:    D       - preprocessed data set

% general analysis options
if nargin < 2
    options = compi_ioio_options;
end

% paths and files
details = compi_ioio_subjects(id, options);

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
        chandef = compi_channel_definition(details);
    else
        load(details.eeg.channeldef);
    end
    D = tnueeg_set_channeltypes(D, chandef, options);
    fprintf('\nChanneltypes done.\n\n');
    
    % do montage (rereferencing, but keep EOG channel)
    if ~exist(options.eeg.montage, 'file')
        error('Please create a montage file first.');
    end
    D = tnueeg_do_montage(D, options.eeg.montage, options);
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
    if ~exist(details.eeg.trialdefinition, 'file')
            trialdef = compi_mmn_trial_definition(options, details);
        else
            load(details.eeg.trialdefinition);
    end
    
    [Dc, ~, trialStats.numEyeartefacts, trialStats.idxEyeartefacts, trialStats.nTrialsNoBlinks, fh] = ...
        tnueeg_eyeblink_rejection_on_continuous_eeg(Dm, trialdef, options);
    savefig(fh, details.eeg.overlapfig)
    fprintf('\nEye blink rejection done.\n\n');
    
    %-- experimental epoching ---------------------------------------------------------------------%
    D = tnueeg_epoch_experimental(Dc, trialdef, options);
    fprintf('\nExperimental epoching done.\n\n');
    
    %-- headmodel ---------------------------------------------------------------------------------%
    fid     = load(details.eeg.fiducialmat);
    hmJob   = tnueeg_headmodel_job(D, fid, details, options);
    spm_jobman('run', hmJob);
    D       = reload(D);
    fprintf('\nHeadmodel done.\n\n');
    
    %-- final artefact rejection ------------------------------------------------------------------%
    %D               = tnueeg_eyeblink_rejection_on_epochs_tnu(D, idxEyeartefacts);
    [D, trialStats.numArtefacts, trialStats.idxArtefacts, trialStats.badChannels] = ...
        tnueeg_artefact_rejection_threshold(D, options);
    fprintf('\nArtefact rejection done.\n\n');
    
    %-- finish ------------------------------------------------------------------------------------%
    D = move(D, details.eeg.prepfilename);
    trialStats.nTrialsFinal = tnueeg_count_good_trials(D);
    save(details.eeg.trialstats, 'trialStats');
    
    disp('   ');
    disp(['Detected ' num2str(trialStats.numEyeblinks) ' eye blinks for subject ' id]);
    disp(['Excluded ' num2str(trialStats.numEyeartefacts.all) ' trials due to eye blinks.']);
    disp(['Rejected ' num2str(trialStats.numArtefacts) ' additional bad trials.']);
    disp(['Marked ' num2str(trialStats.badChannels.numBadChannels) ' channels as bad.']);
    disp([num2str(trialStats.nTrialsFinal.all) ' remaining good trials in D.']);
    fprintf('\nPreprocessing done: subject %s in task DPRST-MMN.\n', id);
    disp('   ');
    disp('*----------------------------------------------------*');
    disp('   ');
end

cd(options.workdir);
close all

diary OFF
end
