function exp_MMN_EEG_instructions_with_tone_test(subject, hand, scanner_mode)
%%EXP_MMN_SCANNER_INSTRUCTIONS_WITH_TONE_TEST Program for MMN instructions 
%%in fMRI with opening central square and a test for hearing the tones
% 
% This program can be run from the command line, specifying: 
% - the subject's name (string)
% - the handedness of the subject ('r' = right, 'l' = left)
%
% e.g.  >> exp_MMN_scanner_instructions_with_tone_test('9999', 'r')
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
    subject = 'DH_test';       % test subject 
    hand = 'r';             % right-handed
    scanner_mode = 0;
end
 
%% ---------------------- setting up session -------------------------- %%

addpath('stimuli', 'design', 'lib');
KbName('UnifyKeyNames');

session = setupSession(subject, hand, 'win', 'instructions', scanner_mode);
MMN = createMMN(session,scanner_mode);

%Initialize triggers
MMN.triggers.test = 99;
MMN.triggers.start = 1;

% Initialize parallel port
if scanner_mode == 3
    ioObj = io64;
    status = io64(ioObj);
    address = hex2dec('378');
    IPI = 4;
    io64(ioObj,address,MMN.triggers.test);   %output command
    wait(IPI);
    io64(ioObj,address,0);
end

%% ------------------------- initializing ----------------------------- %%

cd(session.expPath)
disp('This is the MMN-volatility experiment');
disp(['Instructions and Training for Subject ' subject]);

initializePsychToolBox;
[screen] = setupScreen;  
 
visuals =  createVisualStimuli(screen);

config_keyboard (5,1,'nonexclusive'); % Set up key board
initializeCogent(MMN); 

audios = createAuditoryStimuli(session);
audios = initializeSounds(audios, MMN);


%% ---------------------- start presentation -------------------------- %%

Screen('TextSize', visuals.window, visuals.instrSize);
MMN.startScreen = datestr(now, 30);

% welcome screen
DrawFormattedText(visuals.window, visuals.training00, 'center', 'center', screen.black);
DrawFormattedText(visuals.window, visuals.trainingStart, 'center', 1000, screen.black);
Screen('Flip', visuals.window);
%wait2(2000);

%wait for the scanner and save the starting time
[~,t] = waitkeydown(inf);

if scanner_mode == 3
    io64(ioObj,address,MMN.triggers.start);            
    wait(IPI);                                           
    io64(ioObj,address,0);
end

%[~, t] = waitserialbyte(MMN.scanner.boxport, inf, MMN.scanner.trigger);
MMN.startScan.GetSecs = GetSecs;
MMN.startScan.Cogent = t(1);
%clearserialbytes(MMN.scanner.boxport);


%% ---------------------- instructions -------------------------- %%

