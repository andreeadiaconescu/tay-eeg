% --- Analysis script for MMN volatility EEG dataset --- %

% set up Matlab environment
tayeeg_setup_paths();

% set all analysis options and provide the path to the data
options = tayeeg_analysis_options();

% create the folder structure needed for the full analysis, and fill with necessary raw data
tayeeg_mmn_setup_analysis_folder(options);

% run the full first-level analysis
% includes: data preparation, EEG preprocessing, ERPs, conversion to images, 1st level statistics
loop_tayeeg_subject_analysis(options); 

% summarize quality of preprocessing and trial statistics
loop_tayeeg_quality_check(options);