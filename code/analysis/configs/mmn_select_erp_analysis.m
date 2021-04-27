function erp_select = mmn_select_erp_analysis(options)
switch options.eeg.erp.type 
    case 'roving'
        erp_select.conditions = {'standard', 'deviant'};
    case {'phases_oddball', 'phases_roving'}
        erp_select.conditions = {'volDev', 'stabDev', ...
            'volStan', 'stabStan'};
    case 'epsilon'
        erp_select.conditions = {'lowPE','highPE'};
end
erp_select.electrode   = 'Fz';
erp_select.averaging   = 'robust'; % s (standard), r (robust)
switch erp_select.averaging
    case 'robust'
        erp_select.addfilter = 'f';
    case 'standard'
        erp_select.addfilter = '';
end
erp_select.contrastWeighting   = 1;
erp_select.contrastPrefix      = 'diff_';
erp_select.contrastName        = 'mmn';
erp_select.percentPe           = 15;
erp_select.type                = options.eeg.erp.type;
end