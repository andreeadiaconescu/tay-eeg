function jg_COMPI_Rest_DH_voice_instructions(subject,scanner_mode)

%% Defaults
if nargin < 1
    scanner_mode =  0;
    subject = 'DH_test2';
    window_mode = 0;
else
    window_mode = 1;
end



%% Intialize EEG triggers if necessary
if scanner_mode == 3
    ioObj = io64;
    status = io64(ioObj);
    address = hex2dec('378');
    IPI = 4;
    io64(ioObj,address,6); wait(IPI); io64(ioObj,address,0); %output command
end


%% Set paths
project_name  = 'COMPI';
data_path     = fullfile(cd, 'behav_data', [project_name '_' subject]);


%% Create subject_folder
if exist(data_path)~=7             % check whether subject folder exists
    mkdir(data_path);              % create new subject folder
    
elseif ~strcmp(subject,'DH_test') 
    
    u_resp = input('File for this subject exists already! Continue? [y/n]:','s');
    if strcmp(u_resp,'y')
        disp('Continuing...');
        return;
    else
        disp('Aborting...');
        clear all; return;      % if file exists: abort
    end
end


%% Initialize behavioral data file
rest_data = struct;
rest_data.subject = subject;
rest_data.data = zeros(10,3);
rest_data.data_desc = {'abs t','cor t','Cond. Change (1 = close, 2 = open)'};


%% Load auditory stimuli
%[y1, freq] = audioread('C:\Users\Danie\Dropbox\EEG_IOIO\COMPI\COMPI_paradigms\Rest\eyes_open_ger.wav');
%[y2, freq] = audioread('C:\Users\Danie\Dropbox\EEG_IOIO\COMPI\COMPI_paradigms\Rest\eyes_close_ger.wav');

[y1, freq] = audioread('eyes_open_ger.wav')
[y2, freq] = audioread('eyes_close_ger.wav');


wavedata1 = y1';
nrchannels = size(wavedata1,1); % Number of rows == number of channels.

if nrchannels < 2
    wavedata1 = [wavedata1 ; wavedata1];
    nrchannels = 2;
end

wavedata2 = y2';
nrchannels = size(wavedata2,1); % Number of rows == number of channels.

if nrchannels < 2
    wavedata2 = [wavedata2 ; wavedata2];
    nrchannels = 2;
end


%% Initialize sound buffer
InitializePsychSound('reallyneedlowlatency=1')
devices = PsychPortAudio('GetDevices', [], []);

buffer = [];
buffer(end+1) = PsychPortAudio('CreateBuffer', [], wavedata1);
buffer(end+1) = PsychPortAudio('CreateBuffer', [], wavedata2);

pahandle = PsychPortAudio('Open', [], [], 1, freq, nrchannels);
PsychPortAudio('RunMode', pahandle, 1);

% Fill playbuffer with content of buffer(1):
PsychPortAudio('FillBuffer', pahandle, buffer(2));


%% Set up screen
Screen('Preference', 'SkipSyncTests', 1) %disable synchronization test (unrecommendated)
screens = Screen('Screens');                                                % get screen numbers
screenNumber = max(screens);                                                % draw to external screen

black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
gray = white/2;

% Window mode
if window_mode == 1
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray, [], 32, 2,...
        [], [],  kPsychNeed32BPCFloat);
elseif window_mode == 0
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray, [0 0 800 600], 32, 2,...
        [], [],  kPsychNeed32BPCFloat);
end

Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');  % set up alpha-blending for smooth (anti-aliased) lines
Screen('Flip', window);
[xCenter, yCenter] = RectCenter(windowRect);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
HideCursor(screenNumber);


%% Configure key board
config_keyboard (5,1,'nonexclusive'); % Set up key board
start_cogent;


%% Instruction screen
start_text = sprintf(['Willkommen zum ersten Experiment.\n\n\n',...
    'Bitte schliessen Sie ihre Augen, wenn Sie \n\n',...
    'ueber die Kopfhoerer ''Augen schliessen'' hoeren \n\n',...
    'und halten Sie Ihre Augen geschlossen \n\n',...
    'bis Sie ''Augen oeffnen'' hoeren. \n\n',...
    'Wenn Sie ihre Augen geoeffnet haben, \n\n',...
    'fixieren Sie bitte, das Kreuz in der \n\n',...
    'Mitte des Bildschirms. \n\n\n\n',...
    'Druecken Sie eine beliebige Taste, um fortzufahren']);

DrawFormattedText(window, start_text, 'center', 'center', black);
Screen('Flip', window);
waitkeydown(inf);

%% Wait to start screen
switch scanner_mode
    case {0,3}
        start_text = 'Druecken Sie eine beliebige Taste um zu starten.';
    case 1
        start_text = 'Bitte warten Sie bis das Experiment beginnt.';
end
DrawFormattedText(window, start_text, 'center', 'center', black);
Screen('Flip', window);


%% Get start trigger
switch scanner_mode
    case 0 % behavior
        waitkeydown(inf);
        rest_data.when_start = GetSecs;
    case 1 % fMRI
        waitkeydown(inf,32); %scanner trigger is 32
        rest_data.when_start = GetSecs;
    case 3 % EEG
        waitkeydown(inf);
        rest_data.when_start = GetSecs;
        
        % TRIGGER start experiment
        io64(ioObj,address,1);   %output command
        wait(IPI);
        io64(ioObj,address,0);
end


%% Draw fixation cross
fixCross = struct();
fixCross.lineWidth = 6;
fixCross.size = 0.02 * screenYpixels;
fixCross.color = black;
fixCross.position = [-fixCross.size fixCross.size 0 0;...
    0 0 -fixCross.size fixCross.size];
fixCross.center = [xCenter, yCenter];

% Draw the Fixation Cross to the screen
Screen('DrawLines', window, fixCross.position,...
    fixCross.lineWidth, fixCross.color(1, :), ...
    fixCross.center, 2);
Screen('Flip', window);
wait2(5000);


%% Trial Loop
change_idx = 1;

for i = 1:5 
    for b = 1:2
        
        % Save condition change time
        rest_data.data(change_idx,1) = GetSecs;
        rest_data.data(change_idx,2) = GetSecs - rest_data.when_start;
        rest_data.data(change_idx,3) = b;
        
        % EEG TRIGGER condition change
        if scanner_mode == 3
            io64(ioObj,address,2);   %output command
            wait(IPI);
            io64(ioObj,address,0);
        end
        
        PsychPortAudio('Start', pahandle, 1, 0, 0);
        PsychPortAudio('FillBuffer', pahandle, buffer(b));
        
        switch b
            case 1 %low tone => close eyes
                wait2(120000); 
            case 2 %high tone => open eyes
                wait2(10000);
        end
        change_idx = change_idx +1;
    end
end

%% Save data
switch scanner_mode
    case 0 
        mode_id = 'debug';
    case 1
        mode_id = 'fMRI';
    case 3
        mode_id = 'EEG';
end


save(fullfile(data_path,[project_name '_' subject '_' mode_id '_rest.mat']),'rest_data');


%% End screen 
endText = 'Geschafft!';
DrawFormattedText(window, endText, 'center', 'center', black);
Screen('Flip', window);

%% Clean up
% Wait for end of playback, then stop:
PsychPortAudio('Stop', pahandle, 1);
% Delete all dynamic audio buffers:
PsychPortAudio('DeleteBuffer');
% Close audio device, shutdown driver:
PsychPortAudio('Close');
stop_cogent;

wait2(5000)
sca
close all
clear all
