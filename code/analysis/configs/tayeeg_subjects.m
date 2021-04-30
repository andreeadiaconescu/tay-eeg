function details = tayeeg_subjects(id, options)

if ~ismember(id, options.subjectIDs)
    error('Subject %s does not belong to any group %s. Please choose right options-struct.', ...
        id, options.eeg.part);
end

root = options.root;

%% Paths Behaviour
details = [];
details.root = root;

details.dirSubject                  = sprintf('TAY_%04d', str2num(id));
details.dirID                       = sprintf('%04d', str2num(id));
details.eeg.subjectdataroot         = fullfile(options.dataroot,details.dirSubject);
details.eeg.subjectresultsroot      = fullfile(options.eeg.preproc.grouproot, 'subjects', details.dirSubject);
details.eeg.modelroot               = fullfile(details.eeg.subjectresultsroot, 'model');
details.model.design                = fullfile(details.eeg.modelroot,[options.eeg.stats.design '_design.mat']);
details.model.subjectDesign         = fullfile(details.eeg.modelroot,[options.eeg.stats.design '_designPruned.mat']);
details.model.modelfig              = fullfile(details.eeg.modelroot,[details.dirSubject '_tapas_eHGF.fig']);
details.erp.design                  = fullfile(details.eeg.modelroot,[options.eeg.stats.design '_erpSortedTrials.mat']);
details.model.binnedConditions      = fullfile(details.eeg.modelroot, 'binnedConditions.mat');

% Create subjects results directory for current preprocessing strategy
[~,~] = mkdir(details.eeg.subjectresultsroot);
[~,~] = mkdir(details.eeg.modelroot);

%% EEG
details.eeg.files = sprintf('%s.bdf', details.dirSubject);
% fiducials
details.eeg.fid.labels  = {'NAS'; 'LPA'; 'RPA'};
details.eeg.fid.data    = [1, 85, -41; -83, -20, -65; 83, -20, -65];
%% details for all subjects that follow a common rule
details.eeg.sfxFilter           = 'outcomes'; % labeling the certain kind of analysis
details.eeg.subproname          = sprintf('TAY_%04d', str2num(id));
details.eeg.raw                 = fullfile(details.eeg.subjectdataroot);
details.eeg.subjectroot.results = details.eeg.subjectresultsroot; % own results-subfolder for each preproc strategy, parent to indvidual subject folders
%% EEG Subjects Details (enumerated and automatised)
% prepend path to files
details.eeg.files = strcat(details.eeg.raw, filesep, details.eeg.files);
details.eeg.preproc.eyeBlinkThreshold       = options.eeg.preproc.eyeDetectionThresholdDefault;
details.eeg.preproc.artifact.badtrialthresh = options.eeg.preproc.artifact.badtrialthresh;
details.eeg.preproc.nComponentsforRejection = options.eeg.preproc.nComponentsforRejection;

details.eeg.preproot                     = fullfile(details.eeg.subjectresultsroot, 'spm_preproc');
details.eeg.channeldef                   = fullfile(details.eeg.preproot, 'tayeeg_chandef.mat');
details.eeg.prepfilename                 = [details.eeg.subproname '_' details.eeg.sfxFilter];
details.eeg.source.filename              = fullfile(details.eeg.preproot, ['B' id '_' details.eeg.sfxFilter '.mat']);
details.eeg.tf.filename                  = fullfile(details.eeg.preproot, ['rtf_' id '_' details.eeg.sfxFilter '.mat']);
details.eeg.source.tf.filename           = fullfile(details.eeg.preproot, ['rtf_B' id '_' details.eeg.sfxFilter '.mat']);
details.eeg.source.beamforming.dirname   = fullfile(details.eeg.preproot, 'BF_msp');
details.eeg.source.beamforming.file      = fullfile(details.eeg.source.beamforming.dirname, 'BF.mat');
details.eeg.source.savefilename          = fullfile(details.eeg.preproot, ['B' id '_' details.eeg.sfxFilter '.mat']);
details.eeg.source.logfile               = fullfile(details.eeg.preproot, ...
    [details.eeg.subproname 'source_analysis.log']);
