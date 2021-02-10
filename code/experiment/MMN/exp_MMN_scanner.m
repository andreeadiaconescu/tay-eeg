function exp_MMN_scanner(subject, hand, scanner_mode)
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

session = setupSession(subject, hand, 'win', 'full');
MMN = createMMN(session,scanner_mode);


%% ------------------------- initializing ----------------------------- %%

cd(session.expPath)
disp('This is the MMN-volatility experiment');

[screen] = setupScreen; 
visuals = createVisualStimuli(screen);
initializePsychToolBox;

config_keyboard (5,1,'nonexclusive'); % Set up key board
initializeCogent(MMN);

audios = createAuditoryStimuli(session);
audios = initializeSounds(audios, MMN);


%% ---------------------- start presentation -------------------------- %%

Screen('TextSize', visuals.window, visuals.instrSize);
MMN.startScreen = datestr(now, 30);

% instructions
DrawFormattedText(visuals.window, visuals.instrText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);

% wait for the scanner and save the starting time
if scanner_mode == 0
    [~,t] = waitkeydown(inf);
else
    [~,t] = waitkeydown(inf,MMN.keys.scanner_trigger);
end

MMN.startScan.GetSecs = GetSecs;
MMN.startScan.Serial = t(1);

% start with center square
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('Flip', visuals.window);

% save start time of main loop
MMN.startLoop.GetSecs = GetSecs - MMN.startScan.GetSecs;

%% ---------------------- main loop -------------------------- %%

i = 1; % initialize response index 
clearkeys;
clear t

for trial = 1:length(MMN.stimuli.audSequence) - 1
    
    nexttone = MMN.stimuli.audSequence(trial + 1);
    
    MMN.stimuli.startTimes(trial) = PsychPortAudio('Start', audios.pahandle, 1, 0, 1); % tone of 1st trial is already in the buffer
    MMN.stimuli.audTimes(trial) = GetSecs - MMN.startScan.GetSecs;           % START sec of tone presentation
    
    PsychPortAudio('FillBuffer', audios.pahandle, audios.buffer(nexttone));
    
    wait2(MMN.times.SOT(trial));                                            % stimulus onset time
    MMN = drawVisualTrial(MMN, trial, visuals);

    wait2(MMN.times.rest(trial));                                           % wait until ISI is over
    
    readkeys;
    [k, ~] = getkeydown([MMN.keys.escapeKey MMN.keys.left MMN.keys.right]);
    if ~isempty(k)
        if k(1) == MMN.keys.escapeKey
            DrawFormattedText(visuals.window, visuals.abortText, 'center', 'center', screen.black);
            Screen('Flip', visuals.window);
            
            %Save MMN structure up till this timepoint
            MMN.stimuli.startTimes = MMN.stimuli.startTimes - MMN.startScan.GetSecs;
            save(session.baseName, 'MMN');
            
            %Close everything
            PsychPortAudio('DeleteBuffer');
            PsychPortAudio('Close');
            stop_cogent;
            sca;
            return;
            
        elseif k(1) == MMN.keys.left
            MMN.responses.times(i,1) = GetSecs - MMN.startScan.GetSecs;
            MMN.responses.keys(i,1) = 1;
            i = i + 1;
            
        elseif k(1) == MMN.keys.right
            MMN.responses.times(i,1) = GetSecs - MMN.startScan.GetSecs;
            MMN.responses.keys(i,1) = 2;
            i = i + 1;
        end
        clear k
    end
                       
%     [~, t, keyCode] = KbCheck;
%     if keyCode(MMN.keys.escapeKey)
%         DrawFormattedText(visuals.window, visuals.abortText, 'center', 'center', screen.black);
%         Screen('Flip', visuals.window);
%         PsychPortAudio('DeleteBuffer');
%         PsychPortAudio('Close');
%         stop_cogent;
%         sca;
%         return;
%     end
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
%readserialbytes(MMN.scanner.boxport); CHANGE
%[responses, responseTimes] = getserialbytes(MMN.scanner.boxport);
%[responses, responseTimes] = getkeys(MMN.scanner.boxport)
%MMN.responses.times = responseTimes - MMN.startScan.Serial;
%MMN.responses.keys = responses;

% security save at this point
save(session.baseName, 'MMN');


%% ------------- timing check ----------------- %%

% measure time once again, to compare
%clearserialbytes(MMN.scanner.boxport);

% please press button screen
DrawFormattedText(visuals.window, visuals.pressText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);

if scanner_mode == 0
    [~,t] = waitkeydown(inf);
else
    [~,t] = waitkeydown(inf,MMN.keys.scanner_trigger);
end
%[~, t] = waitserialbyte(MMN.scanner.boxport, inf);
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

