function img = imfuse(g, ch1, ch2)
% Create a composite image of CH 1 or 3 (e.g. Red and Green
% fluorescence images) superimposed on CH 4 gray image
% (e.g. forward-scattering image).
%
% If ch is given, superimpose the given channel with 
%
% Display by imshow() in current axes or in new figure.

    if nargin < 3
        ch2 = g.AI_chSave(end);
    end

    if nargin < 2
        ch1 = g.roi_channel;
    end
    
    if ch1 == ch2
        fprintf('imfuse@gdata: same channel (%d)  has been selected.', ch1);
        img = [];
        return;
    end
    
    % contrast-adjusted images
    A = g.myshow(1, 0.2); % red channel
    B = g.myshow(3, 1); % green channel
    C = g.myshow(4, 0.2); % background to gray
    
    
    if (ch1 == 4) || (ch2 == 4)
        % superimpose on forward-scattering image
        
        img = cat(3, max(C, A), max(C, B), C);
        
        imshow(img);
        
    else
        % imshowpair 
        
        img = cat(3, A, B, C);
        
        imshowpair(A, B, 'ColorChannels', [1, 2, 1]); 
        
    end
    
    title(g.ex_name);

end

