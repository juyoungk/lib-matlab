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