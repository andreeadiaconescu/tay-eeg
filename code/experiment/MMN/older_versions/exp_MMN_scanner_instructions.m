function exp_MMN_scanner_instructions(subject, hand)
%%EXP_MMN_SCANNER_INSTRUCTIONS Program for MMN instructions in fMRI with opening central square
%
% This program can be run from the command line, specifying: 
% - the subject's name (string)
% - the handedness of the subject ('r' = right, 'l' = left)
%
% e.g.  >> exp_MMN_scanner_instructions('9999', 'r')
%
% Alternatively, it can be run without parameters. In this case, data are
% saved to a file named 'PRSSI_TEST_MMN_instructions_[current date].MAT'.
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

session = setupSession(subject, hand, 'win', 'instructions');
MMN = createMMN(session);


%% ------------------------- initializing ----------------------------- %%

cd(session.expPath)
disp('This is the MMN-volatility experiment');
disp(['Instructions and Training for Subject ' subject]);

initializePsychToolBox;
initializeCogent(MMN);

[screen] = setupScreen; 
visuals = createVisualStimuli(screen);

audios = createAuditoryStimuli(session);
audios = initializeSounds(audios, MMN);


%% ---------------------- start presentation -------------------------- %%

Screen('TextSize', visuals.window, visuals.instrSize);
MMN.startScreen = datestr(now, 30);

% welcome screen
DrawFormattedText(visuals.window, visuals.training00, 'center', 'center', screen.black);
DrawFormattedText(visuals.window, visuals.trainingStart, 'center', 1000, screen.black);
Screen('Flip', visuals.window);
wait2(2000);

% wait for the scanner and save the starting time
[~, t] = waitserialbyte(MMN.scanner.boxport, inf, MMN.scanner.trigger);
MMN.startScan.GetSecs = GetSecs;
MMN.startScan.Serial = t(1);
clearserialbytes(MMN.scanner.boxport);


%% ---------------------- instructions -------------------------- %%

% present the center square
DrawFormattedText(visuals.window, visuals.training01, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
DrawFormattedText(visuals.window, visuals.trainingContinue, 'center', 1000, screen.black);
Screen('Flip', visuals.window);
[~, ~] = waitserialbyte(MMN.scanner.boxport, inf);
clearserialbytes(MMN.scanner.boxport);

% left opening
DrawFormattedText(visuals.window, visuals.training02, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('FrameRect', visuals.window, visuals.openCol, visuals.openLeftCoords, visuals.openWidth);
DrawFormattedText(visuals.window, visuals.trainingLeftpress, 'center', 1000, screen.black);
Screen('Flip', visuals.window);
[~, ~] = waitserialbyte(MMN.scanner.boxport, inf); 
clearserialbytes(MMN.scanner.boxport); 

% right opening
DrawFormattedText(visuals.window, visuals.training03, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('FrameRect', visuals.window, visuals.openCol, visuals.openRightCoords, visuals.openWidth);
DrawFormattedText(visuals.window, visuals.trainingRightpress, 'center', 1000, screen.black);
Screen('Flip', visuals.window);
[~, ~] = waitserialbyte(MMN.scanner.boxport, inf); 
clearserialbytes(MMN.scanner.boxport); 

% explain
DrawFormattedText(visuals.window, visuals.training04, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
DrawFormattedText(visuals.window, visuals.trainingContinue, 'center', 1000, screen.black);
Screen('Flip', visuals.window);
[~, ~] = waitserialbyte(MMN.scanner.boxport, inf); 
clearserialbytes(MMN.scanner.boxport); 

% present some openings
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('Flip', visuals.window);
wait2(2000)

% left
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('FrameRect', visuals.window, visuals.openCol, visuals.openLeftCoords, visuals.openWidth);
Screen('Flip', visuals.window);
wait2(MMN.times.visDuration);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('Flip', visuals.window);

wait2(1000)

% right
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('FrameRect', visuals.window, visuals.openCol, visuals.openRightCoords, visuals.openWidth);
Screen('Flip', visuals.window);
wait2(MMN.times.visDuration);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('Flip', visuals.window);

wait2(2500)

% right
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('FrameRect', visuals.window, visuals.openCol, visuals.openRightCoords, visuals.openWidth);
Screen('Flip', visuals.window);
wait2(MMN.times.visDuration);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('Flip', visuals.window);

wait2(2000)

% explain
DrawFormattedText(visuals.window, visuals.training05, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
DrawFormattedText(visuals.window, visuals.trainingContinue, 'center', 1000, screen.black);
Screen('Flip', visuals.window);
[~, ~] = waitserialbyte(MMN.scanner.boxport, inf); 
clearserialbytes(MMN.scanner.boxport); 

DrawFormattedText(visuals.window, visuals.training06, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
DrawFormattedText(visuals.window, visuals.trainingContinue, 'center', 1000, screen.black);
Screen('Flip', visuals.window);
[~, ~] = waitserialbyte(MMN.scanner.boxport, inf); 
clearserialbytes(MMN.scanner.boxport); 

DrawFormattedText(visuals.window, visuals.training07, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
DrawFormattedText(visuals.window, visuals.trainingStart, 'center', 1000, screen.black);
Screen('Flip', visuals.window);
[~, ~] = waitserialbyte(MMN.scanner.boxport, inf); 
clearserialbytes(MMN.scanner.boxport); 

%% ---------------------- training -------------------------- %%

for trial = 1: length(MMN.stimuli.audSequence) - 1
        
    % instead of playing a tone, wait for as long the tone would have
    % lasted:
    MMN.stimuli.audTimes(trial) = GetSecs - MMN.startScan.GetSecs;           % START sec of tone presentation
    wait2(MMN.times.audDuration);
    
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

% end of script: questions and wait for last button press
DrawFormattedText(visuals.window, visuals.trainingEnd, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
DrawFormattedText(visuals.window, visuals.pressText, 'center', 1000, screen.black);
Screen('Flip', visuals.window);
[~, t] = waitserialbyte(MMN.scanner.boxport, inf);
MMN.stopScreen.GetSecs = GetSecs;
MMN.stopScreen.Serial = t(1);

% security save at this point
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

