function exp_MMN(subject, expTask)
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
    baseName = sprintf('COMPA_%s_MMN_task_%s', subject, datetime);
elseif expTask == 0
    baseName = sprintf('COMPA_%s_MMN_test_%s', subject, datetime);
end

% set file- and pathnames
expPath = 'Users/drea/Dropbox/EXPERIMENTS/COMPA/MMN';
tone1 = 'stimuli/tone3_440Hz_70ms_5ms_fadeInOut_-12.wav';
tone2 = 'stimuli/tone5_528Hz_70ms_5ms_fadeInOut_-12.wav';

if expTask == 1
    desFile = 'design/designMatrix.mat';
elseif expTask == 0
    desFile = 'design/designMatrix_test.mat';
end

% construct the MMN structure
MMN.subjectID  = subject;
MMN.expTask    = expTask;

de = load(desFile);                                                         % load stimulus sequence
MMN.stimuli.audSequence = de.designMatrix(1, :);                            % tone sequence
MMN.stimuli.audSequence = [MMN.stimuli.audSequence 1];                      % add dummy tone for loop
MMN.stimuli.visSequence = de.designMatrix(4, :);                            % sequence of visual events
MMN.stimuli.visTypes = MMN.stimuli.visSequence(find(MMN.stimuli.visSequence));
MMN.stimuli.audTimes = [];                                                  % times of tones (from GetSecs)
MMN.stimuli.visTimes = [];                                                  % times of flips (from GetSecs)
%MMN.stimuli.filltimes = [];

MMN.times.visDuration = 200;
MMN.times.audDuration = 70;
MMN.times.ISI = de.designMatrix(3, :);                                      % interstimulus intervals
MMN.times.SOT = de.designMatrix(5, :);                                      % stimulus presentation times (visual)
MMN.times.rest = de.designMatrix(6, :);                                     % time left per visual trial
MMN.times.end = 5000;                                                       % how long endtext is presented

%%%%%%
MMN.triggers.initial = 2^0;
MMN.triggers.instructions = 2^2;
MMN.triggers.visualDummy = 2^3;
MMN.triggers.visualRight = 2^4;
MMN.triggers.visualLeft = 2^5;
MMN.triggers.tones = de.designMatrix(2, :); %%%% adjust triggers here
%%%%%%

KbName('UnifyKeyNames');
MMN.keys.escapeKey = KbName('ESCAPE');                                      % for escape by the experimenter


%% ---------------------- initializing -------------------------- %%

cd(expPath)
disp('This is the MMN-volatility experiment');

PsychDefaultSetup(2);
PsychImaging('PrepareConfiguration');
initializeCogent(MMN);

ioObj = io64;
address = hex2dec('378');  % for setting eeg triggers
IPI = 20;                  % duration of the trigger
io64(ioObj,address,MMN.triggers.initial);   %output command
wait2(IPI);
io64(ioObj,address,0);
                                                          

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
instrText = 'Geben Sie an, auf welcher Seite sich das Quadrat ?ffnet. /n/n/n/nDr?cken Sie eine beliebige Taste um zu starten.';
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
pahandle = PsychPortAudio('Open', [], [], 1, freq, nrchannels);
runMode = 1;
PsychPortAudio('RunMode', pahandle, runMode);

% fill playbuffer with tone of first trial:
PsychPortAudio('FillBuffer', pahandle, buffer(MMN.stimuli.audSequence(1)));


%% ---------------------- start presentation -------------------------- %%

Screen('TextSize', window, instrSize);
MMN.startScreen = datestr(now, 30);
%%%%%%
if expTask == 1
    readkeys;    % this command retrieves all keyboard events
end
%%%%%%

% instructions
DrawFormattedText(window, instrText, 'center', 'center', black);
Screen('Flip', window);

io64(ioObj,address,MMN.triggers.instructions);                               % tone actually starts 25ms later!!!
wait2(IPI);                                                                  % duration of the trigger
io64(ioObj,address,0);

% wait for an experimenter button press
KbStrokeWait;

% save starting time
MMN.startScan.GetSecs = GetSecs;
MMN.startScan.Serial = time; % this is cogent time


% start with center square
Screen('FrameRect', window, fixCol, fixCoords, fixWidth);
Screen('Flip', window);

%%%%
if expTask == 0
    % start recording button presses
    PsychRTBox('Start', rtHandle);
