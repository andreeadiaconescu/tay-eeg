function loop_tayeeg_subject_analysis( options )
%LOOP_TAYEEG_SUBJECT_ANALYSIS Loops over all subjects in the TAYEEG study 
% and executes all analysis steps
%   IN:     options     - the struct that holds all analysis options
%   OUT:    -

if nargin < 1 
    options = tayeeg_analysis_options;
end

for idCell = options.subjectIDs
    id = char(idCell);
    tayeeg_mmn_analyze_subject(id, options);   
end
