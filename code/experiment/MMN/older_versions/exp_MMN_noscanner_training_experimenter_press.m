function exp_MMN_noscanner_training_experimenter_press(subject, hand)
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

session = setupSession(subject, hand, 'win', 'training');
MMN = createMMN(session);


%% ------------------------- initializing ----------------------------- %%

cd(session.expPath)
disp('This is the MMN-volatility experiment');

initializePsychToolBox;
initializeCogent(MMN);

[screen] = setupScreen; 
visuals = createVisualStimuli(screen);


%% ---------------------- start presentation -------------------------- %%

Screen('TextSize', visuals.window, visuals.instrSize);
MMN.startScreen = datestr(now, 30);

% instructions
DrawFormattedText(visuals.window, visuals.instrText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);

% wait for an experimenter button press
KbStrokeWait;

% save starting time
MMN.startScan.GetSecs = GetSecs;
MMN.startScan.cogent = time; % this is cogent time

% start with center square
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('Flip', visuals.window);

% save start time of main loop
MMN.startLoop = GetSecs - MMN.startScan.GetSecs;

%% ---------------------- main loop -------------------------- %%

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
        stop_cogent;
        sca;
        return;
    end
end

% save end time of main loop
MMN.stopLoop = GetSecs - MMN.startScan.GetSecs;

% please wait screen
DrawFormattedText(visuals.window, visuals.waitText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);

%% ------------- response times readout ----------------- %%

% save all responses
%{
readserialbytes(MMN.scanner.boxport);
[responses, responseTimes] = getserialbytes(MMN.scanner.boxport);
MMN.responseTimes = responseTimes - MMN.startScan.Serial;
MMN.responses = responses;

% security save at this point
save(session.baseName, 'MMN');
%}

%% ------------- timing check ----------------- %%

% measure time once again, to compare
clearserialbytes(MMN.scanner.boxport);

% please press button screen
DrawFormattedText(visuals.window, visuals.pressText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);

% wait for an experimenter button press
KbStrokeWait;
MMN.stopScreen.GetSecs = GetSecs;
MMN.stopScreen.cogent = time; % this is cogent time


%% ------------- goodbye ----------------- %%

% goodbye screen
DrawFormattedText(visuals.window, visuals.endText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);

% save all data in workspace
save(session.baseName, 'MMN');

%% ---------------------- shut down ------------------------ %%

% Close all screens
sca;

% Stop cogent
stop_cogent;

end

