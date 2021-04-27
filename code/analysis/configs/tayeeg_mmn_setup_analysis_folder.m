function tayeeg_mmn_setup_analysis_folder(options)
%MMN_SETUP_ANALYSIS_FOLDER Creates project directory tree and collects data for the COMPI project

if nargin < 1
    options = tayeeg_analysis_options;
end

%-- create folder tree ----------------------------------------------------------------------------%
if ~exist(options.eeg.preproc.grouproot, 'dir')
    mkdir(options.eeg.preproc.grouproot);
end

subjectsroot = fullfile(options.eeg.preproc.grouproot, 'subjects');
if ~exist(subjectsroot,'dir')
    mkdir(fullfile(options.eeg.preproc.grouproot, 'subjects'));
end

cd(subjectsroot);
diary('analysis_setup.log');

for subfolder = {'erp', 'stats_erp', 'stats_model'}
    if ~exist(fullfile(options.eeg.preproc.grouproot, char(subfolder)), 'dir')
        mkdir(fullfile(options.eeg.preproc.grouproot, char(subfolder)));
    end
end
disp(['Created analysis folder tree at ' subjectsroot]);

end

