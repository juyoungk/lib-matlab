function channelcorr(g, ch1, ch2, nframe)
% Cross-channel correlation.

    if nargin < 4
        nframe = min(g.nframe, 100);
        print([nframe, ' was selected for cross-channel correlation.']);
    end
        
    if nargin < 3
        ch2 = 3;
    end

    if nargin < 2
        ch1 = 1;
    end
    
    A = g.AI{ch1};
    A = reshape(A(:,:,1:nframe), [], 1);
    
    B = g.AI{ch2};
    B = reshape(B(:,:,1:nframe), [], 1);
    
    %
    figure;
    scatter(A,B);
   

end

