function exp_MMN_eeg(subject, hand, scanner_mode)
%%EXP_MMN_SCANNER Program for MMN in fMRI with opening central square
%
% This program can be run from the command line, specifying: 
% - the subject's name (string)
% - the handedness of the subject ('r' = right, 'l' = left)
%
% e.g.  >> exp_MMN_scanner('9999', 'r')
%
% Alternatively, it can be run without parameters. In this case, data are
% saved to a file named 'COMPASS_TEST_MMN_[current date].MAT'.
%
% This script works in the USZ if in scanner mode. For other
% locations/scanners, enter different port numbers for triggers.
%
% The program needs PsychToolBox and a folder with cogent. The script can
% be terminated by the experimenter by pressing the Escape key. 


%% ---------------------- defaults ------------------------------------ %%
if nargin == 0   
    subject = 'DH_test';    % test subject 
    hand = 'r';             % right-handed
    scanner_mode = 0;       % disable triggers if scanner_mode = 0
end


%% ---------------------- setting up session -------------------------- %%
addpath('stimuli', 'design', 'lib');
KbName('UnifyKeyNames');

session = setupSession(subject, hand, 'win', 'full', scanner_mode);
MMN = createMMN(session,scanner_mode);



%% ------------------------- initializing ----------------------------- %%

cd(session.expPath)
disp('This is the MMN-volatility experiment');

initializePsychToolBox;

%Initialize triggers
MMN.triggers.test = 99;
MMN.triggers.start = 1;
MMN.triggers.instructions = 4;
MMN.triggers.visualDummy = 128;
MMN.triggers.visualRight = 32;
MMN.triggers.visualLeft = 64;
MMN.triggers.tones = MMN.stimuli.audSequence; %%%% adjust triggers here

% Initialize parallel port
if scanner_mode == 3
    ioObj = io64;
    status = io64(ioObj);
    address = hex2dec('378');
    IPI = 4;
    io64(ioObj,address,MMN.triggers.initial);   %output command
    wait(IPI);
    io64(ioObj,address,0);
end

[screen] = setupScreen; 
visuals = createVisualStimuli(screen);

config_keyboard (5,1,'nonexclusive'); % Set up key board
initializeCogent(MMN);

audios = createAuditoryStimuli(session);
audios = initializeSounds(audios, MMN);


%% ---------------------- start presentation -------------------------- %%
% start screen
Screen('TextSize', visuals.window, visuals.instrSize);
MMN.startScreen = datestr(now, 30);
MMN.startScreen.GetSecs = GetSecs;

% instructions
DrawFormattedText(visuals.window, visuals.instrText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);

if scanner_mode == 3
    io64(ioObj,address,MMN.triggers.instructions);                               % tone actually starts 25ms later!!!
    wait(IPI);                                                                  % duration of the trigger
    io64(ioObj,address,0);
end

% wait for an experimenter button press
KbStrokeWait;

% save the starting time
MMN.startScan.GetSecs = GetSecs;
MMN.startScan.Serial = time; % this is cogent time

if scanner_mode == 3
    io64(ioObj,address,MMN.triggers.start);            
    wait(IPI);                                           
    io64(ioObj,address,0);
end

% start with center square
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('Flip', visuals.window);

% save start time of main loop
%MMN.startLoop.GetSecs = GetSecs - MMN.startScan.GetSecs;
MMN.stimuli.startSec = GetSecs - MMN.startScan.GetSecs;

%% ---------------------- main loop -------------------------- %%
%test_time = 150;

