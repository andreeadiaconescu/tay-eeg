function [job2] = mmn_visualise_beamformer_job(VOI, details)

job2{1}.spm.tools.beamforming.output.BF = {details.source.beamforming.file};
job2{1}.spm.tools.beamforming.output.plugin.image_filtcorr.corrtype = 'filtlf';
job2{1}.spm.tools.beamforming.output.plugin.image_filtcorr.modality = 'EEG';
job2{2}.spm.tools.beamforming.write.BF(1) = cfg_dep('Output: BF.mat file', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
job2{2}.spm.tools.beamforming.write.plugin.gifti.normalise = 'no';
job2{2}.spm.tools.beamforming.write.plugin.gifti.space = 'mni';
job2{2}.spm.tools.beamforming.write.plugin.gifti.visualise = 1;

for i = 1:size(VOI, 1)
    job2{1}.spm.tools.beamforming.output.plugin.image_filtcorr.seedspec.label = VOI{i, 1};
    
    spm_jobman('run', vis_beamformerJob);
    
    set(gcf, 'Tag', VOI{i, 1});
    set(gcf, 'Name', VOI{i, 1});
    title(VOI{i, 1});
end
end