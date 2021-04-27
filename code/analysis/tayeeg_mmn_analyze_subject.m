function compi_mmn_analyze_subject( id, options )
%MNKET_ANALYZE_SUBJECT Performs all analysis steps for one subject of the MNKET study (up until
%first level modelbased statistics)
%   IN:     id  - subject identifier string, e.g. '0001'
%   OUT:    --

if nargin < 2
    options = compi_ioio_options;
end

fprintf('\n\n --------- Working on: %s ---------\n\n', id);


%% Strategy 1: Reject eyeblinks
options.eeg.preproc.eyeblinktreatment = 'reject';
fprintf('\n\n --- Subject analysis using: %s method ---\n\n', upper(options.eeg.preproc.eyeblinktreatment));
% Pre-processing
compi_mmn_preprocessing_reject_eyeblinks(id, options);

% ERP analysis (up until conversion): roving definition
options.eeg.conversion.mode = 'diffWaves';
options.eeg.erp.type = 'roving';
dprst_erp(id, options);
dprst_conversion(id, options);

% ERP analysis (up until conversion): phases_roving definition
options.eeg.conversion.mode = 'ERPs';
options.eeg.erp.type = 'phases_roving';
dprst_erp(id, options);
dprst_conversion(id, options);

% ERP analysis (up until conversion): phases_oddball definition
options.eeg.conversion.mode = 'ERPs';
options.eeg.erp.type = 'phases_oddball';
dprst_erp(id, options);
dprst_conversion(id, options);

% modelbased analysis (up until 1st level)
options.eeg.conversion.mode = 'modelbased';
dprst_conversion(id, options);
options.eeg.stats.mode = 'modelbased';
options.eeg.stats.design = 'epsilon';

options.eeg.stats.priors = 'omega35';
dprst_1stlevel(id, options);
options.eeg.stats.priors = 'peIncrease';
dprst_1stlevel(id, options);
options.eeg.stats.priors = 'volTrace';
dprst_1stlevel(id, options);

%% Strategy 2: Correct eyeblinks
options.eeg.preproc.eyeblinktreatment = 'ssp';
fprintf('\n\n --- Subject analysis using: %s method ---\n\n', upper(options.eeg.preproc.eyeblinktreatment));
% Pre-processing
dprst_preprocessing_ssp(id, options);

% ERP analysis (up until conversion): roving definition
options.eeg.erp.type = 'roving';
options.eeg.conversion.mode = 'diffWaves';
dprst_erp(id, options);
dprst_conversion(id, options);

% ERP analysis (up until conversion): phases_roving definition
options.eeg.conversion.mode = 'ERPs';
options.eeg.erp.type = 'phases_roving';
dprst_erp(id, options);
dprst_conversion(id, options);

% ERP analysis (up until conversion): phases_oddball definition
options.eeg.conversion.mode = 'ERPs';
options.eeg.erp.type = 'phases_oddball';
dprst_erp(id, options);
dprst_conversion(id, options);

% modelbased analysis (up until 1st level)
options.eeg.conversion.mode = 'modelbased';
dprst_conversion(id, options);
options.eeg.stats.mode = 'modelbased';
options.eeg.stats.design = 'epsilon';

options.eeg.stats.priors = 'omega35';
dprst_1stlevel(id, options);
options.eeg.stats.priors = 'peIncrease';
dprst_1stlevel(id, options);
options.eeg.stats.priors = 'volTrace';
dprst_1stlevel(id, options);

end

