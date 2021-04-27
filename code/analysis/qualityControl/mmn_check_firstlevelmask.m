function fh = mmn_check_firstlevelmask( id, options )
%DMPAD_CHECK_1STLEVEL_MASK Displays the 1st level mask.nii image and saves the plot for one subject
%of the DMPAD study. 
%   IN:     id          - subject identifier string, e.g. '001'
%           options     - the struct that holds all analysis options
%   OUT:    fh          - figure handle to the image

details = tayeeg_subjects(id, options);

spm_check_registration(fullfile(details.eeg.firstLevel.sensor.pathStats, 'mask.nii'));
title(details.eeg.subproname);

fh = gcf;
saveas(fh, details.eeg.quality.firstlevelmask,'fig');
saveas(fh, details.eeg.quality.firstlevelmask, 'png');
close(gcf);

end

