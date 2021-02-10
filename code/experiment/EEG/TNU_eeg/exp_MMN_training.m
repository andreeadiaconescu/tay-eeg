function exp_MMN_training(subject, expTask)
%%EXP_MMN_TRAINING Program for MMN practice with opening square
% This program can be run from the command line, specifying the subject's
% name (string of length 4), and the experimental task (0 for testing, 1
% for a real subject):
%
% e.g.  >> exp_MMN_square_training('LAEW', 1)
%
% Alternatively, it can be run without parameters. In this case, data are
% saved to a file named 'COMPA_TEST_MMN_training_[current date].MAT'.


%% ---------------------- defaults ------------------------------------ %%
if nargin == 0   
    subject = 'TEST';   % test subject 
    expTask = 0;        % experimenter waitbutton    
end

%% ---------------------- setting up session -------------------------- %%

% create unique name for saving results
datetime = datestr(now, 30);
if expTask == 1
    baseName = sprintf('COMPA_%s_MMN_practice_%s', subject, datetime);
%     ['COMPA_' subject '_MMN_training' ...
%                 num2str(c(2)) '_' ...
%                 num2str(c(3)) '_' ...
%                 num2str(c(4)) '_' ...
%                 num2str(c(5))];
elseif expTask == 0
    baseName = sprintf('COMPA_%s_MMN_training_testing_%s', subject, datetime);
%     ['COMPA_' subject '_MMN_training_testing_' ...
%                 num2str(c(2)) '_' ...
%                 num2str(c(3)) '_' ...
%                 num2str(c(4)) '_' ...
%                 num2str(c(5))];
end

% set file- and pathnames
expPath = 'D:\EXPERIMENTS\COMPA\MMN';
desFile = 'design\designMatrix_training.mat';

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

KbName('UnifyKeyNames');
MMN.keys.escapeKey = KbName('ESCAPE');                                      % for escape by the experimenter


%% ---------------------- initializing -------------------------- %%

cd(expPath)
disp('This is the MMN-volatility experiment');

PsychDefaultSetup(2);
PsychImaging('PrepareConfiguration');

%Screen('Preference', 'SkipSyncTests', 1);                                   % disable sync checks (only for testing!!)
config_io;                                                                  % cogent function
address = hex2dec('A010');%corrected on 6.3.2017 by SI                                                  % for setting eeg triggers
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

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray);      % open a window with white background
Screen('Flip', window);

[screenXpixels, screenYpixels] = Screen('WindowSize', window);              % size of screen in pixels
[xCenter, yCenter] = RectCenter(windowRect);                                % center of screen in pixels

Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');  % set up alpha-blending for smooth (anti-aliased) lines

% Hide Cursor
HideCursor(screenNumber);
%% ---------------------- visual stimuli -------------------------- %%

% text (instructions)
instrSize = 30;
instrText = 'Geben Sie an, auf welcher Seite sich das Quadrat öffnet. \n\n\n\nDrücken Sie eine beliebige Taste, um die Übung zu starten.';
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

%% ---------------------- start presentation -------------------------- %%

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

for trial = 1: length(MMN.stimuli.audSequence)
    
    % instead of presenting a tone, wait for the tone duration plus trigger
    % duration:
    wait2(100);
    
    wait2(MMN.times.SOT(trial));                                            % stimulus onset time
    
    % draw new visual screens
    if MMN.stimuli.visSequence(trial) == 1                                  % open on the right
        Screen('FrameRect', window, fixCol, fixCoords, fixWidth);
        Screen('FrameRect', window, openCol, openRightCoords, openWidth);
        Screen('Flip', window);
        MMN.stimuli.visTimes(trial) = GetSecs - MMN.stimuli.startSec;
        outp(address, MMN.triggers.visual);                            % set the trigger
        wait2(5);
        outp(address, 0);
    elseif MMN.stimuli.visSequence(trial) == 2                              % open on the left
        Screen('FrameRect', window, fixCol, fixCoords, fixWidth);
        Screen('FrameRect', window, openCol, openLeftCoords, openWidth);
        Screen('Flip', window);
        MMN.stimuli.visTimes(trial) = GetSecs - MMN.stimuli.startSec;
        outp(address, MMN.triggers.visual);                             % set the trigger
        wait2(5);
        outp(address, 0);
    elseif MMN.stimuli.visSequence(trial) == 0                              % don't open, dummy flip
        Screen('FrameRect', window, fixCol, fixCoords, fixWidth);
        Screen('Flip', window);
        MMN.stimuli.visTimes(trial) = GetSecs - MMN.stimuli.startSec;
        wait2(5);
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

% Clean up response box driver:
PsychRTBox('CloseAll');

% Close all screens
sca;

end