for trial = 1:length(MMN.stimuli.audSequence) - 1
  
    %tic
    nexttone = MMN.stimuli.audSequence(trial + 1);
    
    %send trigger
    if scanner_mode == 3
        io64(ioObj,address,MMN.triggers.tones(trial));
        wait(IPI);
        io64(ioObj,address, 0);
    end
    
    %Play tone
    MMN.stimuli.startTimes(trial) = PsychPortAudio('Start', audios.pahandle, 1, 0, 1); % tone of 1st trial is already in the buffer
    
    %record times
    MMN.stimuli.audTimes(trial) = GetSecs - MMN.startScan.GetSecs;           % START sec of tone presentation
    
    disp(MMN.stimuli.audTimes(trial))
    
    PsychPortAudio('FillBuffer', audios.pahandle, audios.buffer(nexttone));
     
    wait2(MMN.times.SOT(trial));                                            % stimulus onset time
    %wait2(150);
    %test_time(end+1) = toc*1000;
    %disp(['Discrepancy: ' num2str(test_time(end)-MMN.times.SOT(trial))])
   
    
    % draw new visual screens
    if MMN.stimuli.visSequence(trial) == 1                                  % open on the right
        Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
        Screen('FrameRect', visuals.window, visuals.openCol, visuals.openRightCoords, visuals.openWidth);
        Screen('Flip', visuals.window);
        MMN.stimuli.visTimes(trial) = GetSecs - MMN.stimuli.startSec;
        
        if scanner_mode == 3
            io64(ioObj,address,MMN.triggers.visualRight);                       % set the trigger
            wait(IPI);
            io64(ioObj,address, 0);
        end
        
    elseif MMN.stimuli.visSequence(trial) == 2                              % open on the left
        Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
        Screen('FrameRect', visuals.window, visuals.openCol, visuals.openLeftCoords, visuals.openWidth);
        Screen('Flip', visuals.window);
        MMN.stimuli.visTimes(trial) = GetSecs - MMN.stimuli.startSec;
        
        if scanner_mode == 3
            io64(ioObj,address,MMN.triggers.visualLeft);                       % set the trigger
            wait(IPI);
            io64(ioObj,address, 0);
        end
        
    elseif MMN.stimuli.visSequence(trial) == 0                              % don't open, dummy flip
        Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
        Screen('Flip', visuals.window);
        MMN.stimuli.visTimes(trial) = GetSecs - MMN.stimuli.startSec;
        
        if scanner_mode == 3
            io64(ioObj,address,MMN.triggers.visualDummy);                       % set the trigger
            wait(IPI);
            io64(ioObj,address, 0);
        end
    end
    
    % go back to closed square after stimulus duration
    wait2(MMN.times.visDuration - 5);
    Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
    Screen('Flip', visuals.window);

    wait2(MMN.times.rest(trial));                                           % wait until ISI is over
    
    [~, ~, keyCode] = KbCheck;
    if keyCode(MMN.keys.escapeKey)
        DrawFormattedText(visuals.window, visuals.abortText, 'center', 'center', screen.black);
        Screen('Flip', visuals.window);
        PsychPortAudio('DeleteBuffer');
        PsychPortAudio('Close');
        stop_cogent;
        sca;
        return;
    end
end

% save end time of main loop
MMN.stopLoop.GetSecs = GetSecs - MMN.startScan.GetSecs;

% please wait screen
DrawFormattedText(visuals.window, visuals.waitText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);

%% ------------- response times readout ----------------- %%
% correct start times
MMN.stimuli.startTimes = MMN.stimuli.startTimes - MMN.startScan.GetSecs;

% save all responses
readkeys; 
[responses, responseTimes] = getkeydown(MMN.scanner.boxport);
MMN.responses.times = responseTimes - MMN.startScan.Serial;
MMN.responses.keys = responses;

% security save at this point
save(session.baseName, 'MMN');


%% ------------- timing check ----------------- %%

% measure time once again, to compare
clearkeys;  

% please press button screen
DrawFormattedText(visuals.window, visuals.pressText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);

% wait for an experimenter button press
KbStrokeWait;

% save starting time
MMN.stopScreen.GetSecs = GetSecs;
MMN.stopScreen.Serial = time; % this is cogent time


%% ------------- goodbye ----------------- %%

% goodbye screen
DrawFormattedText(visuals.window, visuals.endText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);

% save all data in workspace
save(session.baseName, 'MMN');

%% ---------------------- shut down ------------------------ %%

% Wait for end of playback, then stop:
PsychPortAudio('Stop', audios.pahandle, 1);

% Delete all dynamic audio buffers:
PsychPortAudio('DeleteBuffer');

% Close audio device, shutdown driver:
PsychPortAudio('Close');

% Close all screens
sca;

% Stop cogent
stop_cogent;

end

