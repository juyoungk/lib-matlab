function [bw_mask, bw_array] = cc_to_bwmask(cc, ids)
%CC_TO_BWMASK Convert cc to BW (black & white) mask image.
%
% Examples:
%
%       [bw_mask, bw_array] = cc_to_bwmask(cc, ids)
%
%       inputs:
%           cc - Connected components (struct)
%           ids - an array of selected ROI ids. All ROI ids will be selected if
%           not given.
%
%       outputs:
%           bw_mask - Black & white (BW) mask image of selected ROIs.
%           bw_array - 3D BW matrix containing total ROI individual BW images.
%

    if nargin < 2
        ids = 1:cc.NumObjects;
    end

    bw_array = false([cc.ImageSize, cc.NumObjects]);

    for i = 1:cc.NumObjects
        grain = false(cc.ImageSize);
        grain(cc.PixelIdxList{i}) = true;
        bw_array(:,:,i) = grain;
    end
    
    % Total bw for selected IDs
    bw_mask = max( bw_array(:,:,ids), [], 3);
    
end