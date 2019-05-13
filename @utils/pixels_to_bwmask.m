function bwmask = pixels_to_bwmask(PixelIdxList, ImageSize)
% 
    % cc can be given to ImageSize directly.
    if isstruct(ImageSize) && isfield(ImageSize, 'ImageSize')
        ImageSize = ImageSize.ImageSize;
    end

    bwmask = false(ImageSize);
    bwmask(PixelIdxList) = true;
 
end