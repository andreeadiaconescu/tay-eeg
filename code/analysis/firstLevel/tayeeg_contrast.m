function D = tayeeg_contrast(id, options)
% Compute Beta Waveform contrasts
%
% IN
%   id          subject id string, only number (e.g. '153')
%   options     general analysis options%
%               options = dmpad_set_analysis_options;
% 
% OUT
%   D           Data structure of SPM EEG Analysis

% paths and files
details = tayeeg_subjects(id, options); % subject-specific information

try
    D = spm_eeg_load(details.eeg.prepfile);
catch
    D = tayeeg_mmn_preprocessing_reject_eyeblinks(id, options);
end

design = getfield(load(details.model.subjectDesign), 'design');

badtrials = D.badtrials;

X = struct2cell(design);
X = cat(2, X{:});
X = detrend(X, 'constant');
X = [ones(size(X, 1), 1) X];

% fill bad trials with 0 in design matrix
X2 = zeros(D.ntrials, size(X,2));
X2(setdiff(1:D.ntrials, badtrials),:) = X; 

S = [];
S.D = D;
S.c = pinv(X2);
S.label = [{'mean'}; fieldnames(design)];
S.weighted = 0;
S.prefix = details.eeg.firstLevel.sensor.prefixBetaWave;
D = spm_eeg_contrast(S);