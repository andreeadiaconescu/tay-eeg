function [job1] = mmn_beamformer_job(D, VOI, details)
res = mkdir(details.source.beamforming.dirname); 
job1{1}.spm.tools.beamforming.data.dir = {details.source.beamforming.dirname};
job1{1}.spm.tools.beamforming.data.D = {fullfile(D)};
job1{1}.spm.tools.beamforming.data.val = 1;
job1{1}.spm.tools.beamforming.data.gradsource = 'inv';
job1{1}.spm.tools.beamforming.data.space = 'MNI-aligned';
job1{1}.spm.tools.beamforming.data.overwrite = 1;
job1{2}.spm.tools.beamforming.sources.BF(1) = cfg_dep('Prepare data: BF.mat file', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
job1{2}.spm.tools.beamforming.sources.reduce_rank = [2 3];
job1{2}.spm.tools.beamforming.sources.keep3d = 1;
job1{2}.spm.tools.beamforming.sources.plugin.mesh.orient = 'original';
job1{2}.spm.tools.beamforming.sources.plugin.mesh.fdownsample = 1;
job1{2}.spm.tools.beamforming.sources.plugin.mesh.flip = false;
job1{2}.spm.tools.beamforming.sources.visualise = 0;
job1{3}.spm.tools.beamforming.features.BF(1) = cfg_dep('Define sources: BF.mat file', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
job1{3}.spm.tools.beamforming.features.whatconditions.all = 1;
job1{3}.spm.tools.beamforming.features.woi = [-300 0]; %
job1{3}.spm.tools.beamforming.features.modality = {'EEG'};
job1{3}.spm.tools.beamforming.features.fuse = 'no';
job1{3}.spm.tools.beamforming.features.plugin.cov.foi = [0 Inf];
job1{3}.spm.tools.beamforming.features.plugin.cov.taper = 'hanning';
job1{3}.spm.tools.beamforming.features.regularisation.manual.lambda = 0;
job1{3}.spm.tools.beamforming.features.bootstrap = false;
job1{4}.spm.tools.beamforming.inverse.BF(1) = cfg_dep('Covariance features: BF.mat file', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));

for i = 1:size(VOI, 1)
    job1{4}.spm.tools.beamforming.inverse.plugin.deflect.filter(i).label = VOI{i, 1};
    job1{4}.spm.tools.beamforming.inverse.plugin.deflect.filter(i).passband{1}.voi.pos = VOI{i, 2};
    job1{4}.spm.tools.beamforming.inverse.plugin.deflect.filter(i).passband{1}.voi.radius = radius;
    job1{4}.spm.tools.beamforming.inverse.plugin.deflect.filter(i).svdpassband = 0;
    job1{4}.spm.tools.beamforming.inverse.plugin.deflect.filter(i).forcepassband = 0;
    job1{4}.spm.tools.beamforming.inverse.plugin.deflect.filter(i).stopband = cell(1, 0);
    job1{4}.spm.tools.beamforming.inverse.plugin.deflect.filter(i).svdstopband = 0;
    job1{4}.spm.tools.beamforming.inverse.plugin.deflect.filter(i).usecov = 1;
end


job1{4}.spm.tools.beamforming.inverse.plugin.deflect.snr = 5;
job1{4}.spm.tools.beamforming.inverse.plugin.deflect.trunc = 0;

end