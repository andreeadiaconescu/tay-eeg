%% Alternating auditory instructions to aid spontaneous EEG recording
% by Gabor Stefanics
function COMPI_Rest_practice()

%config_io;
address = hex2dec('A010');%corrected on 6.3.2017 by SI
[y1, freq] = wavread('C:\Users\danie\Dropbox\EEG_IOIO\paradigms\Rest\open3.wav');
[y2, freq] = wavread('C:\Users\danie\Dropbox\EEG_IOIO\paradigms\Rest\close3.wav');

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

 [window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray, [], 32, 2,...
     [], [],  kPsychNeed32BPCFloat);   
% [window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray, [0 0 800 600], 32, 2,...
%     [], [],  kPsychNeed32BPCFloat);  
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');  % set up alpha-blending for smooth (anti-aliased) lines
Screen('Flip', window);
[xCenter, yCenter] = RectCenter(windowRect);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
HideCursor(screenNumber);


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

wait2(5000);

for i = 1 : 2

    for b = 1 : 2
%         tic
        
        outp(address, b);  wait2(5); outp(address, 0); 
        PsychPortAudio('Start', pahandle, 1, 0, 0);
%         toc


%         tic
        PsychPortAudio('FillBuffer', pahandle, buffer(b));
%         toc
        wait2(7000);
    end

end

endText = 'Geschafft!';

DrawFormattedText(window, endText, 'center', 'center', black);
Screen('Flip', window);
% Wait for end of playback, then stop:
PsychPortAudio('Stop', pahandle, 1);

% Delete all dynamic audio buffers:
PsychPortAudio('DeleteBuffer');

% Close audio device, shutdown driver:
PsychPortAudio('Close');

wait2(5000)

sca
close all
