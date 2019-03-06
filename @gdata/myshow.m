function J = myshow(g, ch, saturation)
    % contrast-adjusted ch mean image    
    if nargin < 3
        saturation = 1; % contrast saturation [%]
    end
    Tol = [saturation*0.01 1-saturation*0.01];
    %
    if nargin > 1
        A = g.AI_mean{ch};
        A = mat2gray(A);
        MinMax = stretchlim(A, Tol);
        J = imadjust(A, MinMax);
    else
        for ch=g.header.channelSave
            J = g.myshow(ch);
            myfig; imshow(J);
        end
    end
end