function exp_MMN_scanner_short(subject, hand)
%%EXP_MMN_SCANNER_SHORT Program for MMN in fMRI with opening central square
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
    subject = 'TEST';       % test subject 
    hand = 'r';             % right-handed
end

%% ---------------------- setting up session -------------------------- %%

addpath('stimuli', 'design', 'lib');
KbName('UnifyKeyNames');

session = setupSession(subject, hand, 'win', 'short');
MMN = createMMN(session);


%% ------------------------- initializing ----------------------------- %%

cd(session.expPath)
disp('This is the MMN-volatility experiment');

initializePsychToolBox;
initializeCogent(MMN);

[screen] = setupScreen; 
visuals = createVisualStimuli(screen);

audios = createAuditoryStimuli(session);
audios = initializeSounds(audios, MMN);


%% ---------------------- start presentation -------------------------- %%

Screen('TextSize', visuals.window, visuals.instrSize);
MMN.startScreen = datestr(now, 30);

% instructions
DrawFormattedText(visuals.window, visuals.instrText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);

% wait for the scanner and save the starting time
[~, t] = waitserialbyte(MMN.scanner.boxport, inf, MMN.scanner.trigger);
MMN.startScan.GetSecs = GetSecs;
MMN.startScan.Serial = t(1);
clearserialbytes(MMN.scanner.boxport);

% start with center square
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('Flip', visuals.window);

% save start time of main loop
MMN.startLoop.GetSecs = GetSecs - MMN.startScan.GetSecs;

%% ---------------------- main loop -------------------------- %%

for trial = 1: length(MMN.stimuli.audSequence) - 1
        
    nexttone = MMN.stimuli.audSequence(trial + 1);
    
    MMN.stimuli.startTimes(trial) = PsychPortAudio('Start', audios.pahandle, 1, 0, 1); % tone of 1st trial is already in the buffer
    MMN.stimuli.audTimes(trial) = GetSecs - MMN.startScan.GetSecs;           % START sec of tone presentation
    
    PsychPortAudio('FillBuffer', audios.pahandle, audios.buffer(nexttone));
    
    wait2(MMN.times.SOT(trial));                                            % stimulus onset time
    MMN = drawVisualTrial(MMN, trial, visuals);

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
readserialbytes(MMN.scanner.boxport);
[responses, responseTimes] = getserialbytes(MMN.scanner.boxport);
MMN.responses.times = responseTimes - MMN.startScan.Serial;
MMN.responses.keys = responses;

% security save at this point
save(session.baseName, 'MMN');


%% ------------- timing check ----------------- %%

% measure time once again, to compare
clearserialbytes(MMN.scanner.boxport);

% please press button screen
DrawFormattedText(visuals.window, visuals.pressText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);

[~, t] = waitserialbyte(MMN.scanner.boxport, inf);
MMN.stopScreen.GetSecs = GetSecs;
MMN.stopScreen.Serial = t(1);


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

