function [job3] = dmpad_write_beamformer_job(details)
job3{1}.spm.tools.beamforming.output.BF = {details.source.beamforming.file};
job3{1}.spm.tools.beamforming.output.plugin.montage.method = 'keep';
job3{1}.spm.tools.beamforming.output.plugin.montage.voidef = struct('label', {}, 'pos', {}, 'radius', {});
job3{2}.spm.tools.beamforming.write.BF(1) = cfg_dep('Output: BF.mat file', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
job3{2}.spm.tools.beamforming.write.plugin.spmeeg.mode = 'write';
job3{2}.spm.tools.beamforming.write.plugin.spmeeg.modality = 'EEG';
job3{2}.spm.tools.beamforming.write.plugin.spmeeg.addchannels.none = 0;
job3{2}.spm.tools.beamforming.write.plugin.spmeeg.prefix = 'B';
end