function offset = getSingleImageShift(img1, img2)
% Calculate shift between two 2-dimensional matrices of the same size.
% img1 is original template, img2 is with an offset.
% offset(1, 2) = getSingleImageShift(img1(N, M), img2(N, M))
% by Dongsoo Lee (2019-04-29)
if size(img1) == size(img2)
    [N, M] = size(img1);
    ccmap = xcorr2(img2, img1);      % cc_map(2N-1, 2M-1)
    [idx1, idx2] = find(ccmap == max(max(abs(ccmap))));
    if size(idx1, 1) > 1
        idx1 = N;
        idx2 = M;
    end
    offset = [idx1 - N, idx2 - M];
else
    disp('Dimensions of two matrices should be same! (getSingleImageShift)');
end
end