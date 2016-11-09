function testscreen

screen = InitScreen(1, 1280, 1024, 75);

% Define the obj Destination Rectangle
objRect = RectForScreen(screen,400,400,0,0);

N =5;

for i=1:20

    objColor = (rand(N, N)>.5)*2*screen.gray;
    objColor = rand(5, 1)*screen.white;

    % texture pointer
    objTex  = Screen('MakeTexture', screen.w, objColor);
    % display last texture
    Screen('DrawTexture', screen.w, objTex, [], objRect, 0, 0);

    %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect]
    %[,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [,
    %modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
    
    Screen('Flip', screen.w, 0);
    
    % pause until Keyboard pressed
    KbWait; [~, ~, c]=KbCheck;  YorN=find(c);
    if YorN==KbName('space'), break; end;
end

Screen('CloseAll');

end