details.eeg.logfile                      = fullfile(details.eeg.preproot, ...
    [details.eeg.subproname '.log']);
% Artefactual Trials
details.eeg.artfname                     = fullfile(details.eeg.preproot, ...
    ['a' details.eeg.subproname '_' details.eeg.sfxFilter '.mat']);
details.eeg.prepfile                     = fullfile(details.eeg.preproot, [details.eeg.subproname '_' details.eeg.sfxFilter '.mat']);
details.eeg.numArtefacts                 = fullfile(details.eeg.preproot, [details.eeg.subproname '_numArtefacts.mat']);

% Create subjects results directory for current preprocessing strategy
[~,~] = mkdir(details.eeg.preproot);

%% Preprocessed data common to all subjects
% Preprocessed Files
details.eeg.fid.labels      = {'NAS'; 'LPA'; 'RPA'};
details.eeg.fid.data       = [1, 85, -41; -83, -20, -65; 83, -20, -65];
details.eeg.prepfile        = fullfile(details.eeg.preproot, ...
    [details.eeg.prepfilename '.mat']);
details.eeg.montage.file    = fullfile(details.eeg.preproot, ...
    [details.eeg.subproname  '_montage.mat']);

details.eeg.totalevents   = fullfile(details.eeg.preproot, ...
    [details.eeg.subproname '_total_event_IDs.mat']);
details.eeg.montagefigure   = fullfile(details.eeg.preproot, ...
    [details.eeg.subproname '_montage.fig']);
details.eeg.trialdefinition = fullfile(details.eeg.preproot, ...
    [details.eeg.subproname '_trialdef.mat']);

details.eeg.eyeblinkfig     = fullfile(details.eeg.preproot, ...
    [details.eeg.subproname '_mmn_EB_detection.fig']);

details.eeg.eyeblinkconfoundsfigure   = fullfile(details.eeg.preproot, ...
    [details.eeg.subproname '_EB_confounds.fig']);

details.eeg.componentconfoundsfigure   = fullfile(details.eeg.preproot, ...
    [details.eeg.subproname '_EB_componentconfounds.fig']);

details.eeg.eyeblinkoverlapfigure  = fullfile(details.eeg.preproot, ...
    [details.eeg.subproname '_mmmn_EB_trial_overlap.fig']);

details.eeg.coregistrationplot        = fullfile(details.eeg.preproot, ...
    [details.eeg.subproname '_coregistration.fig']);
details.eeg.badchannels               = fullfile(details.eeg.preproot, ...
    [details.eeg.subproname '_badchannels.mat']);
details.eeg.goodtrials                = fullfile(details.eeg.preproot, ...
    [details.eeg.subproname '_goodtrials.mat']);
details.eeg.eyeblinkrejectstats       = fullfile(details.eeg.preproot, ...
    [details.eeg.subproname '_EB_rejection_stats.mat']);

%% Single-trial analysis file names
% Image Conversion
details.eeg.conversion.sensor.convRoot  = fullfile(details.eeg.preproot, ['sensor_', details.eeg.prepfilename , '/']);
details.eeg.conversion.sensor.convFile  = fullfile(details.eeg.conversion.sensor.convRoot, 'condition_tone.nii');
details.eeg.conversion.sensor.smoofile  = fullfile(details.eeg.conversion.sensor.convRoot, 'smoothed_condition_tone.nii');

details.eeg.conversion.source.convRoot  = fullfile(details.eeg.preproot, ['source_',id,'_', details.eeg.sfxFilter, '/']);
details.eeg.conversion.source.convFile  = fullfile(details.eeg.conversion.source.convRoot, 'condition_Outcome.nii');
details.eeg.conversion.source.smoofile  = fullfile(details.eeg.conversion.source.convRoot, 'smoothed_condition_Outcome.nii');

details.eeg.conversion.tf.convRoot  = fullfile(details.eeg.preproot, ['tf_',id,'_', details.eeg.sfxFilter, '/']);
details.eeg.conversion.tf.convFile  = fullfile(details.eeg.conversion.tf.convRoot, 'condition_outcome.nii');
details.eeg.conversion.tf.smoofile  = fullfile(details.eeg.conversion.tf.convRoot, 'smoothed_condition_tone.nii');

