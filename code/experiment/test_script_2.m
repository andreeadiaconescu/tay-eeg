
addpath('Rest')

clear all
[y1, freq] = audioread('800Hz250ms.wav');
wavedata1 = y1';
nrchannels = size(wavedata1,1);
InitializePsychSound('reallyneedlowlatency=1')
buffer = PsychPortAudio('CreateBuffer', [], wavedata1); 
pahandle = PsychPortAudio('Open', [], [], 1, freq, nrchannels);
PsychPortAudio('FillBuffer', pahandle, buffer)% buffer(2));
PsychPortAudio('Start', pahandle, 1, 0, 0);
PsychPortAudio('Stop', pahandle, 1);
% Delete all dynamic audio buffers:
PsychPortAudio('DeleteBuffer'); 
% Close audio device, shutdown driver:
PsychPortAudio('Close');




%%
%% --------------

%% Configurations
% Load auditory Stimuli
addpath('Rest')

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


%% Configure key board
%config_keyboard (5,1,'nonexclusive'); % Set up key board
%start_cogent;

i = 1;
b = 1;
PsychPortAudio('Start', pahandle, 1, 0, 0);
PsychPortAudio('FillBuffer', pahandle, buffer(b));
%% Close all
% Wait for end of playback, then stop:
PsychPortAudio('Stop', pahandle, 1);
% Delete all dynamic audio buffers:
PsychPortAudio('DeleteBuffer'); 
% Close audio device, shutdown driver:
PsychPortAudio('Close');





PsychPortAudio('Start', pahandle, 1, 0, 0);
PsychPortAudio('FillBuffer', pahandle, buffer(b));
%% Close all
% Wait for end of playback, then stop:
PsychPortAudio('Stop', pahandle, 1);
% Delete all dynamic audio buffers:
PsychPortAudio('DeleteBuffer'); 
% Close audio device, shutdown driver:
PsychPortAudio('Close');