function exp_MMN_pilots(subject, expTask)
%%EXP_MMN Program for MMN in EEG with opening central square
% This program can be run from the command line, specifying the subject's
% name (string of length 4) and the experimental task (0 = testing, 1 =
% task). If in testing mode, the sequence is shorter (it uses the training
% sequence) and the waitbuttondown in the beginning waits for keyboard
% input (instead of response box). 
%
% e.g.  >> exp_MMN_square('LAEW', 1)
%
% Alternatively, it can be run without parameters. In this case, data are
% saved to a file named 'COMPA_TEST_MMN_[current date].MAT'.


%% ---------------------- defaults ------------------------------------ %%
if nargin == 0   
    subject = 'TEST';       % test subject 
    expTask = 0;            % testing (-> experimenter wait button)
end

%% ---------------------- setting up session -------------------------- %%

% create unique name for saving results
datetime = datestr(now, 30);

if expTask == 1
    baseName = sprintf('COMPA_%s_MMN_task_%s', subject, datetime);%['COMPA_' subject '_MMN_' ...
%                 num2str(c(2)) '_' ...
%                 num2str(c(3)) '_' ...
%                 num2str(c(4)) '_' ...
%                 num2str(c(5))];
elseif expTask == 0
    baseName = sprintf('COMPA_%s_MMN_practice_%s', subject, datetime);%['COMPA_' subject '_MMN_testing_' ...
%                 num2str(c(2)) '_' ...
%                 num2str(c(3)) '_' ...
%                 num2str(c(4)) '_' ...
%                 num2str(c(5))];
end

% set file- and pathnames
expPath = 'D:\EXPERIMENTS\COMPA\MMN';
%tone1 = 'stimuli\200Hz_100ms_5msFadeInFadeOut.wav';
%tone2 = 'stimuli\500Hz_100ms_5msFadeInFadeOut.wav';
tone1 = 'stimuli\tone3_440Hz_100ms_5ms_fadeInOut.wav';
%tone2 = 'stimuli\tone1_500Hz_100ms_5ms_fadeInOut.wav';
%tone1 = 'stimuli\tone4_c1_264Hz_100ms_5ms_fadeInOut.wav';
tone2 = 'stimuli\tone5_c2_528Hz_100ms_5ms_fadeInOut.wav';
if expTask == 1
    desFile = 'design\designMatrix_pilots.mat';
elseif expTask == 0
    desFile = 'design\designMatrix_training_pilots.mat';
end

% construct the MMN structure
MMN.subjectID  = subject;
MMN.expTask    = expTask;

de = load(desFile);                                                         % load stimulus sequence
MMN.stimuli.audSequence = de.designMatrix(1, :);                            % tone sequence
MMN.stimuli.visSequence = de.designMatrix(4, :);                            % sequence of visual events
MMN.stimuli.visTypes = MMN.stimuli.visSequence(find(MMN.stimuli.visSequence));
MMN.stimuli.audTimes = [];                                                  % times of tones (from GetSecs)
MMN.stimuli.visTimes = [];                                                  % times of flips (from GetSecs)

MMN.times.visDuration = 200;
MMN.times.ISI = de.designMatrix(3, :);                                      % interstimulus intervals
MMN.times.SOT = de.designMatrix(5, :);                                      % stimulus presentation times (visual)
MMN.times.rest = de.designMatrix(6, :);                                     % time left per visual trial
MMN.times.end = 5000;                                                       % how long endtext is presented

MMN.triggers.initial = 98;
MMN.triggers.instructions = 99;
MMN.triggers.visual = 100;
MMN.triggers.tones = de.designMatrix(2, :);

KbName('UnifyKeyNames');
MMN.keys.escapeKey = KbName('ESCAPE');                                      % for escape by the experimenter


%% ---------------------- initializing -------------------------- %%

cd(expPath)
disp('This is the MMN-volatility experiment');

PsychDefaultSetup(2);
PsychImaging('PrepareConfiguration');

%Screen('Preference', 'SkipSyncTests', 2);                                   % disable sync checks (only for testing!!)
config_io;                                                                  % cogent function
address = hex2dec('A010'); %corrected on 6.3.2017 by SI                                                 % for setting eeg triggers
outp(address, MMN.triggers.initial);                                         
wait2(20);                                                                  % duration of the trigger
outp(address,0);

