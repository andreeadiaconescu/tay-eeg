function DH_exp_MMN_scanner(subject, hand, scanner_mode)
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

[screen] = setupScreen; 
visuals = createVisualStimuli(screen);
initializePsychToolBox;

config_keyboard (5,1,'nonexclusive'); % Set up key board
initializeCogent(MMN);

audios = createAuditoryStimuli(session);
audios = initializeSounds(audios, MMN);


%% ---------------------- start presentation -------------------------- %%
Screen('TextSize', visuals.window, visuals.instrSize);
MMN.startScreen.Date       = datestr(now, 30);
MMN.startScreen.GetSecs    = GetSecs;
MMN.startScreen.Cogent     = time;

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
MMN.startScan.Cogent = t(1);

% start with center square
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('Flip', visuals.window);

% save start time of main loop
MMN.startLoop.Date      = datestr(now, 30);
MMN.startLoop.GetSecs   = GetSecs - MMN.startScan.GetSecs;
MMN.startLoop.Cogent    = time - MMN.startScan.Cogent;



%% ---------------------- main loop -------------------------- %%
idx_resp = 1;  % initialize response index 
clearkeys;
readkeys;

for trial = 1:length(MMN.stimuli.audSequence) - 1
    
    nexttone = MMN.stimuli.audSequence(trial + 1);
    
    % Play tone & record time
    MMN.stimuli.startTimes(trial) = PsychPortAudio('Start', audios.pahandle, 1, 0, 1); % tone of 1st trial is already in the buffer
    MMN.stimuli.audTimes(trial) = GetSecs - MMN.startScan.GetSecs;           % START sec of tone presentation
    
    PsychPortAudio('FillBuffer', audios.pahandle, audios.buffer(nexttone));
    
    wait2(MMN.times.SOT(trial));                                            % stimulus onset time
    
    % Draw visual stimulus
    MMN = drawVisualTrial(MMN, trial, visuals);

    wait2(MMN.times.rest(trial));                                           % wait until ISI is over
    
    % Record responses
    readkeys;
    [k, t] = getkeydown([MMN.keys.escape MMN.keys.left MMN.keys.right]);   
    if ~isempty(k)
        if any(k == MMN.keys.escape)
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
            
        else
            MMN.responses.times(idx_resp)   = (t(1) - MMN.startScan.Cogent)/1000;
            MMN.responses.keys(idx_resp)    = k(1);
            idx_resp = idx_resp + 1;   
        end
    end
end

% save end time of main loop
MMN.stopLoop.Date       = datestr(now, 30);
MMN.stopLoop.GetSecs    = GetSecs - MMN.startScan.GetSecs;
MMN.stopLoop.Cogent     = time - MMN.startScan.Cogent;

% please wait screen
DrawFormattedText(visuals.window, visuals.waitText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);

%% ------------- response times readout ----------------- %%
MMN.responses.dummy = MMN.responses.keys == MMN.keys.right;
MMN.responses.dummy = MMN.responses.dummy + (MMN.responses.keys == MMN.keys.left)*2;

% correct start times
MMN.stimuli.startTimes = MMN.stimuli.startTimes - MMN.startScan.GetSecs;

% Output warning, when they where no responses
if isempty(MMN.responses.times )
    warning('NO RESPONSES RECORDED!');
    MMN.responses.times     = NaN;
    MMN.responses.keys      = NaN;
end

% security save at this point
save(session.baseName, 'MMN');


%% ------------- timing check ----------------- %%
clearkeys;  

% please press button screen
DrawFormattedText(visuals.window, visuals.pressText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);

if scanner_mode == 0
    [~,t] = waitkeydown(inf);
else
    [~,t] = waitkeydown(inf,MMN.keys.scanner_trigger);
end
MMN.stopScreen.Date     = datestr(now, 30);
MMN.stopScreen.GetSecs  = GetSecs;
MMN.stopScreen.Serial   = t(1);


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

