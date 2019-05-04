function [pixelIdxList_t, shiftIdxOverTime] = getShiftedPixelListOverTime(images, pixelIdxList, padding)
% Compute image shift indices over time and return shifted pixel list.
% pixelIdxList_t(cell arr{T}), shiftIdxOverTime(T, P, 2) = % numFrames, 
%                       getShiftedPixelListOverTime(
%                                           images(N, M, T),
%                                           pixelIdxList(cell arr{R}),
%                                           padding(int))
% by Dongsoo Lee (19-04-29), edited 19-05-01
[N, M, T] = size(images);
patches_t = {};

for t = 1:T
    patches_t{t} = getPatchFromPixelList(squeeze(images(:, :, t)), pixelIdxList, padding);
end

shiftIdxOverTime = getImageShiftOverTime(patches_t); %(T, P, 2)
P = size(shiftIdxOverTime, 2);
pixelIdxList_t = {};

for t = 1:T
    for p = 1:P
        pixelIdxList_t{t}{p} = getShiftedPixelList(pixelIdxList{p}, shiftIdxOverTime(t, p, :), N, M);
    end
end

end



function shiftedPixelIdxList = getShiftedPixelList(pixelIdxList, offset, N, M)
% Compute shifted pixel List (linear index) from pixel List and offset.
% image size should be given. N, M
% shiftedPixelIdxList(px, 1) = getShiftedPixelList(pixelIdxList(px, 1),
%                                                       offset(2, 1)
% by Dongsoo Lee (19-04-29), edited 19-04-30
[idx1, idx2] = ind2sub([N, M], pixelIdxList);
idx1 = idx1 + offset(1);
idx2 = idx2 + offset(2);
idx = [idx1, idx2];
idx = idx(any(idx1>0, 2) & any(idx1<=N, 2) & any(idx2>0, 2) & any(idx2<=M, 2), :);
shiftedPixelIdxList = sub2ind([N, M], idx(:, 1), idx(:, 2));
%shiftedPixelIdxList = shiftedPixelIdxList(any(shiftedPixelIdxList>0, 2) & any(shiftedPixelIdxList<N*M, 2));
end