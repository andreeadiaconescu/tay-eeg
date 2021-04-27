function D = tayeeg_tfsource(id, options)
% IN
%   options     options = tayeeg_analysis_options
% 
% See also tayeeg_analysis_options

details = tayeeg_subjects(id, options);

keep = 0;

try
    D = spm_eeg_load(details.eeg.source.filename);
catch
    D = tayeeg_source(id, options);
end

fnameorig = fullfile(D);

S = [];
S.D = D;
S.channels = {'LFP'};
S.frequencies = 4:48;
S.timewin = [-Inf Inf];
S.phase = 0;
S.method = 'morlet';
S.settings.ncycles = 4;
S.settings.timeres = 0;
S.settings.subsample = 5;
S.prefix = '';
D = spm_eeg_tf(S);


S = [];
S.D = D;
S.method = 'Sqrt';
S.prefix = 'r';
S.timewin = [-Inf 0];
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
S.timewin = [-100 450];
S.freqwin = [-Inf Inf];
S.channels = {'all'};
S.prefix = 'p';
D = spm_eeg_crop(S);

if ~keep, delete(S.D); end

D = move(D, spm_file(fnameorig, 'prefix', 'rtf_'));