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
            categoryNames = {'\epsilon_2','\epsilon_3'};
            categoryLabels={'epsi2','epsi3'};
            design      = getfield(load(details.model.design), 'design');
            factors = fieldnames(design);
            for i = 1:numel(factors)
                condlist    = mmn_lowhighPE_conditions(design.(factors{i}), ...
                    categoryNames{i}, options);
                savefig([details.eeg.erp.erpfig categoryLabels{i} '.fig']);
                D = spm_eeg_load(details.eeg.prepfile);
                % redefine trials for averaging
                Drefined = tnueeg_redefine_conditions(D, condlist);
                Dsaved = copy(Drefined, fullfile(details.eeg.erp.redeffile, [categoryLabels{i} '.mat']));
                disp(['Redefined conditions for subject ' id]);
                
                %-- averaging ---------------------------------------------------------------------------------%
                Daveraged = tnueeg_average(Dsaved, options);
                Daveraged = copy(Daveraged, fullfile(details.eeg.erp.avgfile, [categoryLabels{i} '.mat']));
                disp(['Averaged over trials for subject ' id]);
                
                % in case of robust filtering: re-apply the low-pass filter
                switch options.eeg.erp.averaging
                    case 'robust'
                        % make sure we don't delete ERP files during filtering
                        options.eeg.preproc.keep = 1;
                        Dfiltered = tnueeg_filter(Daveraged, 'low', options);
                        disp(['Re-applied the low-pass filter for subject ' id]);
                    case 'simple'
                        % do nothing
                end
                Dfinal = copy(Dfiltered, fullfile(details.eeg.erp.erpfile, [categoryLabels{i} '.mat']));
                %-- ERP plot ----------------------------------------------------------------------------------%
                chanlabel = options.eeg.erp.electrode;
                switch options.eeg.erp.type
                    case {'epsilon'}
                        triallist = {'low', ['Lowest ' options.eeg.erp.percentPe ' %'], [0 0 1]; ...
                            'high', ['Highest ' options.eeg.erp.percentPe ' %'], [1 0 0];...
                            'other', 'Middle', [0 1 0]};
                end
                if doPlot
                    h = tnueeg_plot_subject_ERPs(Dfinal, chanlabel, triallist);
                    h.Children(2).Title.String = ['Subject ' id ': ' options.eeg.erp.type ' of ' categoryLabels{i} ' ERPs'];
                    savefig(h, fullfile(details.eeg.erp.root, [details.eeg.subproname categoryLabels{i} '.fig']));
                    fprintf('\nSaved an ERP plot for subject %s\n\n', id);
                end
                % preparation for computing the difference wave
                %-- difference waves --------------------------------------------------------------------------%
                % determine condition order within the D object
                idxLow = indtrial(Drefined, 'low');
                idxHigh = indtrial(Drefined, 'high');
                
                % set weights such that we substract standard trials from deviant
                % trials, give the new condition a name
                weights = zeros(1, ntrials(Drefined));
                weights(idxHigh) = 1;
                weights(idxLow) = -1;
                condlabel = {'mmn'};
                
                % sanity check for logfile
                disp('Difference wave will be computed using:');
                disp(weights);
                disp('as weights on these conditions:');
                disp(conditions(Drefined));
                
                % compute the actual contrast
                Ddiff = tnueeg_contrast_over_epochs(Drefined, weights, condlabel, options);
                copy(Ddiff, fullfile(details.eeg.erp.difffile,[categoryLabels{i} '.mat']));
                disp(['Computed the difference wave for subject ' id]);
            end
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
            copy(D, fullfile(details.eeg.erp.difffile, 'standard_mmn.mat'));
            disp(['Computed the difference wave for subject ' id]);
    end
end

close all
cd(options.root);

diary OFF
end
