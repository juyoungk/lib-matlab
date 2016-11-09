function screentest()

Screen('Preference', 'SkipSyncTests',1);

[screen.w screen.rect]=Screen('OpenWindow',0);
interval = Screen('GetFlipInterval', screen.w);
disp(['interval of screen is ', num2str(interval)]);
framerate = Screen('NominalFrameRate', 0);
disp(['NominalFrameRate of the Screen is ', num2str(framerate)]);

[screen.w screen.rect]=Screen('OpenWindow',1);
interval = Screen('GetFlipInterval', screen.w);
disp(['interval of screen is ', num2str(interval)]);
framerate = Screen('NominalFrameRate', 1);
disp(['NominalFrameRate of the Screen is ', num2str(framerate)]);


Screen('CloseAll');


end