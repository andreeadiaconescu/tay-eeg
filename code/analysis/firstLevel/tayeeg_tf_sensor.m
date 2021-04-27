function D = tayeeg_tf_sensor(id, options)
% IN
%   options     options = dmpad_set_analysis_options
% 
% See also dmpad_set_analysis_options

details = tayeeg_subjects(id, options);

bands = {'alpha', [7 12], 200;...
    'beta', [13 30], 100;
    'lgamma', [30 48], 100;
    'hgamma', [52 98], 100};

keep = 0;

try
    Dorig = spm_eeg_load(details.eeg.prepfile);
catch
    Dorig = tayeeg_mmn_preprocessing_reject_eyeblinks(id);
end

cd(details.eeg.preproot);

fnameorig = fullfile(Dorig);

for b = 1:size(bands, 1)
      
    S = [];
    S.D = Dorig;
    S.method = 'mtmconvol';
    S.channels = {'EEG'};
    S.taper    = 'dpss';
    S.freqres  = diff(bands{b, 2});
    S.frequencies = mean(bands{b, 2});
    S.timeres = bands{b, 3};
    S.timestep = 50;
    S.timewin = [-Inf Inf];   
    D = spm_eeg_tf(S);
    
    S = [];
    S.D = D;
    S.method = 'Sqrt'; %'Log'
    S.prefix = 'r';
    D = spm_eeg_tf_rescale(S);
    
    if ~keep, delete(S.D); end
    
    S = [];
    S.D = D;
    S.method = 'Diff';
    S.prefix = 'r';
    S.timewin = [-100 0];
    D = spm_eeg_tf_rescale(S);
    
    if ~keep, delete(S.D); end
    
    S = [];
    S.D = D;
    S.timewin = [100 450];
    S.freqwin = [-Inf Inf];
    S.channels = {'all'};
    S.prefix = 'p';
    D = spm_eeg_crop(S);
    
    if ~keep, delete(S.D); end
    
    S = [];
    S.D = D;  
    D = spm_eeg_avgfreq(S);
    
    if ~keep, delete(S.D); end
    
    D = move(D, spm_file(fnameorig, 'prefix', [bands{b, 1} '_']));
end