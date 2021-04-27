function [fh1, fh2] = mmn_plot_effects_of_eyeblink_correction_on_average_eyeblink( id, options )
% MMN_PLOT_EFFECTS_OF_EYEBLINK_CORRECTION_ON_AVERAGE_EYEBLINK Plots the average eyeblink epoch
%before and after EB correction method was applied. Also creates the averaged and corrected EB epoch
%data sets if they haven't been created before.
%   IN:     id          - subject identifier string, e.g. '001'
%           options     - the struct that holds all analysis options
%   OUT:    -

details = tayeeg_subjects(id, options);
if ~exist(details.eeg.quality.root, 'dir')
    mkdir(details.eeg.quality.root);
end
trials = 1;

[Dbefore, Dafter] = dmpad_get_average_EB_responses(details, options);

channels = {'Fz', 'Cz', 'FPz', 'HEOG'};
fh1 = mmn_diagnostics_effect_of_EB_corr(Dbefore, Dafter, channels, trials);

channels = {'Oz', 'Pz', 'AFz', 'HEOG'};
fh2 = mmn_diagnostics_effect_of_EB_corr(Dbefore, Dafter, channels, trials);

saveas(fh1, details.eeg.quality.averageeyeblinkcorrectionfigure1,'fig');
saveas(fh2, details.eeg.quality.averageeyeblinkcorrectionfigure2,'fig');

close all

end


function [ Dbefore, Dafter ] = dmpad_get_average_EB_responses( details, options )

if ~exist(details.eeg.quality.epoched_EB_uncorrected, 'file')
    
    switch options.eeg.preproc.eyeCorrMethod
        case   'ssp'
            list = dir(fullfile(details.eeg.preproot, ['ceaffMspmeeg_' details.eeg.subproname '*.mat']));
    end
    if numel(list) ~= 1
        error(['Could not unambiguously determine EEG file epoched to eyeblinks (uncorrected)' ...
            ' for subject ' details.eeg.subproname]);
    end
    D = spm_eeg_load(fullfile(details.eeg.preproot, list.name));
    Dinitial = move(D, details.eeg.quality.epoched_EB_uncorrected);
else
    Dinitial = spm_eeg_load(details.eeg.quality.epoched_EB_uncorrected);
end


if ~exist(details.eeg.quality.average_EB_uncorrected, 'file')
    D = tnueeg_average(Dinitial, 's');
    Dbefore = move(D, details.eeg.quality.average_EB_uncorrected);
end

if ~exist(details.eeg.quality.epoched_EB_corrected, 'file')
    Dcorr = mmn_correct_epoched_EB(Dinitial, details, options);
    D = tnueeg_average(Dcorr, 's');
    Dafter = move(D, details.eeg.quality.average_EB_corrected);
end

if ~exist(details.eeg.quality.average_EB_corrected, 'file')
    Dcorr = spm_eeg_load(details.eeg.quality.epoched_EB_corrected);
    D = tnueeg_average(Dcorr, 's');
    Dafter = move(D, details.eeg.quality.average_EB_corrected);
end

if ~exist('Dbefore', 'var')
    Dbefore = spm_eeg_load(details.eeg.quality.average_EB_uncorrected);
end

if ~exist('Dafter', 'var')
    Dafter  = spm_eeg_load(details.eeg.quality.average_EB_corrected);
end


end

