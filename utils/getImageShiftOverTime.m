function shiftIdxOverTime = getImageShiftOverTime(patches_t)
% Calculate 2-dimensional shift of multiple patches the same size over time
% patches are cell array of each time point (t) (original: t=1)
% shiftIdxOverTime(T, P, 2) = getImageShiftOverTime(patches_t(cell arr{T}))
% by Dongsoo Lee (2019-04-29), edited 2019-04-30
T = max(size(patches_t));
P = max(size(patches_t{1}));
shiftIdxOverTime = zeros(T, P, 2);
for t = 1:T
    offset = getImageShift(patches_t{1}, patches_t{t});
    shiftIdxOverTime(t, :, :) = offset;
end
end

function shiftIdx = getImageShift(patches1, patches2)
% Calculate 2-dimensional shift of multiple patches the same size
% patches1 is original template, patches2 is with an offset.
% shiftIdx(P, 2) = getImageShift(patches1(cell arr{P}), patches2(cell arr{P})
% by Dongsoo Lee (2019-04-29)
P = max(size(patches1));
shiftIdx = zeros(P, 2);
for p = 1:P
    offset = getSingleImageShift(patches1{p}, patches2{p});
    shiftIdx(p, :) = offset;
end
end

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