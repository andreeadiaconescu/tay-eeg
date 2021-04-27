function source = mmn_select_source_recon(options)
source.radius         = 16;
source.msp            = true;
source.priors         = fullfile(options.root, 'configs', 'priors.mat');
source.priorsmask     = {''};
source.doVisualize    = false;
source.secondlevelDir = ...
    fullfile(options.eeg.preproc.grouproot, [options.eeg.part '_Source_' options.eeg.stats.firstLevelDesign]);
source.firstLevelAnalysisWindow = [100 445];
source.type           = 'source';
end