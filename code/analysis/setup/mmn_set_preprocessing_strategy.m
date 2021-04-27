function preprocessing = mmn_set_preprocessing_strategy(resultroot, ...
    preprocStrategyValueArray)

if nargin < 2 || isempty(preprocStrategyValueArray)
    preprocStrategyValueArray = [1 3 2 2 1 2];
end

preprocessing             = [];

% Important: please append new strategy components to the END of the list
% and new strategy options to the END of the array

preprocessing.eyeDetectionThreshold           = {'subject-specific', 'default'};
preprocessing.eyeCorrectionMethod             = {'ssp', 'berg', 'reject','pssp'};
preprocessing.eyeCorrectionComponentsNumber   = {'3', '1'};
preprocessing.downsample                      = {'no', 'yes'};
preprocessing.lowpass                         = {'45', '35'};
preprocessing.digitization                    = {'subject-specific', 'template'};

% Preprocessing strategies
preprocessing.selectedStrategy.valueArray = preprocStrategyValueArray;
preprocessing.selectedStrategy.prefix     = ['preproc_strategy' ...
    sprintf('_%d',preprocessing.selectedStrategy.valueArray)];
preprocessing.root                         = fullfile(resultroot, preprocessing.selectedStrategy.prefix);

end