% present the center square
DrawFormattedText(visuals.window, visuals.training01, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
DrawFormattedText(visuals.window, visuals.trainingContinue, 'center', 1000, screen.black);
Screen('Flip', visuals.window);

waitkeydown(inf);
%[~, ~] = waitserialbyte(MMN.scanner.boxport, inf);
%clearserialbytes(MMN.scanner.boxport);

% left opening
DrawFormattedText(visuals.window, visuals.training02, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('FrameRect', visuals.window, visuals.openCol, visuals.openLeftCoords, visuals.openWidth);
DrawFormattedText(visuals.window, visuals.trainingLeftpress, 'center', 1000, screen.black);
Screen('Flip', visuals.window);

waitkeydown(inf,MMN.keys.left);
%[~, ~] = waitserialbyte(MMN.scanner.boxport, inf); 
%clearserialbytes(MMN.scanner.boxport); 

% right opening
DrawFormattedText(visuals.window, visuals.training03, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('FrameRect', visuals.window, visuals.openCol, visuals.openRightCoords, visuals.openWidth);
DrawFormattedText(visuals.window, visuals.trainingRightpress, 'center', 1000, screen.black);
 
Screen('Flip', visuals.window);
waitkeydown(inf,MMN.keys.right);
%[~, ~] = waitserialbyte(MMN.scanner.boxport, inf); 
%clearserialbytes(MMN.scanner.boxport); 

% explain
DrawFormattedText(visuals.window, visuals.training04, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
DrawFormattedText(visuals.window, visuals.trainingContinue, 'center', 1000, screen.black);
Screen('Flip', visuals.window);

waitkeydown(inf);
%[~, ~] = waitserialbyte(MMN.scanner.boxport, inf); 
%clearserialbytes(MMN.scanner.boxport); 

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

waitkeydown(inf);
%[~, ~] = waitserialbyte(MMN.scanner.boxport, inf); 
%clearserialbytes(MMN.scanner.boxport); 

DrawFormattedText(visuals.window, visuals.training06, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
DrawFormattedText(visuals.window, visuals.trainingContinue, 'center', 1000, screen.black);
Screen('Flip', visuals.window);

waitkeydown(inf);
%[~, ~] = waitserialbyte(MMN.scanner.boxport, inf); 
%clearserialbytes(MMN.scanner.boxport); 

%% ---------------------- training -------------------------- %%

DrawFormattedText(visuals.window, visuals.training07, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
DrawFormattedText(visuals.window, visuals.trainingStart, 'center', 1000, screen.black);
Screen('Flip', visuals.window);

waitkeydown(inf);
%[~, ~] = waitserialbyte(MMN.scanner.boxport, inf); 
%clearserialbytes(MMN.scanner.boxport); 

idx_resp = 1;
clearkeys;
readkeys;

for trial = 1: length(MMN.stimuli.audSequence) - 1
        
    % instead of playing a tone, wait for as long the tone would have
    % lasted:
    MMN.stimuli.audTimes(trial) = GetSecs - MMN.startScan.GetSecs;           % START sec of tone presentation
    wait2(MMN.times.audDuration);
    
    wait2(MMN.times.SOT(trial));                                            % stimulus onset time
    MMN = drawVisualTrial(MMN, trial, visuals);

    wait2(MMN.times.rest(trial));                                           % wait until ISI is over
    
   % Record responses
    readkeys;
    [k, t]   = getkeydown([MMN.keys.left,MMN.keys.right,MMN.keys.escape]);
    
    if ~isempty(k)
        if any(k == MMN.keys.escape)
            DrawFormattedText(visuals.window, visuals.abortText, 'center', 'center', screen.black);
            Screen('Flip', visuals.window);
            PsychPortAudio('DeleteBuffer');
            PsychPortAudio('Close');
            stop_cogent;
            sca; 
            return;
        else
            MMN.responses.times(idx_resp)   = (t(1) - MMN.startScan.Cogent)/1000;
            MMN.responses.keys(idx_resp)    = k(1);
            idx_resp = idx_resp + 1;   
        end
    end
end

% save end time of training loop
MMN.stopTrainingLoop.GetSecs = GetSecs - MMN.startScan.GetSecs;
MMN.stopTrainingLoop.Cogent  = time    - MMN.startScan.Cogent;

% end of training, start of tone test
DrawFormattedText(visuals.window, visuals.training08, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
DrawFormattedText(visuals.window, visuals.trainingContinue, 'center', 1000, screen.black);
Screen('Flip', visuals.window);

waitkeydown(inf);


%% ---------------------- tone test -------------------------- %%
%DrawFormattedText(visuals.window, visuals.tone01, 'center', 'center', screen.black);
DrawFormattedText(visuals.window, visuals.tone01, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('Flip', visuals.window);

% prepare audio buffer using first tone
nexttone = MMN.stimuli.audSequence(1);
PsychPortAudio('FillBuffer', audios.pahandle, audios.buffer(nexttone));

% play 10 tones of the training sequence
for trial = 1: 10
        
    nexttone = MMN.stimuli.audSequence(trial + 1);
    
    MMN.stimuli.startTimes(trial) = PsychPortAudio('Start', audios.pahandle, 1, 0, 1); % tone of 1st trial is already in the buffer
    
    PsychPortAudio('FillBuffer', audios.pahandle, audios.buffer(nexttone));
    
    wait2(500);                                           % wait until ISI is over
    
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

% save end time of tone test loop
MMN.stopTonetestLoop.GetSecs = GetSecs - MMN.startScan.GetSecs;
MMN.stopTonetestLoop.Cogent = time - MMN.startScan.Cogent;

% end of tone test: did they hear the tones?
DrawFormattedText(visuals.window, visuals.tone02, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
DrawFormattedText(visuals.window, visuals.trainingContinue, 'center', 1000, screen.black);
Screen('Flip', visuals.window);

waitkeydown(inf);
%[~, ~] = waitserialbyte(MMN.scanner.boxport, inf); 
%clearserialbytes(MMN.scanner.boxport); 

% end of script: questions and wait for last button press
DrawFormattedText(visuals.window, visuals.trainingEnd, 'center', 100, screen.black);
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
DrawFormattedText(visuals.window, visuals.pressText, 'center', 1000, screen.black);
Screen('Flip', visuals.window);

[~, t] = waitkeydown(inf);
%[~, t] = waitserialbyte(MMN.scanner.boxport, inf);
MMN.stopScreen.GetSecs = GetSecs;
MMN.stopScreen.Cogent = t(1);

% Create response dummies
MMN.responses.dummy = MMN.responses.keys == MMN.keys.right;
MMN.responses.dummy = MMN.responses.dummy + (MMN.responses.keys == MMN.keys.left)*2;


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

