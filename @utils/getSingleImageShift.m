function offset = getSingleImageShift(img1, img2, resize_factor)
% Calculate shift between two 2-dimensional matrices of the same size.
% img1 is original template, img2 is with an offset.
% offset(1, 2) = getSingleImageShift(img1(N, M), img2(N, M), resize_factor(int))
% by Dongsoo Lee (2019-04-29), edited 2019-05-04
%
% nargin added 19-05-06 Juyoung

if nargin < 3
    resize_factor = 5;
end
    
if size(img1) == size(img2)
    [N, M] = size(img1);
    ccmap = xcorr2(imresize(img2, resize_factor), imresize(img1, resize_factor));      % ccmap(2*resize*N-1, 2*resize*M-1)
    [idx1, idx2] = find(ccmap == max(max(abs(ccmap))));
    if size(idx1, 1) > 1
        idx1 = idx1(1);
        idx2 = idx2(1);
    end
    offset = [idx1/resize_factor - N, idx2/resize_factor - M];
else
    disp('Dimensions of two matrices should be same! (getSingleImageShift)');
end
end