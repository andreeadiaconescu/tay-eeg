function D = tayeeg_erp(id, options, doPlot)
% TAYEEG_ERP Computes ERPs for one subject from the TAY study.
%   IN:     id                  - subject identifier, e.g '0001'
%           doPlot (optional)   - 1 for plotting subject's ERP and saving a
%                               figure, 0 otherwise
%   OUT:    D                   - preprocessed data set

% plotting yes or no
if nargin < 3
    doPlot = 1;
end

% general analysis options
if nargin < 2
    options = tayeeg_analysis_options;
end

% paths and files
details = tayeeg_subjects(id, options);

% prepare spm
spm('defaults', 'EEG');

% record what we're doing
diary(details.eeg.logfile);
mmn_display_analysis_step_header('ERP', id, options.eeg.erp);

try
    % check for previous ERP analyses
    D = spm_eeg_load(details.eeg.erp.difffile);
    disp(['Subject ' id ' has been averaged before.']);
    if options.eeg.preproc.overwrite
        clear D;
        disp('Overwriting...');
        error('Continue to ERP script');
    else
        disp('Nothing is being done.');
    end
catch
    fprintf('\nAveraging subject %s ...\n\n', id);
    
    %-- preparation -------------------------------------------------------------------------------%
    % check destination folder
    if ~exist(details.eeg.erp.root, 'dir')
        mkdir(details.eeg.erp.root);
    end
    cd(details.eeg.erp.root);
    
    % work on final preprocessed file
    switch options.eeg.erp.type
        case {'epsilon', 'PEs','posteriors','precisions'}
            D = spm_eeg_load(details.eeg.prepfile);
    end
    
    %-- redefinition ------------------------------------------------------------------------------%
    % get new condition names
    switch options.eeg.erp.type
        case 'epsilon'
            design      = getfield(load(details.model.design), 'design');
            condlist    = mmn_lowhighPE_conditions(design.epsilon2, ...
                '\epsilon_2', options);
            savefig([details.eeg.erp.erpfig '_epsi2.fig']);
        case 'lowhighEpsi3'
            load(details.design);
            design      = getfield(load(details.model.design), 'design');
            condlist    = mmn_lowhighPE_conditions(design.epsilon3, ...
                '\epsilon_3', options);
            savefig([details.eeg.erp.erpfig '_epsi3.fig']);
    end
    
    % redefine trials for averaging
    D = tnueeg_redefine_conditions(D, condlist);
    D = copy(D, details.eeg.erp.redeffile);
    disp(['Redefined conditions for subject ' id]);
    
    %-- averaging ---------------------------------------------------------------------------------%
    D = tnueeg_average(D, options);
    D = copy(D, details.eeg.erp.avgfile);
    disp(['Averaged over trials for subject ' id]);
    
    % in case of robust filtering: re-apply the low-pass filter
    switch options.eeg.erp.averaging
        case 'robust'
            % make sure we don't delete ERP files during filtering
            options.eeg.preproc.keep = 1;
            D = tnueeg_filter(D, 'low', options);
            disp(['Re-applied the low-pass filter for subject ' id]);
        case 'simple'
            % do nothing
    end
    D = copy(D, details.eeg.erp.erpfile);
    
    %-- ERP plot ----------------------------------------------------------------------------------%
    chanlabel = options.eeg.erp.electrode;
    switch options.eeg.erp.type
        case {'epsilon'}
            triallist = {'low', 'Lowest 15 %', [0 0 1]; ...
                'high', 'Highest 15 %', [1 0 0]};
    end
    if doPlot
        h = tnueeg_plot_subject_ERPs(D, chanlabel, triallist);
        h.Children(2).Title.String = ['Subject ' id ': ' options.eeg.erp.type ' ERPs'];
        savefig(h, details.eeg.erp.erpfig);
        fprintf('\nSaved an ERP plot for subject %s\n\n', id);
    end
    
    %-- difference waves --------------------------------------------------------------------------%
    switch options.eeg.erp.type
        case {'standard'}
            % preparation for computing the difference wave
            % determine condition order within the D object
            idxDeviants = indtrial(D, 'deviant');
            idxStandards = indtrial(D, 'standard');
            
            % set weights such that we substract standard trials from deviant
            % trials, give the new condition a name
            weights = zeros(1, ntrials(D));
            weights(idxDeviants) = 1;
            weights(idxStandards) = -1;
            condlabel = {'mmn'};
            
            % sanity check for logfile
            disp('Difference wave will be computed using:');
            disp(weights);
            disp('as weights on these conditions:');
            disp(conditions(D));
            
            % compute the actual contrast
            D = tnueeg_contrast_over_epochs(D, weights, condlabel, options);
            copy(D, details.difffile);
            disp(['Computed the difference wave for subject ' id]);
        case {'epsilon'}
            % preparation for computing the difference wave
            % determine condition order within the D object
            idxLow = indtrial(D, 'low');
            idxHigh = indtrial(D, 'high');
            
            % set weights such that we substract standard trials from deviant
            % trials, give the new condition a name
            weights = zeros(1, ntrials(D));
            weights(idxHigh) = 1;
            weights(idxLow) = -1;
            condlabel = {'mmn'};
            
            % sanity check for logfile
            disp('Difference wave will be computed using:');
            disp(weights);
            disp('as weights on these conditions:');
            disp(conditions(D));
            
            % compute the actual contrast
            D = tnueeg_contrast_over_epochs(D, weights, condlabel, options);
            copy(D, details.eeg.erp.difffile);
            disp(['Computed the difference wave for subject ' id]);
    end
end

close all
cd(options.root);

diary OFF
end
