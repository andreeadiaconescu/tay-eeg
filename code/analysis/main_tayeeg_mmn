% --- Analysis script for MMN volatility EEG dataset --- %

% set up Matlab environment
compi_setup_paths();

% set all analysis options and provide the path to the data
options = compi_ioio_options('HGF_v1',[2 1 4 2 1 1 1 1 2],'Default','mmn');

% create the folder structure needed for the full analysis, and fill with necessary raw data
compi_mmn_setup_analysis_folder(options);

% run the full first-level analysis
% includes: data preparation, EEG preprocessing, ERPs, conversion to images, 1st level statistics
loop_compi_mmn_subject_analysis(options); 

% summarize quality of preprocessing and trial statistics
loop_mnket_quality_check(options);

% run second level steps for model-based analysis and report the results
mnket_2ndlevel_modelbased;
mnket_results_report_modelbased;

% collect all results reported in the paper into a separate folder
mnket_pull_paper_data(options);

% not needed for paper:
%mnket_2ndlevel_erpbased;
%mnket_results_report_erpbased;