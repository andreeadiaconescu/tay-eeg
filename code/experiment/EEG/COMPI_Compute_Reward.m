clc
clear all

addpath('GUI')

reward = zeros(3, 1);
sbj = COMPI_Reward_GUI();

reward = zeros(4, 1);
% SRL
try
    SRLPath = sprintf('DATA/COMPA_%s/task/behav/srl/', sbj);
    SRLFile = dir(sprintf('%s/*_SOC_*.mat', SRLPath));
    load(sprintf('%s/%s', SRLPath, SRLFile(1).name));
    reward(1) = 10*SOC.Session(2).Payout; 
catch
    display('There seems to be an error in the calculation of the SRL reward...')
    reward(1) = 0;
end

    
% WM
try
    WMPath = sprintf('DATA/COMPA_%s/', sbj);
    WMFile = dir(sprintf('%s/*WM_task_exp*.mat', WMPath));
    load(sprintf('%s/%s', WMPath, WMFile(1).name));
    WMFile = dir(sprintf('%s/*WM_task_pars*.mat', WMPath));
    load(sprintf('%s/%s', WMPath, WMFile(1).name));
    addpath(genpath('WM'));
    reward(2) = computeWMReward(dpars, dexp);
catch
    disp('There seems to be an error in the calculation of the WM reward...')
    reward(2) = 0;
end

% MMN
try
    MMNPath = sprintf('DATA/COMPA_%s/', sbj);
    MMNFile = dir(sprintf('%s/*MMN_task*.mat', MMNPath));
    load(sprintf('%s/%s', MMNPath, MMNFile(1).name));
    addpath('MMN')
    reward(3) = mmn_calculate_performance(MMN);
catch
    disp('There seems to be an error in the calculation of the MMN reward...')
    reward(3) = 0;
end

reward = round(reward * 10) / 10;

reward(4) = sum(reward(1:3));


COMPA_Reward_GUI(reward)


