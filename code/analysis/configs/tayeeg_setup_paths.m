function output = tayeeg_setup_paths()
% restores default paths, add project paths including SPM (but without
% sub-folders), sets up batch editor
%
%   output = dmpad_setup_paths(input)
%
% IN
%
% OUT
%
% EXAMPLE
%   dmpad_setup_paths
%
%   See also
%
% Author:   Lars Kasper
% Created:  2018-02-05
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%


pathProject = fileparts(mfilename('fullpath'));

% remove all other toolboxes
restoredefaultpath;

warning off; % to remove obvious path warnings for now


% add project path with all sub-paths
addpath(genpath(pathProject));


%% remove SPM subfolder paths 
% NOTE: NEVER add SPM with subfolders to your path, since it creates
% conflicts with Matlab core functions, e.g., uint16

pathSpm = fileparts(which('spm'));
% remove subfolders of SPM, since it is recommended,
% and fieldtrip creates conflicts with Matlab functions otherwise
rmpath(genpath(pathSpm));
addpath(pathSpm);

%% Remove EEG lab path for downsampling
pathEegLab = fileparts(which('eeglab'));
rmpath(genpath(pathEegLab));

tayeeg_setup_spm();