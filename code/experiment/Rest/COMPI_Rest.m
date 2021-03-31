%% Alternating auditory instructions to aid spontaneous EEG recording
% by Gabor Stefanics
function COMPI_Rest(scanner_mode)

%% Defaults
if nargin < 1
    scanner_mode = 0;
end



%% Intialize EEG triggers if necessary
if scanner_mode == 3 && ~debug
    ioObj = io64;
    status = io64(ioObj);
    address = hex2dec('378');
    IPI = 0.01;
    io64(ioObj,address,6); wait(IPI); io64(ioObj,address,0); %output command
end


%% Load auditory stimuli
%config_io;
%address = hex2dec('A010');%corrected on 6.3.2017 by SI
[y1, freq] = audioread('C:\Users\Danie\Dropbox\EEG_IOIO\paradigms\Rest\open3.wav');
[y2, freq] = audioread('C:\Users\Danie\Dropbox\EEG_IOIO\paradigms\Rest\close3.wav');

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

runMode = 1;
PsychPortAudio('RunMode', pahandle, runMode);

% Fill playbuffer with content of buffer(1):
PsychPortAudio('FillBuffer', pahandle, buffer(2));


%% ---------------------- set up screen -------------------------- %%
Screen('Preference', 'SkipSyncTests', 1) %disable synchronization test (unrecommendated)
screens = Screen('Screens');                                                % get screen numbers
screenNumber = max(screens);                                                % draw to external screen

black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
gray = white/2;

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray, [], 32, 2,...
    [], [],  kPsychNeed32BPCFloat);   
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');  % set up alpha-blending for smooth (anti-aliased) lines
Screen('Flip', window);
[xCenter, yCenter] = RectCenter(windowRect);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
HideCursor(screenNumber);


%% Configure key board
config_keyboard (5,1,'nonexclusive'); % Set up key board
start_cogent;


%% Start screen
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
        [~,t] = waitkeydown(inf);
    case 1 % fMRI
        [~,t] = waitkeydown(inf,32); %scanner trigger is 32
    case 3 % EEG
        [~,t] = waitkeydown(inf);
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



%%
for i = 1:10    
    for b = 1:2
        %         tic
        
        % EEG TRIGGER condition change
        if scanner_mode == 3
            io64(ioObj,address,2);   %output command
            wait(IPI);
            io64(ioObj,address,0);
        end
        %outp(address, b);  wait2(5); outp(address, 0);
        PsychPortAudio('Start', pahandle, 1, 0, 0);
        %         toc

        %         tic
        PsychPortAudio('FillBuffer', pahandle, buffer(b));
        %         toc
        wait2(20000);
    end
    
end

endText = 'Geschafft!';

DrawFormattedText(window, endText, 'center', 'center', black);
Screen('Flip', window);
% Wait for end of playback, then stop:
PsychPortAudio('Stop', pahandle, 1);

% Delete all dynamic audio buffers:
PsychPortAudio('DeleteBuffer');

% Close audio device, shutdown driver:
PsychPortAudio('Close');

wait2(5000)

sca
close all
