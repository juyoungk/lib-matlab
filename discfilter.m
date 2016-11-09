function smoothed = discfilter(img)
H = fspecial('disk', 1);
smoothed = imfilter(img, H,'replicate');
end