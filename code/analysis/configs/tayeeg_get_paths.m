function options = tayeeg_get_paths()

[~, uid] = unix('whoami');
switch uid(1: end-1)
    case 'drea'
        root             = '/Users/drea/Documents/Collaborations/TAY';
        coderoot         = '/Users/drea/Documents/Collaborations/TAY/kcni-eeg-lab/studies/tay-eeg/code/analysis';
        configroot       = fullfile(coderoot,'configs');
        dataroot         = fullfile(root,'eeg','raw');
        behavroot        = fullfile(root,'eeg','behav');
        resultroot       = fullfile(root,'eeg','results');
    otherwise
        error(['Undefined user. Please specify a user in tayeeg_get_paths ' ...
            'and provide the path to the data']);
        
end

% create folders, if non existent, and don't give warnings, if they do
% (won't be overwritten!)
[~,~] = mkdir(resultroot);

%% Paths
options.root             = root;
options.dataroot         = dataroot;
options.resultroot       = resultroot;
options.behavroot        = behavroot;
options.qualityroot      = fullfile(options.root, 'data_quality');

options.configroot       = configroot;
options.coderoot         = coderoot;
options.code             = fullfile(fileparts(mfilename('fullpath')));
options.eeg.batchesroot  = fullfile(options.coderoot, 'eeg-functions','dmpad-toolbox','EEG', 'CustomSPMPreprocAnalysis', 'batches');
end

