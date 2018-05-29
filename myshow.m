function [J, handle] = myshow(imgstack, varargin)
%
% imshow for imgage stack [ynum xnum channel]. It also works for 2-D image [ynum xnum].
% scaled, and imshow for given channel #.
% myshow(image)
% myshow(image, ch)
% myshow(image, ch, fraction) % fraction (%) of ourliers for contrast adjust.
% 0.5% is default
% No figure creation. You can use this function with subplot.
% Output: Min Max range for contrast
%
Dim = ndims(imgstack);
nVarargs = numel(varargin);

[ynum, xnum, d3, d4] = size(imgstack);
text = sprintf('[row  col  d3  d4*d5*..] = [%d  %d  %d  %d].  ',ynum,xnum,d3,d4);
fprintf('%s', text);
%disp(text);

if ismatrix(imgstack)
    %disp('2-D image was given.');
    I = scaled(imgstack);
elseif Dim == 3 || Dim == 4
    if nVarargs < 1
        disp('fn: myshow: Many Channels. Channel # should be provided.');
        % Multi-CH imaging
        % 
        return
    end
    % Single ch imaging
    ch = varargin{1};
    img = comp(imgstack,ch);
    %disp('A image stack is given. (3-D or 4-D)');
    %disp(['Channel # = ',num2str(ch)]);
    fprintf('Ch# = %d  ', ch);
    if ~ismatrix(img) % final check
        disp('Incorrect image or image stack.');
    end
    I = scaled(img);
else
    disp('Too large Dimension (>4). Incorrect image or image stack');
    return
end

% percentage for saturation level for top and low pixels.
if nVarargs >= 2
    fraction = varargin{2};
elseif nVarargs >= 1 && Dim ==2
    fraction = varargin{1};
else
    fraction = 0.5; % percentage for saturation level for top and low pixels.
end
Tol = [fraction*0.01 1-fraction*0.01];

if fraction ~= 0.5    
    %disp(['Tol  =  ', num2str(Tol)]);
    fprintf('Tol = [%.3f  %.3f]\n', Tol(1), Tol(2));
else
    fprintf('\n');
end

MinMax = stretchlim(I,Tol);
J = imadjust(I,MinMax);

handle = imshow(J);
%set(gca, 'Color', 'none');

end