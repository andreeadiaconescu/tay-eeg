function tayeeg_mmn_analyze_subject( id, options )
%TAYEEG_ANALYZE_SUBJECT Performs all analysis steps for one subject of the MNKET study (up until
%first level modelbased statistics)
%   IN:     id  - subject identifier string, e.g. '0001'
%   OUT:    --

if nargin < 2
    options = tayeeg_analysis_options;
end

fprintf('\n===\n\t The following pipeline Steps per subject were selected. Please double-check:\n\n');
disp(options.eeg.pipe.executeStepsPerSubject);
fprintf('\n\n===\n\n');
pause(2);

doPreprocessing         = ismember('correct_eyeblinks', options.eeg.pipe.executeStepsPerSubject);
doModelling             = ismember('create_behav_regressors', options.eeg.pipe.executeStepsPerSubject);  
doRunStatsSensor        = ismember('run_stats_sensor', options.eeg.pipe.executeStepsPerSubject);
doErpAnalysis           = ismember('run_erp_analysis', options.eeg.pipe.executeStepsPerSubject);
doRunSources            = ismember('extract_sources', options.eeg.pipe.executeStepsPerSubject);
doRunStatsSource        = ismember('run_stats_source', options.eeg.pipe.executeStepsPerSubject);
doComputeBetaWave       = ismember('compute_beta_wave', options.eeg.pipe.executeStepsPerSubject);
doRunTFSources          = ismember('extract_tf', options.eeg.pipe.executeStepsPerSubject);
doRunStatsTFSource      = ismember('run_stats_tfsource', options.eeg.pipe.executeStepsPerSubject);

% Preparation and Pre-processing
if doPreprocessing
    tayeeg_mmn_preprocessing_reject_eyeblinks(id, options);
end

% Applies Bayesian Learning Model to Input and Creates regressors from behavioral model
if doModelling
    tayeeg_mmn_model(id, options)
end

% Image conversion and GLM in sensor space
if doRunStatsSensor
    fprintf('Running GLM for %s (Sensor space)', id);
    tayeeg_1stlevel_stats(id, options,'sensor');
end

% ERP analysis
if doErpAnalysis
    tayeeg_erp(id, options)
end

% Compute Beta Waveform
if doComputeBetaWave
    fprintf('Running Beta Wave computation for %s', id);
    tayeeg_contrast(id, options);
end

% Extract sources based on fMRI priors
if doRunSources
    tmpType = options.eeg.type;
    options.eeg.type = 'source';
    fprintf('Extracting source waveforms for %s', id);
    tayeeg_source(id, options, options.eeg.source.doVisualize); % tayeeg_source; %tayeeg_timeFrequency/dmpad_tf
    options.eeg.type = tmpType;
end

% Image conversion and GLM in source space
if doRunStatsSource
    fprintf('Running GLM for %s (Source space)', id);
    tayeeg_1stlevel_stats(id, options,'source');
end

% Extract sources based on fMRI priors
if doRunTFSources
    tmpType = options.eeg.type;
    options.eeg.type = 'tfsource';
    fprintf('Extracting time-frequency based on source waveforms for %s', id);
    tayeeg_tfsource(id, options);
    options.eeg.type = tmpType;
end

% Image conversion and GLM in source space
if doRunStatsTFSource
    fprintf('Running GLM for %s (TF in Source space)', id);
    tayeeg_1stlevel_stats(id, options,'tfsource');
end

end

