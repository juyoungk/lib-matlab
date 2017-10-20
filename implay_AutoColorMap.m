function [] = implay_AutoColorMap(image)

m = min(image(:));
M = max(image(:));

image_normalized = (image - m)/(M-m);


handle = implay(image);

handle.Visual.ColorMap.UserRange = 1; 
handle.Visual.ColorMap.UserRangeMin = min(image(:)); 
handle.Visual.ColorMap.UserRangeMax = max(image(:));

end