rtHandle = PsychRTBox('Open', [], 0);
PsychRTBox('SyncClocks', rtHandle);
PsychRTBox('Stop', rtHandle);
t = GetSecs;                                                                % to clear the buffer

%% ---------------------- set up screen -------------------------- %%

screens = Screen('Screens');                                                % get screen numbers
screenNumber = max(screens);                                                % draw to external screen

black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
gray = white/2;

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray, [], 32, 2,...
    [], [],  kPsychNeed32BPCFloat);     
Screen('Flip', window);

[screenXpixels, screenYpixels] = Screen('WindowSize', window);              % size of screen in pixels
[xCenter, yCenter] = RectCenter(windowRect);                                % center of screen in pixels

Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');  % set up alpha-blending for smooth (anti-aliased) lines

% Hide Cursor
HideCursor(screenNumber);
%% ---------------------- visual stimuli -------------------------- %%

% text (instructions)
instrSize = 30;
instrText = 'Geben Sie an, auf welcher Seite sich das Quadrat �ffnet. \n\n\n\nDr�cken Sie eine beliebige Taste um zu starten.';
abortText = 'Abbruch';
endText = 'Ende';

% fixation square
fixSize = 15;                                                               % size of square side in pixels
fixWidth = 2;
fixCol = white;
fixRect = [0 0 fixSize fixSize];
fixCoords = CenterRectOnPointd(fixRect, xCenter, yCenter);

% openings
openWidth = 5;
openCol = gray;
openDist = fixSize - fixWidth;
openLeftCoords = CenterRectOnPointd(fixRect, xCenter - openDist, yCenter);
openRightCoords = CenterRectOnPointd(fixRect, xCenter + openDist, yCenter);


%% ---------------------- auditory stimuli -------------------------- %%

% load tones
[y1, freq] = audioread(tone1);
[y2, freq] = audioread(tone2);

% setup tone 1
wavedata1 = y1';                                                            
nrchannels = size(wavedata1, 1);                                            % Number of rows == number of channels.
% stereo
if nrchannels < 2
    wavedata1 = [wavedata1; wavedata1];
end

% setup tone 2
wavedata2 = y2';
nrchannels = size(wavedata2, 1);                                            % Number of rows == number of channels.
% stereo
if nrchannels < 2
    wavedata2 = [wavedata2; wavedata2];
end

nrchannels = 2;

%% ---------------------- initialize sounds -------------------------- %%

% intialize sounds
InitializePsychSound('reallyneedlowlatency=1')
devices = PsychPortAudio('GetDevices', [], []);

% fill tone buffers
buffer = [];
buffer(end+1) = PsychPortAudio('CreateBuffer', [], wavedata1); 
buffer(end+1) = PsychPortAudio('CreateBuffer', [], wavedata2); 

% get handle and set to run mode
pahandle = PsychPortAudio('Open', 2, [], [], freq, nrchannels);
runMode = 1;
PsychPortAudio('RunMode', pahandle, runMode);

% fill playbuffer with content of buffer(2) (could be anything):
PsychPortAudio('FillBuffer', pahandle, buffer(2));


%% ---------------------- start presentation -------------------------- %%

nFlips = 0;

Screen('TextSize', window, instrSize);
MMN.startScreen = datestr(now, 30);
if expTask == 1
    PsychRTBox('Start', rtHandle, 0);
end

% instructions
DrawFormattedText(window, instrText, 'center', 'center', black);
Screen('Flip', window);

outp(address, MMN.triggers.instructions);                                   % tone actually starts 25ms later!!!      
wait2(5);                                                                   % duration of the trigger
outp(address,0);

if expTask == 1
    keyPress = [];
    while isempty(keyPress)
        [~, keyPress, ~] = PsychRTBox('GetSecs', rtHandle);
    end
elseif expTask == 0
    KbStrokeWait;
end

% start with center square
Screen('FrameRect', window, fixCol, fixCoords, fixWidth);
Screen('Flip', window);

if expTask == 0
    % start recording button presses
    PsychRTBox('Start', rtHandle);
end

% save start time of main loop
MMN.startLoop = datestr(now, 30);

