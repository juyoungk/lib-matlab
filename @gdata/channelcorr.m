function channelcorr(g, ch1, ch2, nframe)
% Cross-channel correlation of pixel values.
    
    if length(g.AI_chSave) < 2
        str = ['Only one channel available: ', num2str(g.AI_chSave)];
        error(str);
    end
    
    if nargin < 4
        nframe = min(g.nframes, 60);
        print([num2str(nframe), ' was selected for cross-channel correlation.']);
    end
        
    if nargin < 3
        ch2 = g.AI_chSave(2);
    end

    if nargin < 2
        ch1 = g.AI_chSave(1);
    end
    
    A = g.AI{ch1};
    A = reshape(A(:,:,1:nframe), [], 1);
    
    B = g.AI{ch2};
    B = reshape(B(:,:,1:nframe), [], 1);
    
    %
    figure;
    scatter(A,B);
   

end

