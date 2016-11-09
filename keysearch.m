function keysearch()

keyNum = 0;

while (keyNum~= 27) && (keyNum~= 41)
    % ESC for Mac OS X 10.10 is 41?
    disp('Press any key..ESC key will stop the loop.');
    KbWait(-1, 2); [~, ~, c]=KbCheck;  
    keyNum=find(c)
end


end