end
%%%%%%%

% save start time of main loop
MMN.startLoop = datestr(now, 30);

% record time as baseline
MMN.stimuli.startSec = GetSecs;

%% ---------------------- loop over trials -------------------------- %%

for trial = 1: length(MMN.stimuli.audSequence) - 1
    
    triggerCode = MMN.triggers.tones(trial);
    nexttone = MMN.stimuli.audSequence(trial + 1);
    
    %%%%%
    io64(ioObj,address,triggerCode);
    wait2(IPI);
    io64(ioObj,address, 0);
    %%%%%
    
    MMN.stimuli.startTimes(trial) = PsychPortAudio('Start', pahandle, 1, 0, 1); % tone of 1st trial is already in the buffer
    MMN.stimuli.audTimes(trial) = GetSecs - MMN.stimuli.startSec;           % START sec of tone presentation
    
    PsychPortAudio('FillBuffer', pahandle, buffer(nexttone));
    %MMN.stimuli.fillTimes(trial) = GetSecs - MMN.stimuli.startSec;
    % time it took to fill the buffer (i.e., to send out the tone)
    
    wait2(MMN.times.SOT(trial));                                            % stimulus onset time
    
    % draw new visual screens
    if MMN.stimuli.visSequence(trial) == 1                                  % open on the right
        Screen('FrameRect', window, fixCol, fixCoords, fixWidth);
        Screen('FrameRect', window, openCol, openRightCoords, openWidth);
        Screen('Flip', window);
        MMN.stimuli.visTimes(trial) = GetSecs - MMN.stimuli.startSec;
        io64(ioObj,address,MMN.triggers.visualRight);                       % set the trigger
        wait2(IPI);
        io64(ioObj,address, 0);
    elseif MMN.stimuli.visSequence(trial) == 2                              % open on the left
        Screen('FrameRect', window, fixCol, fixCoords, fixWidth);
        Screen('FrameRect', window, openCol, openLeftCoords, openWidth);
        Screen('Flip', window);
        MMN.stimuli.visTimes(trial) = GetSecs - MMN.stimuli.startSec;
        outp(address, MMN.triggers.visualLeft);                             % set the trigger
        wait2(5);
        outp(address, 0);
    elseif MMN.stimuli.visSequence(trial) == 0                              % don't open, dummy flip
        Screen('FrameRect', window, fixCol, fixCoords, fixWidth);
        Screen('Flip', window);
        MMN.stimuli.visTimes(trial) = GetSecs - MMN.stimuli.startSec;
        outp(address, MMN.triggers.visualDummy);                            % set the trigger
        wait2(5);
        outp(address, 0);
    end
    
    % go back to closed square after stimulus duration
    wait2(MMN.times.visDuration - 5);
    Screen('FrameRect', window, fixCol, fixCoords, fixWidth);
    Screen('Flip', window);
    
    wait2(MMN.times.rest(trial) - 5);                                       % wait until ISI is over
    
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

% correct start times
MMN.stimuli.startTimes = MMN.stimuli.startTimes - MMN.stimuli.startSec;

% save all responses
%%%%%%%
[ktime, key, btime] = PsychRTBox('GetSecs', rtHandle);
if ~isempty(ktime)
    MMN.responses.times = ktime;
    MMN.responses.keys = key;
    MMN.responses.boxTimes = btime;
else
    warning('no responses recorded!');
    MMN.responses.times = NaN;
    MMN.responses.keys = NaN;
    MMN.responses.boxTimes = NaN;
end
PsychRTBox('Stop', rtHandle);
%%%%%%%%

% security save (in case remapping doesn't work)
save(baseName, 'MMN');

% remap button press times to getSecs times:
if ~isnan(MMN.responses.boxTimes)
    try
        [MMN.responses.mapTimes, MMN.responses.errorTime] = ...
            PsychRTBox('BoxsecsToGetsecs', rtHandle, MMN.responses.boxTimes);
        
        % put into same time frame as stimuli times:
        MMN.responses.responseTimes = (MMN.responses.mapTimes - MMN.stimuli.startSec)';
    catch
        warning('remapping of response times did not work')
        MMN.responses.responseTimes = NaN;
    end
else
    warning('no response times!');
    MMN.responses.responseTimes = NaN;
end

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

