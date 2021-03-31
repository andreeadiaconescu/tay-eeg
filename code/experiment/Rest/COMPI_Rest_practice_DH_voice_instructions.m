%% Alternating auditory instructions to aid spontaneous EEG recording
% by Gabor Stefanics
function COMPI_Rest_practice_DH_voice_instructions

%% Configurations
% Load auditory Stimuli
[y1, freq] = audioread('C:\Users\Danie\Dropbox\EEG_IOIO\COMPI\COMPI_paradigms\Rest\eyes_open_ger.wav');
[y2, freq] = audioread('C:\Users\Danie\Dropbox\EEG_IOIO\COMPI\COMPI_paradigms\Rest\eyes_close_ger.wav');
 
wavedata1 = y1';
nrchannels = size(wavedata1,1); % Number of rows == number of channels.

if nrchannels < 2
    wavedata1 = [wavedata1 ; wavedata1]; 
    nrchannels = 2;
end

wavedata2 = y2';
nrchannels = size(wavedata2,1); % Number of rows == number of channels.

if nrchannels < 2
    wavedata2 = [wavedata2 ; wavedata2];
    nrchannels = 2;
end

% Initialize sound buffer
InitializePsychSound('reallyneedlowlatency=1')
devices = PsychPortAudio('GetDevices', [], []);
buffer = [];
buffer(end+1) = PsychPortAudio('CreateBuffer', [], wavedata1); 
buffer(end+1) = PsychPortAudio('CreateBuffer', [], wavedata2); 
pahandle = PsychPortAudio('Open', [], [], 1, freq, nrchannels);

runMode = 1;
PsychPortAudio('RunMode', pahandle, runMode);

% Fill playbuffer with content of buffer(1):
PsychPortAudio('FillBuffer', pahandle, buffer(2));


%% ---------------------- set up screen -------------------------- %%
screens = Screen('Screens');                                                % get screen numbers
screenNumber = max(screens);                                                % draw to external screen

black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
gray = white/2;

Screen('Preference', 'SkipSyncTests', 1) %disable synchronization test (unrecommended)
 [window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray, [], 32, 2,...
     [], [],  kPsychNeed32BPCFloat);   
%  [window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray, [0 0 800 600], 32, 2,...
%      [], [],  kPsychNeed32BPCFloat);  
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');  % set up alpha-blending for smooth (anti-aliased) lines
Screen('Flip', window);


[xCenter, yCenter] = RectCenter(windowRect);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
HideCursor(screenNumber);


%% Welcome screen
startText = sprintf(['Willkommen zum ersten Experiment.\n\n\n',...
                     'Bitte schliessen Sie ihre Augen, wenn Sie \n\n',...
                     'ueber die Kopfhoerer ''Augen schliessen'' hoeren \n\n',...
                     'und halten Sie Ihre Augen geschlossen \n\n',...
                     'bis Sie ''Augen oeffnen'' hoeren. \n\n',...
                     'Wenn Sie ihre Augen geoeffnet haben, \n\n',...
                     'fixieren Sie bitte, das Kreuz in der \n\n',...
                     'Mitte des Bildschirms. \n\n\n\n',...                  
                     'Druecken Sie eine beliebige Taste, um fortzufahren']);
                    
DrawFormattedText(window, startText, 'center', 'center', black);
Screen('Flip', window);
KbStrokeWait;

%% Instruction continued
startText = sprintf(['Bitte, teilen Sie uns mit, wenn Sie die Audio- \n\n',...
                     'Instruktionen nicht hoeren koennen. \n\n\n\n',...
                     'Sie koennen nun das Ganze kurz ueben.\n\n\n',...                     
                     'Druecken Sie eine beliebige Taste, um die Uebung zu beginnen']);
                    
DrawFormattedText(window, startText, 'center', 'center', black);
Screen('Flip', window);
KbStrokeWait;

%% Fixation Cross
fixCross = struct(); 
fixCross.lineWidth = 6;
fixCross.size = 0.02 * screenYpixels;
fixCross.color = black;
fixCross.position = [-fixCross.size fixCross.size 0 0;...
    0 0 -fixCross.size fixCross.size];
fixCross.center = [xCenter, yCenter];

% Draw the Fixation Cross to the screen
Screen('DrawLines', window, fixCross.position,...
        fixCross.lineWidth, fixCross.color(1, :), ...
        fixCross.center, 2);
Screen('Flip', window);

wait2(3000);

for i = 1 : 2
    for b = 1 : 2       
        PsychPortAudio('Start', pahandle, 1, 0, 0);

        PsychPortAudio('FillBuffer', pahandle, buffer(b)); 
        
        switch b
            case 1 %close eyes
                wait2(10000);
            case 2 %open eyes
                wait2(4000);
        end
    end
end


%% End screen
endText = sprintf(['Sie haben die Uebung geschafft. \n\n\n',...
                   'Wundern Sie sich nicht:\n\n',...
                   'Im echten Experiment wird die Zeit zwischen \n\n',...
                   'den Instruktionen laenger sein.\n\n']);

DrawFormattedText(window, endText, 'center', 'center', black);
Screen('Flip', window);


%% Close all
% Wait for end of playback, then stop:
PsychPortAudio('Stop', pahandle, 1);

% Delete all dynamic audio buffers:
PsychPortAudio('DeleteBuffer');

% Close audio device, shutdown driver:
PsychPortAudio('Close');

wait2(5000)
sca
close all
