function run_tay_eeg_expt
%%
% TAY Experiment Launcher Function
% ================================
%
% Usage:
%        This function should be called from the 
%        'tay-eeg/code/experiment' folder
% 
%        To run, simply type 'run_tay_eeg_expt' on the matlab
%        prompt, and follow the GUI instructions. 
%

%%

clc
close all   
clear all

%[~, uid] = unix('whoami');
%switch uid(1:end-1)
%    case 'ifp-b-082\labor'
%       root = 'D:\COMPI';
%    case 'desktop-pllks1m\daniel'
%        root = 'C:\Users\Danie\Dropbox\EEG_IOIO\COMPI\COMPI_paradigms';
%    case 'daniel-hp\daniel'
%        root = 'C:\Users\Daniel\Dropbox\EEG_IOIO\COMPI\COMPI_paradigms';
%    case 'desktop-ctoao6k\compi'
%        root = 'C:\Users\compi\Dropbox\EEG_IOIO\COMPI\COMPI_paradigms';
%    case 'drea'
%        root = '/Users/drea/Documents/CAMH/TAY/EEG';
%    otherwise
%        % JG_MOD
%        root = 'C:\Users\john_griffiths\Desktop\KCNI_EEGLab\from_ad_dropbox\TAY\EEG';
%end

%% Setup paths for data toolbox and scripts
expt_folder = pwd;
eeg_folder = fullfile(expt_folder, 'EEG');
mmn_folder = fullfile(eeg_folder, 'MMN');
rest_folder = fullfile(eeg_folder, 'Rest');
toolboxes_folder = fullfile(expt_folder, 'Toolboxes');

addpath(genpath(mmn_folder))

%cd(root);
%addpath(genpath(fullfile(root,'GUI','GUI_GUIDE')));
addpath(genpath(eeg_folder))

addpath(genpath(fullfile(eeg_folder,'GUI','GUI_GUIDE')));

addpath(genpath(rest_folder))

%addpath('C:\Users\john_griffiths\Desktop\KCNI_EEGLab\from_ad_dropbox\TAY\Toolboxes\BioSemiUSBtrigger-master');
addpath(fullfile(toolboxes_folder, 'BioSemiUSBtrigger-master'));

addpath(genpath(fullfile(toolboxes_folder, 'cogent2000v1.32')));


resetup_psychtoolbox = 0;
if resetup_psychtoolbox == 1
    cd(fullfile(toolboxes_folder, 'Psychtoolbox'))
    SetupPsychtoolbox;
end



%% cd EEG folder
% cd(eeg_folder)

%% Get User data
ui = DH_GUI_GUIDE();


%% Launch task

scanner_mode = 3; % changed by zheng



% ------------------------- IOIO -------------------------
switch ui.task
    
        % ------------------------- MMN -------------------------
    case 'MMN'
        addpath(genpath('MMN'));
        try
            cd(mmn_folder);
        end
        
        switch scanner_mode
            case 0 % behavior debug
                switch ui.session
                    case 'practice'
                        exp_MMN_scanner_instructions_with_tone_test(ui.subject_ID, ui.handedness, scanner_mode);
                    case 'task'
                        DH_exp_MMN_scanner(ui.subject_ID, ui.handedness,scanner_mode);
                end
                
            case 1 %fMRI
                switch ui.session
                    case 'practice'
                        exp_MMN_scanner_instructions_with_tone_test(ui.subject_ID, ui.handedness, scanner_mode);
                    case 'task'
                        DH_exp_MMN_scanner(ui.subject_ID, ui.handedness,scanner_mode);
                end
                
            case 3 %EEG
                switch ui.session
                    case 'practice'
                        exp_MMN_EEG_instructions_with_tone_test(ui.subject_ID, ui.handedness, 0, expt_folder);
                    case 'task'
                        DH_exp_MMN_eeg(ui.subject_ID, ui.handedness,scanner_mode, expt_folder);
                end
        end
        
        % ------------------------- Resting -------------------------
    case 'Rest'
        addpath(genpath('Rest'));
        %addpath(genpath('MMN/cogent2000v1.32'));
        try
            cd(rest_folder)
        end
        
        switch ui.session
            case 'practice'
                %COMPI_Rest_practice_DH(scanner_mode);     % JG_MOD
                COMPI_Rest_practice_DH_eng_2(scanner_mode, expt_folder);

            case 'task'
                %COMPI_Rest_DH(ui.subject_ID,scanner_mode);  % JG_MOD
                COMPI_Rest_DH_eng_2(ui.subject_ID,scanner_mode, expt_folder);
        end
 
end



%%
%cd(root)
cd(expt_folder)
clear ui out ans root scanner_mode


