function [ trialdef ] = tayeeg_mmn_trial_definition( options, details )
%TAY_TRIAL_DEFINTION Trial definition for auditory MMN with volatility EEG data sets
%   IN:     paths       - struct with general paths and files
%           options     - struct with analysis options
%   OUT:    trialdef    - struct with labels, types and values of triggers

switch options.eeg.preproc.trialdef
    case 'tone'
        trialdef.labels = {'tone', 'tone'};
        trialdef.types  = repmat({'STATUS'}, [1 2]);
        trialdef.values = [1 2];               
end

save(details.eeg.trialdefinition, 'trialdef');

end

