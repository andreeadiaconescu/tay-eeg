function loop_tayeeg_quality_check( options )
%LOOP_TAYEEG_QUALITY_CHECK Loops through conditions and performs all
%quality checks after subject analysis
%   IN:     options     - the struct that holds all analysis options
%   OUT:    -

% perform quality check for subject analysis
if nargin < 1
    options = tayeeg_analysis_options;
end

mmn_trialstats_check( options );
mmn_summarize_step('eyeblinkdetection', options);

switch lower(options.eeg.preproc.eyeCorrMethod)
    case {'ssp', 'berg','pssp'}
        mmn_summarize_step('eyeblinkconfounds', options);
        mmn_group_check_eyeblink_correction(options);
        mmn_summarize_step('eyeblinkcorrection', options);
    case 'reject'
        mmn_summarize_step('eyeblinkoverlap', options);
end

mmn_group_check_coregistration(options);
mmn_summarize_step('coregistration', options);

mmn_group_check_firstlevelmask(options);
mmn_summarize_step('firstlevelmask', options);

end

function mmn_group_check_eyeblink_correction(options)
for iSub = 1: numel(options.subjectIDs)
    id = char(options.subjectIDs{iSub});
    mmn_plot_effects_of_eyeblink_correction_on_average_eyeblink(id, options);
end
end

function mmn_group_check_coregistration(options)
for iSub = 1: numel(options.subjectIDs)
    id = char(options.subjectIDs{iSub});
    mmn_check_coregistration(id, options);
end
end

function mmn_group_check_firstlevelmask(options)
for iSub = 1: numel(options.subjectIDs)
    id = char(options.subjectIDs{iSub});  
    mmn_check_firstlevelmask(id, options);
end
end


