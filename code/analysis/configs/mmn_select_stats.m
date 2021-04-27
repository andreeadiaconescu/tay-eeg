function select_stats = mmn_select_stats(options)

select_stats.mode          = 'ERP';        % 'modelbased', 'ERP'
select_stats.priors        = 'volTrace';   % omega35, default, mypriors,
switch options.eeg.stats.design
    case 'epsilon'
        select_stats.regressors = {'epsi2', 'epsi3'};
    case 'PEs'
        select_stats.regressors = {'delta1', 'delta2'};
    case 'posteriors'
        select_stats.regressors = {'mu2', 'mu3'};
    case 'precisions'
        select_stats.regressors = {'pi1', 'pi2','pi3'};
end
select_stats.pValueMode    = 'clusterFWE';
select_stats.exampleID     = '0001';
select_stats.design        = options.eeg.stats.design;
end