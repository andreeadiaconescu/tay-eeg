function loop_compi_mmn_subject_analysis( options )
%LOOP_MMN_SUBJECT_ANALYSIS Loops over all subjects in the COMPI study and executes all analysis 
%steps
%   IN:     options     - the struct that holds all analysis options
%   OUT:    -

if nargin < 1 
    options = compi_ioio_options;
end

options.subjectIDs = {'0101'};
for idCell = options.subjectIDs
    id = char(idCell);
    
    compi_mmn_analyze_subject(id, options);
    
end
