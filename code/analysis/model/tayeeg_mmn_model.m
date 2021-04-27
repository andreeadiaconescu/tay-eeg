function tayeeg_mmn_model(id, options)
% MMN_MODEL Simulates the beliefs of one subject from the mnCHR study and saves the trajectories
%for modelbased analysis of EEG data.
%   IN:     id          - subject identifier, e.g '001'
%           optionally:
%           options     - the struct that holds all analysis options
%   OUT:    design      - the design file which holds the modelbased regressors for this subject

% general analysis options
if nargin < 2
    options = tayeeg_analysis_options;
end

% paths and files
details = tayeeg_subjects(id, options);

% record what we're doing
diary(details.eeg.logfile);
tnueeg_display_analysis_step_header('model', 'mmn', id, options.model);

% check destination folder
if ~exist(details.eeg.modelroot, 'dir')
    mkdir(details.eeg.modelroot);
end
cd(details.eeg.modelroot);

try
    % check for previous preprocessing
    load(details.model.design);
    disp(['Subject ' id ' has been modeled before.']);
    if options.model.overwrite
        clear design;
        disp('Overwriting...');
        error('Continue to modeling step.');
    else
        disp('Nothing is being done.');
    end
catch
    disp(['Modeling subject ' id ' ...']);
    
    %-- simulate beliefs --------------------------------------------------------------------------%
    
    D = spm_eeg_load(details.eeg.prepfile);
    
    % code binary trials
    trial_types = mmn_binary_trialDef(D, details);
    
    [lowPETrialsAll, highPETrialsAll,trajectoryEpsilon2,trajectoryEpsilon3,...
        predictionProb,precision,informationalUncertainty,volatilityUncertainty,predictionVol,delta1, delta2, delta3] ...
        = mmn_volatilityMMN_extract_beliefs_eHGF(trial_types, details);
    
    switch options.eeg.stats.design
        case 'epsilon'
            design.epsilon2 = trajectoryEpsilon2;
            design.epsilon3 = trajectoryEpsilon3;
        case 'PEs'
            design.delta1   = delta1;
            design.delta2   = delta2;
            design.delta3   = delta3;
        case 'posteriors'
            design.mu2      = predictionProb;
            design.mu3      = predictionVol;
        case 'precisions'
            design.pi1      = precision;
            design.pi2      = 1./informationalUncertainty;
            design.pi3      = 1./volatilityUncertainty;
    end
    
    erp.trials.lowPE        = lowPETrialsAll;
    erp.trials.hiPE         = highPETrialsAll;
    
    save(details.model.design, 'design');
    save(details.erp.design, 'erp');
    
    fprintf('\nDesign file has been created.\n\n');
    
    fprintf('\nModeling done: subject %s', id);
    disp('   ');
    disp('*----------------------------------------------------*');
    disp('   ');
    
end

cd(options.root);
close all

diary OFF
end
