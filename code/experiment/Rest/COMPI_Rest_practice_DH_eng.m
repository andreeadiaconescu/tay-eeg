%% Alternating auditory instructions to aid spontaneous EEG recording
% by Gabor Stefanics
function COMPI_Rest_practice_DH_eng(scanner_mode)

%% Configurations
% Load auditory Stimuli
[y1, freq] = audioread('800Hz250ms.wav');
[y2, freq] = audioread('800Hz250ms.wav');
 
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
 [window, windowRect] = PsychImaging('OpenWindow', screenNumber, black, [], 32, 2,...
     [], [],  kPsychNeed32BPCFloat);   
%  [window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray, [0 0 800 600], 32, 2,...
%      [], [],  kPsychNeed32BPCFloat);  
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');  % set up alpha-blending for smooth (anti-aliased) lines
Screen('Flip', window);


[xCenter, yCenter] = RectCenter(windowRect);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
HideCursor(screenNumber);


%% Configure key board
config_keyboard (5,1,'nonexclusive'); % Set up key board
start_cogent;


%% Welcome screen
%startText = sprintf(['Willkommen zum ersten Experiment.\n\n\n',...
%                     'In diesem Experiment werden Sie Ihre \n\n',...
%                     'Augen oeffnen und schliessen muessen. \n\n\n',...
%                     'Versuchen Sie sich bitte waehrend der Messung \n\n',...
%                     'moeglichst wenig zu bewegen. Wenn Sie \n\n',...
%                     'sich unbedingt bewegen muessen, dann tun \n\n',...
%                     'Sie das, wenn moeglich, waehrend Sie die Augen \n\n',...
%                     'geoeffnet haben. Wenn Sie z.B. niesen \n\n',...
%                     'muessen koennen Sie das natuerlich tun. \n\n\n\n',...
%                     'Druecken Sie eine beliebige Taste, um fortzufahren']);

startText = sprintf(['Welcome to the first experiment.\n\n\n',...
	             'In this experiment, you will be yours \n\n',...
                     'Open and close eyes \n\n\',...
		     'Please try your hand at the measurement \n\n',...
		     'to move as little as possible. If you \n\n',...
		     'absolutely have to move, then do \n\n',...
		     'Do this, if possible, while keeping your eyes closed \n\n',...
		     'have opened. For example, if you sneeze \n\n',...
		     'you can of course do that. \n\n',...
		     'Press any key to continue \n\n']);


DrawFormattedText(window, startText, 'center', 'center', white);
Screen('Flip', window);

if scanner_mode == 1
    waitkeydown(inf,[28,29,30,31]);
else
    waitkeydown(inf);
end

%startText = sprintf(['Bleiben Sie bitte die ganze Zeit wach. \n\n',...
%                     'Waehrend Sie die Augen geschlossen haben, \n\n',...
%                     'koennen Sie an alles denken was sie wollen. \n\n\n\n',...    
%                     'Druecken Sie eine beliebige Taste, um fortzufahren']);
startText = sprintf(['Please stay awake all the time.\n\n',...
                     'While you closed your eyes\n\n',...
                     'You can think of anything you want.\n\n\n\n',...
                     'Press any key to continue']);

DrawFormattedText(window, startText, 'center', 'center', white);
Screen('Flip', window);

if scanner_mode == 1
    waitkeydown(inf,[28,29,30,31]);
else
    waitkeydown(inf);
end



%% Instruction ctd
%startText = sprintf(['Bitte schliessen Sie ihre Augen, wenn Sie \n\n',...
%                     'den ersten Ton ueber die Kopfhoerer hoeren \n\n',...
%                     'und halten Sie Ihre Augen geschlossen \n\n',...
%                     'bis Sie den zweiten Ton hoeren. \n\n',...
%                     'Dieser Vorgang wird dann einige Male wiederholt. \n\n\n\n',...
%                     'Druecken Sie eine beliebige Taste, um fortzufahren']);

startText = sprintf (['Please close your eyes if you \n\n',...
                     'hear the first tone over the headphones \n\n',...
                     'and keep your eyes closed \n\n',...
                     'until you hear the second tone. \n\n',...
                     'This process is then repeated a few times. \n\n\n\n',...
                     'Press any key to continue']);



DrawFormattedText(window, startText, 'center', 'center', white);
Screen('Flip', window);

if scanner_mode == 1
  waitkeydown(inf,[28,29,30,31]);
else
    waitkeydown(inf);
end

%% Instruction continued
%startText = sprintf(['Bitte, teilen Sie uns mit, wenn Sie die \n\n',...
%                     'Toene nicht hoeren koennen. \n\n\n\n',...
%                     'Sie koennen das Ganze jetzt kurz ueben.\n\n\n',...                     
%                     'Druecken Sie eine beliebige Taste, um die Uebung zu beginnen']);
startText = sprintf (['Please, let us know if you have the \n\n',...
                     'Cant hear sounds. \n\n\n\n ',...
                     'You can now practice the whole thing briefly. \n\n\n',...
                     'Press any key to start the exercise']);


DrawFormattedText(window, startText, 'center', 'center', white);
Screen('Flip', window);
if scanner_mode == 1
    waitkeydown(inf,[28,29,30,31]);
else
    waitkeydown(inf);
end

%% Fixation Cross
% fixCross = struct(); 
% fixCross.lineWidth = 6;
% fixCross.size = 0.02 * screenYpixels;
% fixCross.color = black;
% fixCross.position = [-fixCross.size fixCross.size 0 0;...
%     0 0 -fixCross.size fixCross.size];
% fixCross.center = [xCenter, yCenter];
% 
% % Draw the Fixation Cross to the screen
% Screen('DrawLines', window, fixCross.position,...
%         fixCross.lineWidth, fixCross.color(1, :), ...
%         fixCross.center, 2);
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
                if i == 1
                    wait2(4000);
                end
        end
    end
end

wait2(1000); %Wait only shortly, after last tone

%% End screen
%endText = sprintf(['Sie haben die Uebung geschafft. \n\n\n',...
%    'Bitte, sagen Sie uns jetzt Bescheid, \n\n'...
%    'falls Sie die Toene nicht hoeren konnten. \n\n\n\n',...
%    'Druecken Sie eine beliebige Taste, um fortzufahren']);
endText = sprintf (['You have done the exercise. \n\n\n',...
    'Please let us know now,\n\n',...
    'in case you couldnt hear the tones. \n\n\n\n',...
    'Press any key to continue']);

DrawFormattedText(window, endText, 'center', 'center', white);
Screen('Flip', window);
if scanner_mode == 1
    waitkeydown(inf,[28,29,30,31]);
else
    waitkeydown(inf);
end


%endText = sprintf(['- Ende der Uebung -\n\n\n',...
%    'Wundern Sie sich nicht:\n\n',...
%    'Im echten Experiment wird die Zeit zwischen \n\n',...
%    'den Toenen laenger sein.\n\n']);
endText = sprintf(['- end of exercise - \n\n\n',...
    'Dont be surprised: \n\n',...
    'In the real experiment, the time between\n\n',...
    'the tones be longer.\n\n']);


DrawFormattedText(window, endText, 'center', 'center', white);
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
