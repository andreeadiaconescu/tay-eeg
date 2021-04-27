function mmn_report_step_posthoc( stepStr, options )
% MMN_REPORT_STEP_POSTHOC Loops through all subjects and creates quality check plots and variables 
%that have not been saved automatically during modeling, preprocessing, or first-level statistics.
%   IN:     stepStr - step identifier string, e.g. 'coregistration'
%           options - the struct that holds all analysis options
%   OUT:    -

if nargin < 1
    options = tayeeg_analysis_options;
end

if ~exist(options.qualityroot, 'dir')
    mkdir(options.qualityroot);
end

for idCell = options.subjectIDs
    id = char(idCell);
    details = tayeeg_subjects( id, options );
    switch lower(stepStr)
        case {'ebcorr', 'ebcorrection', 'eyeblinkcorrection'}
            tnueeg_check_eb_correction_on_average(details.eeg.ebfile, details.eeg.prepfile, ...
                details.ebcorrectfig, options);
        case {'coreg', 'coregistration'}
            tnueeg_check_coregistration(details.prepfile, details.coregmeshfig, ...
                details.coregdatafig); 
        case {'reg', 'regressors'}
            tnueeg_check_regressors_before_after(details.design, details.eegdesign, ...
                details.regressorplots);
        case {'mask', 'firstlevelmask'}
            tnueeg_check_mask_image(details.statroot, details.firstlevelmaskfig); 
    end
end

end
