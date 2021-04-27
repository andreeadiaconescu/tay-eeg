function finaldesign = mmn_correct_regressors_for_EEG_artefacts( details, options )
% MMN_CORRECT_REGRESSORS_FOR_EEG_ARTEFACTS 
%   IN:     details     - the struct that holds all subject-specific paths and filenames     
%   OUT:    finaldesign - the corrected design struct holding the vectors to be used in the regression of the preprocessed EEG data

initialdesign   = getfield(load(details.model.design), 'design');
trialStats = getfield(load(details.eeg.goodtrials), 'trialStats');

design = initialdesign;
regressors = fieldnames(design);

% determine number of trials before any removal
nTrialsInit = numel(design.(char(regressors(1))));
disp(['Initial regressors contain ' num2str(nTrialsInit) ' trials.']);

%-- Bad trials due to Artefacts ---------------------------------------------------%
artefacttrials = trialStats.idxArtefacts;

for iReg = 1: numel(regressors)
    design.(regressors{iReg})(artefacttrials) = [];
end

% determine number of trials after removal and save new design
nTrialsArtCorr = numel(design.(char(regressors(1))));
disp(['Regressors corrected for artefacts contain ' num2str(nTrialsArtCorr) ' trials.']);
save(details.model.subjectDesign, 'design');

%-- Compare numbers ---------------------------------------------------%
nInitial = length(initialdesign.(regressors{1}));
nFinal = length(design.(regressors{1}));
nArtefacts = length(artefacttrials);
nEyeblinktrials = numel(trialStats.idxEyeartefacts.tone);

if nInitial+nEyeblinktrials ~= 1800
    warning('Design does not hold 1800 trials - check first trials');
end
if nFinal ~= trialStats.nTrialsFinal.all
    error('Final number of trials does not match the preprocessing output.');
end
if nArtefacts ~= trialStats.numArtefacts
    error('Number of additional artefacts does not match the preprocessing output.');
end

switch options.eeg.preproc.eyeCorrMethod
    case 'reject'
        nEyeblinks = numel(trialStats.idxEyeartefacts.tone);
        if nEyeblinks ~= trialStats.numEyeartefacts.all
            error('Number of eye blink artefacts does not match the preprocessing output.');
        end
        if nArtefacts ~= ((nInitial+nEyeblinktrials - nEyeblinks) - nFinal)
            error('Number rejected trials due to eyeblinks and artefacts are not consistent.');
        end
end

finaldesign = design;

end

