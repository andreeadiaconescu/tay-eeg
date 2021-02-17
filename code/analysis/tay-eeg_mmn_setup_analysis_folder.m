function compi_eeg_setup_analysis_folder(options)
%MMN_SETUP_ANALYSIS_FOLDER Creates project directory tree and collects data for the COMPI project

if nargin < 1
    options = compi_ioio_options;
end

%-- create folder tree ----------------------------------------------------------------------------%
if ~exist(options.eeg.resultroot, 'dir')
    mkdir(options.eeg.resultroot);
end


cd(options.eeg.resultroot);
diary('analysis_setup.log');

for subfolder = {'config', 'subjects', 'tones', 'erp', 'stats_erp', 'stats_model'}
    if ~exist(fullfile(options.eeg.resultroot, char(subfolder)), 'dir')
        mkdir(fullfile(options.eeg.resultroot, char(subfolder)));
    end
end
disp(['Created analysis folder tree at ' options.eeg.resultroot]);

end