% record time as baseline
MMN.stimuli.startSec = GetSecs;

%% ---------------------- loop over trials -------------------------- %%

for trial = 1:length(MMN.stimuli.audSequence)
        
    tone = MMN.stimuli.audSequence(trial);
    triggerCode = MMN.triggers.tones(trial);
    
    outp(address, triggerCode);
    wait2(5);
    outp(address, 0);
    
    PsychPortAudio('Start', pahandle, 1, 0, 0);
    PsychPortAudio('FillBuffer', pahandle, buffer(tone));
    MMN.stimuli.audTimes(trial) = GetSecs - MMN.stimuli.startSec;           % START sec of tone presentation
    
    if MMN.stimuli.visSequence(trial) ~= 0                                  % visual stimulus
        nFlips = nFlips + 1;
        wait2(MMN.times.SOT(trial));                                        % stimulus onset time
        
        % open the square
        if MMN.stimuli.visSequence(trial) == 1                              % open on the right
	    Screen('FrameRect', window, fixCol, fixCoords, fixWidth);
	    Screen('FrameRect', window, openCol, openRightCoords, openWidth);
            Screen('Flip', window);
            MMN.stimuli.visTimes(nFlips) = GetSecs - MMN.stimuli.startSec;
            outp(address, MMN.triggers.visual);                             % set the trigger
            wait2(5);
            outp(address, 0);
        elseif MMN.stimuli.visSequence(trial) == 2                          % open on the left
	    Screen('FrameRect', window, fixCol, fixCoords, fixWidth);
	    Screen('FrameRect', window, openCol, openLeftCoords, openWidth);
            Screen('Flip', window);
            MMN.stimuli.visTimes(nFlips) = GetSecs - MMN.stimuli.startSec;
            outp(address, MMN.triggers.visual);                             % set the trigger
            wait2(5);
            outp(address, 0);
        end
                
        % close square after stimulus duration
        wait2(MMN.times.visDuration - 5);
        Screen('FrameRect', window, fixCol, fixCoords, fixWidth);
        Screen('Flip', window);
        
        wait2(MMN.times.rest(trial) - 5);                                   % wait until ISI is over
    else
        wait2(MMN.times.ISI(trial));
    end
    
    [~, ~, keyCode] = KbCheck;
    if keyCode(MMN.keys.escapeKey)
        DrawFormattedText(window, abortText, 'center', 'center', black);
        Screen('Flip', window);
        PsychPortAudio('DeleteBuffer');
        PsychPortAudio('Close');
        PsychRTBox('CloseAll');
        sca;
        return;
    end
end

% save end time of main loop
MMN.stopLoop = datestr(now, 30);

%% ---------------------- goodbye -------------------------- %%

% good-bye screen
DrawFormattedText(window, endText, 'center', 'center', black);
Screen('Flip', window);

wait2(MMN.times.end);

%% ---------------------- response time calculation ------------------- %%

% save all responses
[ktime, key, btime] = PsychRTBox('GetSecs', rtHandle);
if ~isempty(ktime)
    MMN.responses.times = ktime;
    MMN.responses.keys = key;
    MMN.responses.boxTimes = btime;
else
    MMN.responses.times = NaN;
    MMN.responses.keys = NaN;
    MMN.responses.boxTimes = NaN;
end
PsychRTBox('Stop', rtHandle);

% remap button press times to getSecs times:
[MMN.responses.mapTimes, MMN.responses.errorTime] = ...
    PsychRTBox('BoxsecsToGetsecs', rtHandle, MMN.responses.boxTimes);

% put into same time frame as stimuli times:
MMN.responses.responseTimes = (MMN.responses.mapTimes - MMN.stimuli.startSec)';

% save all data in workspace
MMN.stopScreen = datestr(now, 30);
save(baseName, 'MMN');

%% ---------------------- shut down -------------------------- %%

% Wait for end of playback, then stop:
PsychPortAudio('Stop', pahandle, 1);

% Delete all dynamic audio buffers:
PsychPortAudio('DeleteBuffer');

% Close audio device, shutdown driver:
PsychPortAudio('Close');

% Clean up response box driver:
PsychRTBox('CloseAll');

% Close all screens
sca;

end

