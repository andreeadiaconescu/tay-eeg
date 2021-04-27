function mmn_summarize_step( stepStr, options )
% MMN_SUMMARIZE_STEP Summarizes plots from all subjects for one processing step and saves this info
%in a pdf document.
%   IN:     stepStr - step identifier string, e.g. 'coregistration'
%           options - the struct that holds all analysis options
%   OUT:    -

qualityRoot = fullfile(options.eeg.preproc.grouproot, 'quality');
stepRoot    = fullfile(qualityRoot, stepStr);
if ~exist(qualityRoot, 'dir')
    mkdir(qualityRoot)
end
if ~exist(stepRoot, 'dir')
    mkdir(stepRoot)
end
for iSub = 1: numel(options.subjectIDs)
    id = char(options.subjectIDs{iSub});
    details = tayeeg_subjects(id, options);

    figureTitle = ['TAYEEG subject ' id];
    switch lower(stepStr)
        case {'ebdetect', 'ebdetection', 'eyeblinkdetection'}
            dmpad_save_single_figure_as_png_with_title(details.eeg.eyeblinkfig, figureTitle, stepRoot);
        case {'ebconf', 'ebconfounds', 'eyeblinkconfounds'}
            dmpad_save_single_figure_as_png_with_title(details.eeg.quality.eyeblinkconfoundsfigure, figureTitle, stepRoot);
        case {'ebcorr', 'ebcorrection', 'eyeblinkcorrection'}
            dmpad_save_single_figure_as_png_with_title(...
                details.eeg.quality.eyeblinkcorrectionfigure, figureTitle, stepRoot); 
        case {'eboverlap', 'eyeblinkoverlap'}
            dmpad_save_single_figure_as_png_with_title(...
                details.eeg.eyeblinkoverlapfigure, figureTitle, stepRoot);
        case {'coreg', 'coregistration'}
            dmpad_save_single_figure_as_png_with_title(details.eeg.quality.coregdatafigure, figureTitle, stepRoot);
        case {'mask', 'firstlevelmask'}
            copyfile([details.eeg.quality.firstlevelmask '.png'], stepRoot);
    end
end

end

function dmpad_save_single_figure_as_png_with_title(fullFileName, figureTitle, destination)

[~, fileName, ~] = fileparts(fullFileName);
fh = openfig(fullFileName);
title(figureTitle)
saveas(fh, fullfile(destination, fileName), 'png');
close(fh);

end