% First Level Analysis Names
details.eeg.firstLevel.sensor.prefixBetaWave = ['w_' options.eeg.stats.firstLevelDesign];
details.eeg.firstLevel.sensor.prefixPreproc = '';
details.eeg.firstLevel.sensor.prefixImages = ['sensor_' details.eeg.firstLevel.sensor.prefixPreproc];
details.eeg.firstLevel.sensor.pathImages = details.eeg.conversion.sensor.convRoot;
details.eeg.firstLevel.sensor.fileBetaWave = fullfile(details.eeg.preproot, [details.eeg.firstLevel.sensor.prefixBetaWave, details.eeg.prepfilename  '.mat']);
details.eeg.firstLevel.sensor.pathStats   = fullfile(details.eeg.subjectroot.results, 'stats_model', [details.eeg.firstLevel.sensor.prefixImages, options.eeg.stats.firstLevelDesign]);

details.eeg.firstLevel.source.pathImages = details.eeg.conversion.source.convRoot;
details.eeg.firstLevel.source.pathStats  = fullfile(details.eeg.subjectroot.results, 'stats_model', 'source');
details.eeg.firstLevel.source.prefixImages = 'source_';
details.eeg.firstLevel.tf.pathImages     = details.eeg.conversion.tf.convRoot;
details.eeg.firstLevel.tf.pathStats      = fullfile(details.eeg.subjectroot.results, 'stats_model', 'tfsource');
details.eeg.firstLevel.tf.prefixImages   = 'tfsource_';

% take smoothed or unsmoothed images
switch options.eeg.preproc.smoothing
    case 'yes'
        details.eeg.firstLevel.sensor.fileImage  = details.eeg.conversion.sensor.smoofile;
        details.eeg.firstLevel.source.fileImage  = details.eeg.conversion.source.smoofile;
        details.eeg.firstLevel.tf.fileImage      = details.eeg.conversion.tf.smoofile;
    case 'no'
        details.eeg.firstLevel.sensor.fileImage  = details.eeg.conversion.sensor.convFile;
        details.eeg.firstLevel.source.fileImage  = details.eeg.conversion.source.convFile;
        details.eeg.firstLevel.tf.fileImage      = details.eeg.conversion.tf.convFile;
end

%% ERP analysis file names
details.eeg.erp.root          = fullfile(details.eeg.preproot, 'stats_erp');
details.eeg.erp.type          = '2bins';
details.eeg.erp.conditions    = {'Percentile0to20', 'Percentile80to100'};
details.eeg.erp.conditionsName= {'Percentile0to20', 'Percentile80to100'};
details.eeg.erp.fold          = fullfile(details.eeg.erp.root, details.eeg.erp.type);
details.eeg.erp.averaging         = 'r'; % s (standard), r (robust)
switch details.eeg.erp.averaging
    case 'r'
        details.eeg.erp.addfilter = 'f';
    case 's'
        details.eeg.erp.addfilter = '';
end
details.eeg.erp.erpfilename         = [details.eeg.subproname '_' options.eeg.erp.type '_erp'];
details.eeg.erp.contrastWeighting   = 1;
details.eeg.erp.contrastPrefix      = 'diff_';
details.eeg.erp.contrastName        = 'mmn';
details.eeg.erp.difffile            = fullfile(details.eeg.erp.root, ['diffwave' details.eeg.prepfilename  '.mat']);
details.eeg.erp.sourcefile          = fullfile(details.eeg.erp.root, ['B' details.eeg.subproname '_binned_outcomes.mat']);
details.eeg.erp.erpfig              = fullfile(details.eeg.erp.root, ...
                            [details.eeg.subproname '_ERP_']);
                        
