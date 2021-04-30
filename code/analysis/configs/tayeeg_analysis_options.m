function options = tayeeg_analysis_options(preprocStrategyValueArray)

if nargin < 1
    preprocStrategyValueArray = [1 3 2 2 1 2];
end

%% Load Paths-----------------------------------------------------------%
options = tayeeg_get_paths;

%% EEG analysis pipeline-----------------------------------------------------------%
pipeline         = tayeeg_select_pipeline;
options.eeg.pipe = pipeline;

%% Configuration Options -----------------------------------------------------------%
options.eeg.channels    = fullfile(options.configroot,  'tayeeg_64ch.sfp');
options.eeg.part        = 'pilot';
options.eeg.type        = 'sensor';

%% Model Space -----------------------------------------------------------%
options.model.perceptualModel  = 'tapas_ehgf_binary_config';
options.model.forwardModel     = 'tapas_bayes_optimal_binary_config';
options.model.optimization     = 'tapas_quasinewton_optim_config';
options.model.overwrite        = 1; % whether to overwrite any previous model

%% Preprocessing Fixed Options -----------------------------------------------------------%
% standard preprocessing options; recommendation is not to alter these steps
fixed_preprocessing                         = mmn_fixed_preprocessing;
options.eeg.preproc                         = fixed_preprocessing;
options.eeg.preproc.montage.veog            = [68 72];
options.eeg.preproc.montage.heog            = [67 71];

%% Preprocessing Changeable Options -----------------------------------------------------------%
% set options for most common preproc parameters to form a preproc strategy
% (pipeline), separated in its own preproc directory
preprocessing = mmn_set_preprocessing_strategy(options.resultroot, preprocStrategyValueArray);
disp(preprocessing.selectedStrategy.valueArray);
options.eeg.preprocStrategyValueArray       = preprocStrategyValueArray;
options.eeg.preproc.grouproot               = preprocessing.root;
options.eeg.preproc.eyeDetectionThreshold   = ...
    preprocessing.eyeDetectionThreshold{preprocessing.selectedStrategy.valueArray(1)};% other option: default (i.e., set to 3 for all subjects)
options.eeg.preproc.eyeCorrMethod           = ...
    preprocessing.eyeCorrectionMethod{preprocessing.selectedStrategy.valueArray(2)};% other option; 'SSP'
options.eeg.preproc.nComponentsforRejection = ...
    str2num(preprocessing.eyeCorrectionComponentsNumber{preprocessing.selectedStrategy.valueArray(3)});
options.eeg.preproc.downsample              = preprocessing.downsample{preprocessing.selectedStrategy.valueArray(4)}; % yes or no
options.eeg.preproc.lowpassfreq             = str2num(preprocessing.lowpass{preprocessing.selectedStrategy.valueArray(5)});
options.eeg.preproc.digitization            = ...
    preprocessing.digitization{preprocessing.selectedStrategy.valueArray(6)};

% steps you can turn on/off for saving/rewrite purposes
options.eeg.preproc.overwrite               = 1; % whether to overwrite any prev. prepr
options.eeg.preproc.keep                    = 1; % whether to keep intermediate data
options.eeg.preproc.mrifile                 = 'template';

%% ERP analysis -----------------------------------------------------------%
options.eeg.erp.type        = 'epsilon';
erp_specifications          = mmn_select_erp_analysis(options);
options.eeg.erp             = erp_specifications;

%% First and Second-Level Analysis ---------------------------------------%
options.eeg.stats.design                   = 'epsilon';    % 'posterior', 'PEs', 'precisions'
stats_specifications                       = mmn_select_stats(options);
options.eeg.stats                          = stats_specifications;
options.eeg.stats.firstLevelAnalysisWindow = [100 450];
options.eeg.stats.firstLevelDesign         = options.eeg.stats.design;

%% Conversion2images -----------------------------------------------------%
conversion_specifications               = mmn_select_conversion;
options.eeg.conversion                  = conversion_specifications;
options.eeg.conversion.mode             = 'modelbased'; %'ERPs', 'modelbased',
options.eeg.conversion.convTimeWindow   = options.eeg.stats.firstLevelAnalysisWindow;
%% EEG Source Analysis--------------------------------------------------------%
source_modelling_specifications   = mmn_select_source_recon(options);
options.eeg.source                = source_modelling_specifications;
options.eeg.source.VOI            = fullfile(options.configroot, 'mmn_voi_msp.mat');

%% EEG Second level Analysis-----------------------------------------------------------------%
stats_secondlevel                  = mmn_select_stats_group(options);
options.eeg.stats.secondlevel      = stats_secondlevel;
options.eeg.stats.secondlevel.type = 'classical';
[~,~]                              = mkdir(options.eeg.stats.secondlevel.secondlevelDir.classical); % creates also 2ndlevel dir with it

%% EEG Logging options --------------------------------------------------------%
options.eeg.log.errorfile       = fullfile(options.eeg.preproc.grouproot, 'errorLog.mat');
options.eeg.log.diarygroupfile  = fullfile(options.eeg.preproc.grouproot, 'diary_AllSubjects.log');
options.eeg.log.optionssavefile = fullfile(options.eeg.preproc.grouproot, 'optionsAsExecuted.mat');
save(options.eeg.log.optionssavefile, 'options');

%% EEG Quality Control
options.eeg.quality.trialstatstab = fullfile(options.qualityroot, 'trialStatsTable.mat');
options.eeg.quality.trialstatsfig = fullfile(options.qualityroot, 'trialStatsTable.fig');
options.eeg.quality.trialstatsfig = fullfile(options.qualityroot, 'trialStatsTable.png');

%% Subject IDs included in this analysis
options = subjects_group_details(options);
%% Subjects with specific name rules
    function detailsOut = subjects_group_details(detailsIn)
        detailsOut = detailsIn;
        
        switch lower(detailsOut.eeg.part)
            case 'pilot'
                detailsOut.subjectIDs  = ...
                    {'0001','0002','0004','0012','0013','0014'}; % '0003' and '0006' are very noisy
            case 'tay'
                detailsOut.subjectIDs  = ...
                    {'0001','0002','0003','0006','0005','0007',...
                    '0008','0009','0010','0011','0012','0013','0014'};
        end
    end
end
