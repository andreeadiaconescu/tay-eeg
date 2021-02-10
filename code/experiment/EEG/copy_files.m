function copy_files
% -------------------------------------------------------------------------
% Function to copy files of a participant specified by the user to external
% hard disk with the following structure:
%
% project_name/data/task/Subject ID/behav/
%
% -------------------------------------------------------------------------



%% Specify project name
project_name = 'COMPI';
tasks = {'IOIO','Rest','WM','MMN'};


%% Set up paths
[~, uid] = unix('whoami');
switch uid(1:end-1)
    case 'ifp-b-082\labor'
        from = ['D:\' project_name];
        to = ['E:\' project_name '\data\'];
    case 'desktop-pllks1m\daniel'
        from = 'C:\Users\Danie\Dropbox\EEG_IOIO\COMPI\COMPI_paradigms';
        to = ['E:\' project_name '\data\'];
    case 'daniel-hp\daniel'
        from = 'C:\Users\Daniel\Dropbox\EEG_IOIO\COMPI\COMPI_paradigms';
        to = ['D:\' project_name '\data\'];
    case 'desktop-ctoao6k\compi'
        from = 'C:\Users\compi\Dropbox\EEG_IOIO\COMPI\COMPI_paradigms';
         to = ['D:\' project_name '\data\'];
end
cd(from);



%% Determine new files
ID = input('Please, tell me the participant''s ID, whose files you wish to copy: ' ,'s');
disp('Thank you!')
ID_verb = [project_name '_' ID];



%% Copy files
% Set tasks for subjects
if str2double(ID) < 51
    n_tasks = [1,2,3];
else
    n_tasks = [1,2,4];
end

% Copy!
for i_task = n_tasks
    try
        copyfile(fullfile(from,tasks{i_task},'behav_data',ID_verb,'*'),...
            fullfile(to,tasks{i_task},ID_verb,'behav','\'));
        mkdir(fullfile(to,tasks{i_task},ID_verb,'raw_EEG'));
    catch
        disp(['WARNING: No behavioral file for ' tasks{i_task} ' task!'])
    end
end
