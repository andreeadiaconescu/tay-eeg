function audios = initializeSounds(audios, MMN)

% intialize sounds
InitializePsychSound('reallyneedlowlatency=1')
audios.devices = PsychPortAudio('GetDevices');

% fill tone buffers
audios.buffer = [];
audios.buffer(end+1) = PsychPortAudio('CreateBuffer', [], audios.wav1); 
audios.buffer(end+1) = PsychPortAudio('CreateBuffer', [], audios.wav2); 

% get handle and set to run modesuggestedLatencySecs = 0.015;
buffersize = 0;
deviceid = 3;

audios.pahandle = PsychPortAudio('Open', deviceid, [], 1, audios.freq, audios.nrchannels);%, buffersize, suggestedLatencySecs);
%audios.pahandle = PsychPortAudio('Open', audios.devices, [], 1, audios.freq, audios.nrchannels);
runMode = 1;
PsychPortAudio('RunMode', audios.pahandle, runMode);

% fill playbuffer with tone of first trial:
PsychPortAudio('FillBuffer', audios.pahandle, audios.buffer(MMN.stimuli.audSequence(1)));


end