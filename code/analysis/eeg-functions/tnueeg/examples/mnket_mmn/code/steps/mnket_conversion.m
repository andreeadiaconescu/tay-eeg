function mnket_conversion(id, options)
%MNKET_CONVERSION Converts preprocessed epoched EEG data to 3D images and 
%smoothes them for one subject from the MNKET study.
%   IN:     id                  - subject identifier, e.g '0001'
%   OUT:    --

% general analysis options
if nargin < 2
    options = mnket_set_analysis_options;
end

% paths and files
[details, ~] = mnket_subjects(id, options);

% record what we're doing
diary(details.logfile);
mnket_display_analysis_step_header('conversion', id, options.conversion);

% determine the preprocessed file to use for conversion
switch options.conversion.mode
    case 'diffWaves'
        prepfile = details.difffile;
    case 'modelbased'
        prepfile = details.prepfile;
    case 'ERPs'
        prepfile = details.erpfile;
    case 'mERPs'
        prepfile = details.mergfile;
end

% try whether this file exists
try
    D = spm_eeg_load(prepfile);
catch
    disp('This file: ')
    disp(prepfile)
    disp('could not been found.')
    error('No final preprocesed EEG file')
end

try
    % check for previous smoothing
    im = spm_vol(details.smoofile{1});
    disp(['Images for subject ' id ' have been converted and smoothed before.']);
    if options.conversion.overwrite
        clear im;
        disp('Overwriting...');
        error('Continue to conversion step');
    else
        disp('Nothing is being done.');
    end
catch
    disp(['Converting subject ' id ' ...']);

    % convert EEG data
    [images, ~] = tnueeg_convert2images(D, options);
    disp(['Converted EEG data for subject ' id ' in mode ' options.conversion.mode]);

    % and smooth the resulting images
    tnueeg_smooth_images(images, options);
    disp(['Smoothed images for subject ' id ' in mode ' options.conversion.mode]);
end

cd(options.workdir);

diary OFF
end
