function [lowPETrialsAll, highPETrialsAll,trajectoryEpsilon2,trajectoryEpsilon3,...
    predictionProb,precision,informationalUncertainty,volatilityUncertainty,predictionVol, delta1, delta2, delta3] = ...
    mmn_volatilityMMN_extract_beliefs_eHGF(inputValues,details)

inputValues = inputValues';
mode = 'bayesSurprise';

u = inputValues;
bopars = tapas_fitModel([],...
    u,...
    'tapas_ehgf_binary_config',...
    'tapas_bayes_optimal_binary_config',...
    'tapas_quasinewton_optim_config');

% Set up display
scrsz = get(0,'screenSize');
outerpos = [0.2*scrsz(3),0.2*scrsz(4),0.8*scrsz(3),0.8*scrsz(4)];
fh = figure(...
    'OuterPosition', outerpos,...
    'Name', 'HGF trajectories');
tapas_hgf_binary_plotTraj(bopars);
savefig(fh, details.model.modelfig);
close(fh);
predictionProb            = bopars.traj.mu(:,2);
precision                 = 1./bopars.traj.sahat(:,1);
informationalUncertainty  = tapas_sgm(bopars.traj.muhat(:,2), 1).*(1 -tapas_sgm(bopars.traj.muhat(:,2), 1)).*bopars.traj.sahat(:,2);
volatilityUncertainty     = tapas_sgm(bopars.traj.muhat(:,2), 1).*(1-tapas_sgm(bopars.traj.muhat(:,2), 1)).*exp(bopars.traj.muhat(:,3));
predictionVol             = bopars.traj.mu(:,3);

epsilon2                  = abs(bopars.traj.epsi(:,2));

delta1                    = abs(bopars.traj.da(:,1));
delta2                    = bopars.traj.da(:,2);
delta3                    = bopars.traj.da(:,3);

[lowIdcs,highIdcs,trajectoryEpsilon2] = mmn_volatilityMMN_PE(epsilon2,mode);

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

epsilon3                  = bopars.traj.epsi(:,3);
[lowIdcs_highPE,highIdcs_highPE,trajectoryEpsilon3] = mmn_volatilityMMN_PE(epsilon3,mode);

highpeTrials = zeros(size(u));
highpeTrials(lowIdcs_highPE) = 1;
highpeTrials(highIdcs_highPE) = 2;

highPETrialsAll = highpeTrials;

end