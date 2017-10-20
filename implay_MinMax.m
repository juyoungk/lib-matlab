function [] = implay_MinMax(vol, MinMax)

% input 'vol' is [0 1] scaled multi-framed matrix


handle = implay(vol);

handle.Visual.ColorMap.UserRange = 1; 
handle.Visual.ColorMap.UserRangeMin = MinMax(1);
handle.Visual.ColorMap.UserRangeMax = MinMax(2);

end

