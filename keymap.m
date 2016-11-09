function num = keymap(str)
% Use KbName??
KbName('UnifyKeyNames');

right_arrow = 79; % Mac OS X 10.10

switch str
    case 'Right Arrow'
        num = right_arrow;
    case 'Left Arrow'
        num = right_arrow + 1;
    case 'Down Arrow'
        num = right_arrow + 2;
    case 'Up Arrow'
        num = right_arrow + 3;
    case 'Space'
        num = 44;
    case 'ESC'
        num = 41;
    otherwise
        disp('No number for the input key')
end


end