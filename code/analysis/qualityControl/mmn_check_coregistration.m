function mmn_check_coregistration(id, options)
%MMN_CHECK_COREGISTRATION Plots the mesh and data coregistration (EEG space to sMRI space via
%fiducial locations) and saves the plots for one subject from the DMPAD study.
%   IN:     id          - subject identifier string, e.g. '001'
%           options     - the struct that holds all analysis options
%   OUT:    -

details = tayeeg_subjects(id, options);
if ~exist(details.eeg.quality.root, 'dir')
    mkdir(details.eeg.quality.root);
end
D = spm_eeg_load(details.eeg.prepfile);

% check the mesh
spm_eeg_inv_checkmeshes(D);

saveas(gcf,details.eeg.quality.coregmeshfigure,'fig');

close all


% check the mesh
spm_eeg_inv_checkdatareg(D, 1, 1);

saveas(gcf, details.eeg.quality.coregdatafigure,'fig');
close all
end