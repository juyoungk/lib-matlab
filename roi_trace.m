function roi_mean = roi_trace(vol_ch, cc)
% inputs:
%       1) multi-frame images (vol image or stack). Channels as cell array.
%       2) cc: struct for connected components in binarized image or ROI
% output:
%       1) avg_output - (roi_id x channel#) cell array 

    n_ch = numel(vol_ch);
    n_roi = cc.NumObjects;
    
    % roi -> cell array
    roi_mean = cell(n_roi, n_ch);
    
    % Average over individual ROI (cell)
    for j=1:n_ch
        
        vol = vol_ch{j};
        
        if isempty(vol)
            continue;
        end
        
        [~, ~, n_frames_ch] = size(vol);
        vol_reshaped = reshape(vol, [], n_frames_ch);
        
        for i=1:n_roi
            roi_mean{i,j} = mean(vol_reshaped(cc.PixelIdxList{i},:),1);
            %roi_mean{i,j} = mean(vol(cc.PixelIdxList{i})); % mean over rows (pixels in ROI). 
        end
    end
    
end