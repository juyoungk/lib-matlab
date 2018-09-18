function img = imfuse(obj, ch1, ch2, s1, s2)
% Create a composite image in cross-(or identical-)channels between sessions.
%
% e.g.
% Ch1 in laser1 vs Ch2 in laser2
%
% Default channel IDs: 1 and 3 (red and green in Baccus lab upright scope)
% Default session IDs: 1 and 2

if nargin < 4
    % first two sessions
    s1 =1;
    s2 =2;
    disp('fdata: first 2 seesions are chosen for cross-channel images.');
end

% Check if the currennt obj has s1 and s2.
if s1 > obj.numImaging
    error(['No imaging session id ',num2str(s1),' in fdata object']);
end
if s2 > obj.numImaging
    error(['No imaging session id ',num2str(s1),' in fdata object']);
end

%
if nargin < 2
    ch1 = 1;
    ch2 = 3;
end
%
% A = obj.g(s1).AI_mean{ch1};
% B = obj.g(s2).AI_mean{ch2}; 

A = obj.g(s1).myshow(ch1, 0.5);
B = obj.g(s2).myshow(ch2, 1);
%
if isempty(A)
    fprintf('Empty image data on session %d channel %d\n', s1, ch1);
    A = zeros(obj.g(s1).size);
end
if isempty(B)
    fprintf('Empty image data on session %d channel %d\n', s2, ch2);
    B = zeros(obj.g(s2).size);
end

myfig;
% img = merge(A, B);
% imshow(img);

img = cat(3, A, B);
imshowpair(A, B, 'ColorChannels', [1, 2, 1]); 

str = sprintf('Red: %s (ch %d), Green: %s (ch %d)', obj.ex_name{s1}, ch1, obj.ex_name{s2}, ch2);
title(str, 'FontSize', 15, 'Color', 'w');

end

function img = merge(A, B, c_fraction)
% A --> channel 1 (red)   in composite
% B --> channel 2 (green) in composite
    if nargin < 3
        c_fraction = 2;
    end
    Tol = [c_fraction*0.01 1-c_fraction*0.01];
    
    %
    if isempty(A)
        error('input A is empty');
    else
        A = mat2gray(A);
        MinMax = stretchlim(A, Tol);
        A = imadjust(A, MinMax);
    end

    % 
    if isempty(B)
        error('input B is empty');
    else
        B = mat2gray(B);
        MinMax = stretchlim(B, Tol);
        B = imadjust(B, MinMax);
    end
    
    C = zeros(size(A));
    
    img = cat(3, A, B, C);
        
%     if ch == 1
%         img = cat(3, max(A, B), A, A);
%     elseif ch == 3
%         img = cat(3, A, max(A, C), A);
%     else
%         img = cat(3, max(A, B), max(A, C), A);
%     end

end