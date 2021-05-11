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

expt_folder = pwd;

eeg_folder = fullfile(expt_folder, 'EEG');
mmn_folder = fullfile(expt_folder, 'MMN');
rest_folder = fullfile(expt_folder, 'Rest');
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


%cd(root);
cd(eeg_folder);

%% Get User data
ui = DH_GUI_GUIDE();


%% Launch task
switch ui.modality
    case 'Behavior'
        scanner_mode = 0;
    case 'fMRI'
        scanner_mode = 1;
    case 'EEG'
        scanner_mode = 3;
        
end


% ------------------------- IOIO -------------------------
switch ui.task
    case 'IOIO'
        addpath(genpath('IOIO'));
        try
            cd 'IOIO'
        end
        
        switch ui.session
            case 'practice'
                SLadv_practice(ui.subject_ID,ui.run,scanner_mode,ui.key_mode);
            case 'task'
                SLadv_task(ui.subject_ID,ui.run,scanner_mode,ui.key_mode,ui.adviser);
        end
        
        % ------------------------- WM -------------------------
    case 'WM'
        addpath(genpath('WM'));
        try
            cd 'WM'
        end
        switch ui.session
            case 'practice'
                wm_practice(ui.subject_ID, ui.wm_task);
            case 'task'
                wm_task(ui.subject_ID, ui.wm_task, scanner_mode);
        end
        
        % ------------------------- MMN -------------------------
    case 'MMN'
        addpath(genpath('WM'));
        try
            cd 'MMN'
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
                        exp_MMN_EEG_instructions_with_tone_test(ui.subject_ID, ui.handedness, 0);
                    case 'task'
                        DH_exp_MMN_eeg(ui.subject_ID, ui.handedness,scanner_mode);
                end
        end
        
        % ------------------------- Resting -------------------------
    case 'Rest'
        addpath(genpath('Rest'));
        addpath(genpath('MMN/cogent2000v1.32'));
        try
            cd 'Rest'
        end
        
        switch ui.session
            case 'practice'
                %COMPI_Rest_practice_DH(scanner_mode);     % JG_MOD
                COMPI_Rest_practice_DH_eng_2(scanner_mode);

            case 'task'
                %COMPI_Rest_DH(ui.subject_ID,scanner_mode);  % JG_MOD
                COMPI_Rest_DH_eng_2(ui.subject_ID,scanner_mode);
    end
 
end



%%
%cd(root)
cd(expt_folder)
clear ui out ans root scanner_mode


