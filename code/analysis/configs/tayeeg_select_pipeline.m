function pipeline = tayeeg_select_pipeline
% cell array with a subset of the following:
% general (for all subgroups below)
%     'cleanup'
% preproc:
%     'correct_eyeblinks'
% stats (sensor):
%     'create_behav_regressors'
%     'ignore_reject_trials'
%     'run_stats_sensor'
%     'compute_beta_wave'
% stats (source):
%     'extract_sources'
%     'run_stats_source'
%
%  NOTE: 'cleanup' only cleans up files (deletes them) that will be
%  recreated by the other specified pipeline steps in the array
%  See also dmpad_analyze_subject

pipeline.executeStepsPerSubject = {
    'correct_eyeblinks'
    'create_behav_regressors'
    'run_stats_sensor'
    'compute_beta_wave'
    'run_erp_analysis'
    'extract_sources'
    'run_stats_source'
    'extract_tf'
    'run_stats_tfsource'
    };

% Other specialised options not executed yet are:
%     'extract_sources'
%     'run_stats_source'
%     'extract_tf'
%     'run_stats_tfsource'

%% Group Level analysis pipeline options
% steps that are performed for all subjects at once, include any of the
% following in a cell array:
%
%       'run_stats_2ndlevel_sensor'
%       'run_stats_2ndlevel_source'
%       'create_figure_eeg_temporal_hierarchy_blobs'
%       'create_figure_eeg_temporal_hierarchy_timeseries'
%
pipeline.executeStepsGroup = {''
    }; % second level analysis not executed at the moment
end