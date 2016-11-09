function [] = implay_AutoColorMap(image)

handle = implay(image);

handle.Visual.ColorMap.UserRange = 1; 
handle.Visual.ColorMap.UserRangeMin = min(image(:)); 
handle.Visual.ColorMap.UserRangeMax = max(image(:));

end

