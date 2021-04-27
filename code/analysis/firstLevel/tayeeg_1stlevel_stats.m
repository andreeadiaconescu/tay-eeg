function tayeeg_1stlevel_stats(id, options,analysis_type)
% TAYEEG_1STLEVEL_STATS Computes the first level contrast images for modelbased
%statistics for one subject from the MNKET study.
%   IN:     id      - subject identifier, e.g '0001'
%           options - the struct that holds all analysis options
%
% OUT
%   D          SPM.MAT file

% general analysis options
if nargin < 2
    options = tayeeg_analysis_options;
end

if nargin < 3
    analysis_type = options.eeg.type;
end

% paths and files
details = tayeeg_subjects(id, options);

%% record what we're doing
diary(details.eeg.logfile);
mmn_display_analysis_step_header('firstlevel stats', id, options.eeg.stats);
%% Conversion and smoothing of single-trial sensor data
switch options.eeg.preproc.smoothing
    case 'yes'
        try
            % check for previous smoothing
            im = spm_vol(details.eeg.conversion.sensor.smoofile);
            disp(['Images for subject ' id ' have been converted and smoothed before.']);
            if options.eeg.conversion.overwrite
                clear im;
                disp('Overwriting...');
                error('Continue to conversion step');
            else
                disp('Nothing is being done.');
            end
        catch
            disp(['Converting subject ' id ' ...']);
            % convert EEG data
            D = spm_eeg_load(details.eeg.prepfile);
            [images, ~] = tnueeg_convert2images(D, options);
            disp(['Converted EEG data for subject ' id]);
            % and smooth the resulting images
            tnueeg_smooth_images(images, options);
            disp(['Smoothed images for subject ' id]);
        end
end

%% First-level Stats

% first, correct the regressors for trials that were rejected during
% preprocessing
design = mmn_correct_regressors_for_EEG_artefacts(details, options);
disp(['Corrected regressors for subject ' id]);

disp(['Computing 1st level stats for subject ' id ' ...']);

%% Check whether files needed for stats exist, error otherwise
switch analysis_type
    case 'sensor'
        fileToLoad = details.eeg.prepfile;
        stringRerunFunction = 'tayeeg_mmn_preprocessing_reject_eyeblinks';
        pathImages  = details.eeg.firstLevel.sensor.pathImages;
        pathStats   = details.eeg.firstLevel.sensor.pathStats;
        timeWindow  = options.eeg.stats.firstLevelAnalysisWindow;
        switch options.eeg.preproc.smoothing
            case 'yes'
                fileImage   = details.eeg.conversion.sensor.smoofile;
            case 'no'
                fileImage   = details.eeg.firstLevel.sensor.fileImage;
        end
    case 'source'
        fileToLoad = details.eeg.source.filename;
        stringRerunFunction = 'tayeeg_source';
        pathImages  = details.eeg.firstLevel.source.pathImages;
        pathStats  = details.eeg.firstLevel.source.pathStats;
        pfxImages = details.eeg.firstLevel.source.prefixImages;
        timeWindow = options.eeg.source.firstLevelAnalysisWindow;
        switch options.eeg.preproc.smoothing
            case 'yes'
                fileImage   = details.eeg.conversion.source.smoofile;
            case 'no'
                fileImage   = details.eeg.firstLevel.source.fileImage;
        end
        
    case 'tfsource'
        fileToLoad = details.eeg.source.tf.filename;
        stringRerunFunction = 'tayeeg_timeFrequency';
        pathImages  = details.eeg.firstLevel.tf.pathImages;
        pathStats  = details.eeg.firstLevel.tf.pathStats;
        pfxImages = details.eeg.firstLevel.tf.prefixImages;
        timeWindow = options.eeg.source.firstLevelAnalysisWindow;
        switch options.eeg.preproc.smoothing
            case 'yes'
                fileImage   = details.eeg.conversion.tf.smoofile;
            case 'no'
                fileImage   = details.eeg.firstLevel.tf.fileImage;
        end
end

hasConvertedImages = exist(fileImage, 'file');

if exist(fileToLoad, 'file')
    D = spm_eeg_load(fileToLoad);
else
    error(sprintf(...
        ['EEG data not found \n\tfile: %s\nCannot perform single subject stats.\n', ...
        'Please run preprocessing again, starting from %s!\n'], ...
        fileToLoad, stringRerunFunction))
end

%% delete existing SPM folder and create non-existing one
fileSpm     = fullfile(pathStats, 'SPM.mat');

if exist(fileSpm, 'file')
    delete(fileSpm);
else
    if ~exist(pathStats, 'dir')
        res = mkdir(pathStats);
    end
end
factors = fieldnames(design);

%% Set up GLM design and estimate job

job = {};

if hasConvertedImages
    iJobFactorialDesign = 1;
    for i=1:size(design.epsilon2,1)
        scans{i,1}=[fileImage ',' num2str(i)];
    end
    
    job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.scans = scans;
