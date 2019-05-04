function patches = getPatchFromPixelList(img, pixelIdxList, padding)
% Get image patches (with padding) from pixel indices. ex) cc.PixelIdxList
% patches(cell arr{R}) = getPatchFromPixelList(img(N, M),
%                                   pixelIdxList(cell arr{R}), padding(int))
% by Dongsoo Lee (19-04-29)
patches = {};
[N, M] = size(img);          % ex)[N, M] = [512 380]
P = padding;
R = max(size(pixelIdxList)); % ROI number
for r = 1:R
    flatten = reshape(zeros(N, M), [N * M, 1]);
    flatten(pixelIdxList{r}) = 1;
    s = regionprops(reshape(flatten, [N, M]), 'BoundingBox');
    ymin = ceil(s.BoundingBox(2));
    ymax = ymin + ceil(s.BoundingBox(4)) - 1;
    xmin = ceil(s.BoundingBox(1));
    xmax = xmin + s.BoundingBox(3) - 1;
    padded = padarray(img, [P, P], 0);
    patches{r} = padded(ymin:ymax + 2*P, xmin:xmax + 2*P);
end
end