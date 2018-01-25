function [bw_array, bw_hole_filled] = cc_to_bwmask(cc)
% convert cc to bwmask

bw_array = false([cc.ImageSize, cc.NumObjects]);
bw_hole_filled = false([cc.ImageSize, cc.NumObjects]);

% cc_filled = regionprops(cc, 'FilledImage');
% bbox = regionprops(cc, 'BoundingBox'); %upper-left corner


for i = 1:cc.NumObjects
    grain = false(cc.ImageSize);
    grain(cc.PixelIdxList{i}) = true;
    bw_array(:,:,i) = grain;
    
    grain_filled = imfill(grain, 'holes');
    bw_hole_filled(:,:,i) = grain_filled;
    
end

end