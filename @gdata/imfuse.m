function img = imfuse(g, ch1, ch2)
% Create a composite image between channels. ch2 will become a last
% available ch# if not given.
%
% Example 1: Red and Green fluorescence images superimposed on CH 4 gray image (e.g. forward-scattering image)
%           g.imfuse(1, 4)
%           g.imfuse(3, 4)
%           g.imfuse([], 4)
%
% Example 2: imshowpair between ch1 and ch2.
%           g.imdrift(1, 3)
%   
% Display by imshow() in current axes or in new figure.

    if nargin < 3
        ch2 = g.AI_chSave(end);
    end

    if nargin < 2
        ch1 = [];
    end
    
    if ch1 == ch2
        fprintf('imfuse@gdata: same channel (%d) has been selected.', ch1);
        img = [];
        return;
    end
     
    if ch2 == 4
        % superimpose on forward-scattering image
        
        % contrast-adjusted images
        A = g.myshow(1, 0.3); % red channel
        B = g.myshow(3, 0.3);   % green channel
        C = g.myshow(4, 0.2); % background to gray
        
        if isempty(ch1)
            %img = cat(3, max(C, A), max(C, B), C);
            img = cat(3, min(ones(g.size), A+C), min(ones(g.size), B+C), C);
        elseif ch1 == 1
            img = cat(3, min(ones(g.size), A+C), C, C);
        elseif ch1 == 3
            img = cat(3, C, min(ones(g.size), B+C), C);
        else
            error(['not know how to image for ch1: ',num2str(ch1)]);
        end
            
        imshow(img);
        
    else
        % imshowpair 
        
        A = g.myshow(1, 0.8); % red channel
        B = g.myshow(3, 0.8);   % green channel
        C = g.myshow(4, 0.2); % background to gray
        
        img = cat(3, A, B, C);
        
        imshowpair(A, B, 'ColorChannels', [1, 2, 1]); 
        
    end
    
    title(g.ex_name);

end

