function visuals = createVisualStimuli(screen)

visuals.window = screen.window;

% text (instructions)
visuals.instrSize = 25; %25 CHANGED to fit things on screen
visuals.instrText = 'Please indicate, on which side the square opens. \n\n\n\n Please wait to begin.';
visuals.abortText = 'Cancel';
visuals.waitText = 'Please wait...';
visuals.pressText = 'End: Please click on any key to end the experiment.';
visuals.endText = 'Thank you!';

% fixation square
visuals.fixSize = 30;                                                       % size of square side in pixels
visuals.fixWidth = 2;
visuals.fixCol = screen.white;
visuals.fixRect = [0 0 visuals.fixSize visuals.fixSize];
visuals.fixCoords = CenterRectOnPointd(visuals.fixRect, screen.xCenter, screen.yCenter);

% openings
visuals.openWidth = 5;
visuals.openCol = screen.gray;
visuals.openDist = visuals.fixSize - visuals.fixWidth;
visuals.openLeftCoords = CenterRectOnPointd(visuals.fixRect, screen.xCenter - visuals.openDist, screen.yCenter);
visuals.openRightCoords = CenterRectOnPointd(visuals.fixRect, screen.xCenter + visuals.openDist, screen.yCenter);

% text (training)
visuals.trainSize = 30; % 30; CHANGED by zheng
visuals.trainingStart = 'Please click on any key to begin ...';
visuals.trainingContinue = 'Please click on any key to continue ...';
visuals.trainingLeftpress = 'Click on the left arrow.';
visuals.trainingRightpress = 'Click on the right arrow.';
visuals.trainingEnd = ['The practice is complete. \n\n\n' ...
    'If you have further questions, please ask the experimenter \n\n' ...
    'Good luck!'];

visuals.training00 = ['Welcome to the practice session. \n\n\n\n' ...
    'Your task will be now described to you. \n\n' ...
    'If you have further questions after the practice trial, \n\n please ask the experimenter.'];

visuals.training01 = ['At the centre of the screen, there is a square.  \n\n' ...
    'From time to time, one side of it will disappear.  \n\n' ...
    'Your task is to respond with the corresponding button press as soon as possible.'];

visuals.training02 = 'When you see the square open on the left side, as in the display, \n\n respond by pressing the left arrow.';
visuals.training03 = 'When you see the square open on the right side, as in the display, \n\n respond by pressing the right arrow.';
visuals.training04 = ['This change occurs very quickly.  \n\n' ...
    'In the next screen, the effects will be presented in realtime:'];

visuals.training05 = ['The square opened once on the left \n\n and twice on the right.  \n\n\n' ... 
    'To not miss the changes, keep your gaze fixated at the center of the screen.'];

visuals.training06 = ['Please respond as quickly and as accurately as possible \n\n' ...
    'to the shape changes.'];

visuals.training07 = ['Now we begin a short practice. \n\n\n' ...
    'The square at the center of the screen will open a few times. \n\n' ... 
    'Please click on the left arrow, if the square opens on the left,  \n\n' ...
    'and the right arrow, if it opens on the right side.'];

visuals.training08 = ['End of the practice. \n\n\n' ...
    'If you have further questions, address them to your experimenter. \n\n' ...
    'Please note: During the task, you will hear some tones. \n\n' ... 
    'To be sure that you can hear the tones \n\n' ...
    'we will play them now for you.'];
    
visuals.tone01 = ['Tone test. \n\n' ...
    'You might hear 10 short tones.' ];

visuals.tone02 = ['End of tone test. \n\n\n' ...
    'If you cannot hear the tones please inform your experimenter. \n\n\n' ...
    'Please note: You can ignore the tones. \n\n' ...
    'They do not relate to the changes in the square shape. \n\n' ...
    'Please respond to the shape changes as quickly and as accurately as possible.'];

end
