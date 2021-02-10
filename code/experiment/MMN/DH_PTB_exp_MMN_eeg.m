function DH_exp_MMN_eeg(subject, hand, scanner_mode)
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

%config_keyboard (5,1,'nonexclusive'); % Set up key board
%initializeCogent(MMN);

audios = createAuditoryStimuli(session);
audios = initializeSounds(audios, MMN);


%% ---------------------- start presentation -------------------------- %%
% start screen
Screen('TextSize', visuals.window, visuals.instrSize);
MMN.startScreen.Date       = datestr(now, 30);
MMN.startScreen.GetSecs    = GetSecs;
%MMN.startScreen.Cogent     = time;

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

% start with center square
Screen('FrameRect', visuals.window, visuals.fixCol, visuals.fixCoords, visuals.fixWidth);
Screen('Flip', visuals.window);

if scanner_mode == 3
    io64(ioObj,address,MMN.triggers.start);            
    wait(IPI);                                           
    io64(ioObj,address,0);
end

% save start time of main loop
MMN.startLoop.Date      = datestr(now, 30);
MMN.startLoop.GetSecs   = GetSecs;
MMN.stimuli.startSec    = GetSecs;
%MMN.stimuli.Cogent      = time;
 

%% ---------------------- main loop -------------------------- %%
idx_resp = 1;
%clearkeys;
%readkeys;


for trial = 1:20%length(MMN.stimuli.audSequence) - 1
    %load tone
    nexttone = MMN.stimuli.audSequence(trial + 1);
    
    %send trigger
    if scanner_mode == 3
        io64(ioObj,address,MMN.triggers.tones(trial));
        wait(IPI);
        io64(ioObj,address, 0);
    end
    
    %Play tone & record time
    MMN.stimuli.startTimes(trial) = PsychPortAudio('Start', audios.pahandle, 1, 0, 1); % tone of 1st trial is already in the buffer
    MMN.stimuli.audTimes(trial) = GetSecs - MMN.stimuli.startSec;           % START sec of tone presentation
    
   
    %Update buffer
    PsychPortAudio('FillBuffer', audios.pahandle, audios.buffer(nexttone));
     
    wait2(MMN.times.SOT(trial));                                            % stimulus onset time
   
    
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
    
    % Record responses
%     readkeys;
%     [k, t]   = getkeydown([MMN.keys.left,MMN.keys.right,MMN.keys.escape]);
%     
%     if ~isempty(k)
%         if any(k == MMN.keys.escape)
%             DrawFormattedText(visuals.window, visuals.abortText, 'center', 'center', screen.black);
%             Screen('Flip', visuals.window);
%             PsychPortAudio('DeleteBuffer');
%             PsychPortAudio('Close');
%             stop_cogent;
%             sca;
%             return;
%         else
%             MMN.responses.times(idx_resp)   = t(1) - MMN.stimuli.Cogent;
%             MMN.responses.keys(idx_resp)    = k(1);
%             idx_resp = idx_resp + 1;
%             
%         end
%     end

    [~, t, keyCode] = KbCheck;
    if keyCode(MMN.keys.escapeKey)
        DrawFormattedText(visuals.window, visuals.abortText, 'center', 'center', screen.black);
        Screen('Flip', visuals.window);
        PsychPortAudio('DeleteBuffer');
        PsychPortAudio('Close');
        stop_cogent;
        sca;
        return;
    elseif keyCode(MMN.keys.left) || keyCode(MMN.keys.right)        
        MMN.responses.times(idx_resp)   = t(1) - MMN.stimuli.startSec;
        MMN.responses.keys(idx_resp)    = KbName(KbName(keyCode));
        idx_resp = idx_resp + 1;
        disp(KbName(keyCode));
    end
end

% save end time of main loop
MMN.stopLoop.GetSecs    = GetSecs - MMN.stimuli.startSec;
MMN.stopLoop.Date       = datestr(now, 30);
%MMN.stopLoop.Cogent     = time - MMN.stimuli.Cogent;


%% ------------- response times readout ----------------- %%
% correct start times
MMN.stimuli.startTimes = MMN.stimuli.startTimes - MMN.stimuli.startSec;

% Output warning, when they where no responses
if isempty(MMN.responses.times )
    warning('NO RESPONSES RECORDED!');
    MMN.responses.times     = NaN;
    MMN.responses.keys      = NaN;
end

% security save at this point
save(session.baseName, 'MMN');


% please wait screen
DrawFormattedText(visuals.window, visuals.waitText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);




%% ------------- timing check ----------------- %%
% measure time once again, to compare
%clearkeys;  

% please press button screen
DrawFormattedText(visuals.window, visuals.pressText, 'center', 'center', screen.black);
Screen('Flip', visuals.window);

% wait for an experimenter button press
KbStrokeWait;

% save starting time
MMN.stopScreen.Date     = datestr(now, 30);
MMN.stopScreen.GetSecs  = GetSecs;
MMN.stopScreen.Cogent   = time; % this is cogent time


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

