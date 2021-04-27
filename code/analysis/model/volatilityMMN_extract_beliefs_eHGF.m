function [lowPETrialsAll, highPETrialsAll,trajectoryEpsilon2,trajectoryEpsilon3] = volatilityMMN_extract_beliefs_eHGF(inputValues)
inputValues = inputValues';
mode = 'bayesSurprise';

u = inputValues;
bopars = tapas_fitModel([],...
    u,...
    'tapas_ehgf_binary_config',...
    'tapas_bayes_optimal_binary_config',...
    'tapas_quasinewton_optim_config');

tapas_hgf_binary_plotTraj(bopars);
epsilon2 = [0; bopars.traj.epsi(:,2)];

[lowIdcs,highIdcs,trajectoryEpsilon2] = volatilityMMN_PE(epsilon2,mode);

peTrials = zeros(size(u));
peTrials(lowIdcs) = 1;
peTrials(highIdcs) = 2;

lowPETrialsAll = peTrials;

mode = 'volatilityPE';

bopars = tapas_fitModel([],...
    u,...
    'tapas_ehgf_binary_config',...
    'tapas_bayes_optimal_binary_config',...
    'tapas_quasinewton_optim_config');
epsilon3 = [0; bopars.traj.epsi(:,3)];
[lowIdcs_highPE,highIdcs_highPE,trajectoryEpsilon3] = volatilityMMN_PE(epsilon3,mode);

highpeTrials = zeros(size(u));
highpeTrials(lowIdcs_highPE) = 1;
highpeTrials(highIdcs_highPE) = 2;

highPETrialsAll = highpeTrials;

end