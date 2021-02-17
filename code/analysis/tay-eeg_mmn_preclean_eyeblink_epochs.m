function [ D ] = compi_mmn_preclean_eyeblink_epochs( D, details, options ) 
%MNKET_PRECLEAN_EYEBLINK_EPOCHS  Precleans the EB epoched data set to improve confound estimation
%   This function performs several precleaning steps if selected:
%   - a low-pass filter (cutoff frequency options.preproc.preclean.lowPassFilterFreq to remove any
%   high frequency noise on top of the low-frequency eye blinks
%   - a simple artefact detection routine (channel thresholding) in SPM, rejecting trials with 
%   amplitude exceeding options.preproc.preclean.badtrialthresh and channels with a proportion of 
%   more than options.preproc.preclean.badchanthresh of bad trials
%   IN:     D       - epoched EEG data set 
%           details - the struct that holds all subject-specific options and paths
%           options - the struct that holds all analysis options 
%   OUT:    D       - epoched EEG data set with flags for bad trials 

if options.preproc.preclean.doFilter
    filterOptions.preproc.lowpassfreq   = options.preproc.preclean.lowPassFilterFreq;
    filterOptions.preproc.keep          = options.preproc.keep;
    
    D = tnueeg_filter(D, 'low', filterOptions); 
end

if options.preproc.preclean.doBadChannels
    badChannels = details.preclean.badchannels;
    
    D = badchannels(D, badChannels, ones(1, numel(badChannels)));
end

if options.preproc.preclean.doRejection
    rejectOptions.preproc.badtrialthresh    = options.preproc.preclean.badtrialthresh;
    rejectOptions.preproc.badchanthresh     = options.preproc.preclean.badchanthresh;
    rejectOptions.preproc.artefactPrefix    = options.preproc.preclean.rejectPrefix;
    rejectOptions.preproc.keep              = options.preproc.keep;
    
    D = tnueeg_reject_remaining_artefacts(D, rejectOptions);
end

end