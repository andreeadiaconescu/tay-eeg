function DH_COMPI_launch_task(ui)

%% Paths
root = 'D:\COMPI';
%root = 'C:\Users\Danie\Dropbox\EEG_IOIO\paradigms';



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
            case 'experiment'
                SLadv_task(ui.subject_ID,ui.run,scanner_mode,ui.key_mode);
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
            case 'experiment'
                wm_task(ui.subject_ID, ui.wm_task,scanner_mode);
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
                        exp_MMN_scanner_instructions_with_tone_test(ui.subject_ID, ui.handedness, 1);
                    case 'experiment'
                        exp_MMN_scanner(ui.subject_ID, ui.handedness,1);
                end
                
            case 1 %fMRI
                switch ui.session
                    case 'practice'
                        exp_MMN_scanner_instructions_with_tone_test(ui.subject_ID, ui.handedness, 0);
                    case 'experiment'
                        exp_MMN_scanner(ui.subject_ID, ui.handedness,scanner_mode);
                end
                
            case 3 %EEG
                switch ui.session
                    case 'practice'
                        exp_MMN_scanner_instructions_with_tone_test(ui.subject_ID, ui.handedness, 0);
                    case 'experiment'
                        exp_MMN_eeg(ui.subject_ID, ui.handedness,scanner_mode);
                end
        end
        
        % ------------------------- Resting -------------------------
    case 'resting'
        addpath(genpath('Rest'));
        addpath(genpath('MMN/cogent2000v1.32'));
        try
            cd 'Rest'
        end
        
        switch ui.session
            case 'practice'
                COMPI_Rest_practice_DH;
            case 'experiment'
                COMPI_Rest_DH(ui.subject_ID,scanner_mode);
        end
end


%%
cd(root)
delete 'ui.mat';