details.eeg.erp.redeffile   = fullfile(details.eeg.erp.root, ['redef_' details.eeg.subproname]);
details.eeg.erp.avgfile     = fullfile(details.eeg.erp.root, ['avg_' details.eeg.subproname]);
details.eeg.erp.erpfile     = fullfile(details.eeg.erp.root, details.eeg.erp.erpfilename);
details.eeg.erp.difffile    = fullfile(details.eeg.erp.root, ['diff_' details.eeg.erp.erpfilename]);
%% EEG Quality Control
details.eeg.quality.root = fullfile(details.eeg.subjectroot.results, 'quality');
details.eeg.quality.initialtrials = fullfile(details.eeg.quality.root, [details.eeg.subproname '_numTrialsInitial.mat']);
details.eeg.quality.eyeblinks = fullfile(details.eeg.quality.root, [details.eeg.subproname '_numEyeblinks.mat']);
details.eeg.quality.eyeblinkdetectionfigure = fullfile(details.eeg.quality.root, [details.eeg.subproname '_eyeblinkdetection.fig']);
details.eeg.quality.eyeblinkconfoundsfigure = fullfile(details.eeg.quality.root, [details.eeg.subproname '_eyeblinkconfounds.fig']);
details.eeg.quality.eyeblinkcorrectionfigure = fullfile(details.eeg.quality.root, [details.eeg.subproname '_eyeblinkcorrection']);

details.eeg.quality.epoched_EB_uncorrected = fullfile(details.eeg.preproot, [details.eeg.subproname '_epoched_to_EBs_uncorrected.mat']);
details.eeg.quality.average_EB_uncorrected = fullfile(details.eeg.preproot, [details.eeg.subproname '_epoched_to_EBs_uncorrected_averaged.mat']);
details.eeg.quality.epoched_EB_corrected = fullfile(details.eeg.preproot, [details.eeg.subproname '_epoched_to_EBs_corrected.mat']);
details.eeg.quality.average_EB_corrected = fullfile(details.eeg.preproot, [details.eeg.subproname '_epoched_to_EBs_corrected_averaged.mat']);
details.eeg.quality.averageeyeblinkcorrectionfigure1 = fullfile(details.eeg.quality.root, [details.eeg.subproname '_averageeyeblinkcorrection_channels1.fig']);
details.eeg.quality.averageeyeblinkcorrectionfigure2 = fullfile(details.eeg.quality.root, [details.eeg.subproname '_averageeyeblinkcorrection_channels2.fig']);

details.eeg.quality.badtrialfigures = fullfile(details.eeg.quality.root, [details.eeg.subproname '_badtrials']);
details.eeg.quality.coregmeshfigure = fullfile(details.eeg.quality.root, [details.eeg.subproname '_coregistration_mesh.fig']);
details.eeg.quality.coregdatafigure = fullfile(details.eeg.quality.root, [details.eeg.subproname '_coregistration_data.fig']);
details.eeg.quality.firstlevelmask = fullfile(details.eeg.quality.root, [details.eeg.subproname '_firstlevel_mask']);

%% logging, e.g. single subject batches
details.eeg.log.batches.root = fullfile(details.eeg.subjectroot.results, 'batches');
details.eeg.log.sfxTimeStamp = sprintf('_%s', datestr(now, 'yymmdd_HHMMSS'));
details.eeg.log.batches.statsfile = fullfile(details.eeg.log.batches.root, ...
    sprintf('%s%s.m', 'batch_TAY_stats', details.eeg.log.sfxTimeStamp));

%% logging, e.g. single subject batches
details.eeg.log.batches.root = fullfile(details.eeg.subjectroot.results, 'batches');
details.eeg.log.sfxTimeStamp = sprintf('_%s', datestr(now, 'yymmdd_HHMMSS'));
details.eeg.log.batches.statsfile = fullfile(details.eeg.log.batches.root, ...
    sprintf('%s%s.m', 'batch_TAY_stats', details.eeg.log.sfxTimeStamp));

%% subject-specific options
% EB detection threshold
switch id
    case {'0003', '0006'}
        details.eeg.eyeblinkthreshold = 2;
        options.eeg.preproc.eyeblinkthreshold = details.eeg.eyeblinkthreshold;
    otherwise
        details.eeg.eyeblinkthreshold = options.eeg.preproc.eyeblinkthreshold;
end
