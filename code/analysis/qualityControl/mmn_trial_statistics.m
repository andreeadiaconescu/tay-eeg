function [nTrialsInitial,nEyeblinks,nArtefacts,...
    nBadChannels,nGoodTrialsTone,nEyeartefactsTone] = mmn_trial_statistics( id, options )
% MMN_TRIAL_STATISTICS Creates a table summarizing the number of artefactual, excluded and
%remaining trials per subject in the TAYEEG study and creates an overview plot.
%   IN:     optionally:
%           options         - the struct that contains all analysis options
%   OUT:    tableArtefacts  - overview table size 10 x nSubjects

if nargin < 1
    options = tayeeg_analysis_options;
end

if ~exist(options.qualityroot, 'dir')
    mkdir(options.qualityroot);
end


details = tayeeg_subjects( id, options );
load(details.eeg.goodtrials);
D               = spm_eeg_load(details.eeg.prepfile);
nInitial        = length(D.events);
nEyeblinktrials = numel(trialStats.idxEyeartefacts.tone);

nTrialsInitial   = nInitial + nEyeblinktrials;
nEyeblinks       = trialStats.numEyeblinks;
nArtefacts       = trialStats.numArtefacts;
nBadChannels     = trialStats.badChannels.numBadChannels;
nGoodTrialsTone  = trialStats.nTrialsFinal.tone;

switch options.eeg.preproc.eyeCorrMethod
    case 'reject'
        nEyeartefactsTone = trialStats.numEyeartefacts.tone;
end
end