else % convert2Images is first job
    iJobFactorialDesign = 2;
    % same for all conversion jobs
    job{1}.spm.meeg.images.convert2images.conditions = cell(1, 0);
    job{1}.spm.meeg.images.convert2images.timewin = timeWindow;
    job{1}.spm.meeg.images.convert2images.D = {fullfile(D)};
    job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.scans(1) = cfg_dep('Convert2Images: M/EEG exported images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
end

iJobFcon = iJobFactorialDesign + 2;


%% Factorial design specification
for i = 1:numel(factors)
    job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.mcov(i).c = design.(factors{i});
    job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.mcov(i).cname = factors{i};
    job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.mcov(i).iCC = 1;
end

job{iJobFactorialDesign}.spm.stats.factorial_design.des.mreg.incint = 1;
job{iJobFactorialDesign}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
job{iJobFactorialDesign}.spm.stats.factorial_design.masking.tm.tm_none = 1;
job{iJobFactorialDesign}.spm.stats.factorial_design.masking.im = 1;
job{iJobFactorialDesign}.spm.stats.factorial_design.masking.em = {''};
job{iJobFactorialDesign}.spm.stats.factorial_design.globalc.g_omit = 1;
job{iJobFactorialDesign}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
job{iJobFactorialDesign}.spm.stats.factorial_design.globalm.glonorm = 1;
job{iJobFactorialDesign+1}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{iJobFactorialDesign}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
job{iJobFactorialDesign+1}.spm.stats.fmri_est.write_residuals = 0;
job{iJobFactorialDesign+1}.spm.stats.fmri_est.method.Classical = 1;

job{iJobFcon}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{iJobFactorialDesign+1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));


%% Change analysis type in function
switch analysis_type
    case 'sensor'
        
        %% Set up converted Image input file dependencies for GLM
        if ~hasConvertedImages
            % convert2Images First            
            %% image conversion job
            job{1}.spm.meeg.images.convert2images.mode = 'scalp x time';
            job{1}.spm.meeg.images.convert2images.channels{1}.type = 'EEG';
            job{1}.spm.meeg.images.convert2images.prefix = details.eeg.firstLevel.sensor.prefixImages;
        end
        
    case 'source'
        
        % images are always converted...
        D = copy(D, spm_file(fullfile(D), 'prefix', 'abs'));
        chan = D.indchantype('LFP');
        D(chan, :, :) = abs(D(chan, :, :));
        
        job{1}.spm.meeg.images.convert2images.mode = 'time';
        
    case 'tfsource'
        % images are always converted...
        chan = D.indchantype('LFP');
        job{1}.spm.meeg.images.convert2images.mode = 'time x frequency';
end


%% F - contrast creation job
job{iJobFcon}.spm.stats.con.delete = 1;

isTimeFreqSource = contains(analysis_type, 'tfsource');

for i = 1:numel(factors)
    
    isPE = ~isempty(strfind(factors{i}, 'PE'));
    if isPE && isTimeFreqSource %% PE with t contrast
        job{iJobFcon}.spm.stats.con.consess{i}.tcon.name    = factors{i};
        job{iJobFcon}.spm.stats.con.consess{i}.tcon.weights = zeros(1, numel(factors)+1);
        job{iJobFcon}.spm.stats.con.consess{i}.tcon.weights(i+1) = 1;
        job{iJobFcon}.spm.stats.con.consess{i}.tcon.sessrep = 'none';
    else % all other quantities with F-contrast
        job{iJobFcon}.spm.stats.con.consess{i}.fcon.name    = factors{i};
        job{iJobFcon}.spm.stats.con.consess{i}.fcon.weights = zeros(1, numel(factors)+1);
        job{iJobFcon}.spm.stats.con.consess{i}.fcon.weights(i+1) = 1;
        job{iJobFcon}.spm.stats.con.consess{i}.fcon.sessrep = 'none';
    end
end


%% use dependencies for all other submodules of batch

job{iJobFcon + 1} = mmn_get_job_contrast_manager(iJobFcon, analysis_type);

[~,~] = mkdir(pathImages);
fprintf('Trying to run job of tayeeg_1stlevel_stats\n');

switch analysis_type
    case 'sensor'
        
        job{iJobFactorialDesign}.spm.stats.factorial_design.dir = {pathStats};
        mmn_save_subject_batch(job, details.eeg.log.batches.statsfile);
        
        if ~hasConvertedImages
            warning off
            fprintf('Subject Id %s: File %s does not exist\n Converting images now...\n', id, fileImage);
        end
        warning on
        
        mmn_save_subject_batch(job, details.eeg.log.batches.statsfile);
        spm_jobman('run', job);
    case {'source', 'tfsource'}
        for i = 1:length(chan)
            stringChannel = char(D.chanlabels(chan(i)));
            pathSpmChannel = fullfile(pathStats, stringChannel);
            job{1}.spm.meeg.images.convert2images.channels{1}.chan = stringChannel;
            job{1}.spm.meeg.images.convert2images.prefix = [pfxImages stringChannel '_'];
            
            res = mkdir(pathSpmChannel);
            if exist(fullfile(pathSpmChannel, 'SPM.mat'), 'file')
                delete(fullfile(pathSpmChannel, 'SPM.mat'));
            end
            
            job{iJobFactorialDesign}.spm.stats.factorial_design.dir = {pathSpmChannel};
            
            mmn_save_subject_batch(job, ...
                spm_file(details.eeg.log.batches.statsfile, 'suffix', ['_' stringChannel]));
            
            spm_jobman('run', job);
            
        end
end


