% -------------------------------------------------------------------------
%
% This Script Launches the Experiment of COMPI (Computational Models of 
% Persecutory Ideation) including the GUI session to define User Input 
%
% -------------------------------------------------------------------------


%% Clear Memory
clc
close all
clear all

%% Paths
%root = 'D:\COMPI';
root = '/Users/drea/Documents/CAMH/TAY/EEG';
addpath('GUI')

%% Start GUI
UserInput = COMPI_Launcher_GUI();
acceptSettings = COMPI_Launcher_Settings(UserInput);

switch acceptSettings
    case 0
        disp('Execution of the Experiment has been terminated by the User.')
        return
end


% disp('You are running with the following settings: ')
% disp(UserInput);
% prompt ='\n Do you want to continue...? \n (y = yes, n = no) \n';
% keyPress = input(prompt, 's');
% 
% if strcmp(keyPress, 'y') ~= 1
%     disp('Execution of the Experiment has been aborted by the User.')
%     break
% end


%% Enter subject code
sbj = UserInput.Subject; %sprintf('COMPI_%s', UserInput.Subject);

switch strcmp(sbj, 'Enter Code')
    case 1
        disp('You have not entered a valid Subject Code')
        return
end


%% Enter task
% ------------------------- IOIO -------------------------
switch UserInput.Task
    case 'SRL'
        cd 'IOIO'
        switch UserInput.Session
            case 'Practice'
                SLadv_practice(sbj);   
            case 'Experiment'
                SLadv_short(sbj);  
        end

% ------------------------- WM -------------------------
    case 'WM'
        cd 'WM'
        switch UserInput.Session
            case 'Practice'
                try 
                    wm_practice(sbj, 'Memory');
                catch ME
                    sca
                    rethrow(ME)
                end

            case 'Experiment'
                try 
                    wm_task(sbj,UserInput.Settings);
                catch ME
                    sca
                    rethrow(ME)
                end    
        end

% ------------------------- MMN -------------------------
    case 'MMN'
        cd 'MMN'
        switch UserInput.Session
            case 'Practice'
                try
                    % CORRECT PRACTICE SESSSION
                    exp_MMN_eeg(sbj, 'r'); %settings are handedness
                catch ME
                    sca
                    rethrow(ME)
                end                 
            case 'Experiment'
                try
                    exp_MMN_eeg(sbj, 'r'); %settings are handedness
                catch ME
                    sca
                    rethrow(ME)
                end      
        end
        
% ------------------------- REST -------------------------        
    case 'Rest'
        cd Rest
        switch UserInput.Session
            case 'Practice'
                COMPI_Rest_practice()
            case 'Experiment'
                COMPI_Rest();
        end
end

clc
cd(root)


        
                
                
                
