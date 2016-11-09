function smoothed = boxfilter(img)
h = fspecial('average', [3 3]);
smoothed = imfilter(img, h,'replicate');
end

