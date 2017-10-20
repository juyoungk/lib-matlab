function roi_mean = roi_avg_output(vol_ch_cells, roi_array)
% inputs:
%       1) multi-frame images (vol image or stack) as cell array (channels)
%       2) ROI images as 3-D array
% output:
%       1) avg_output - (roi_id x channel#) cell array 

    n_ch = numel(vol_ch_cells);
    
    % roi reshape
    [~, ~, n_roi] = size(roi_array);
    roi_reshaped = reshape(roi_array, [], n_roi);
    roi_reshaped = logical(roi_reshaped);
    
    % roi -> cell array
    roi_img = cell(n_roi, n_ch);
    roi_mean = cell(n_roi, n_ch);
    
    % Average over individual ROI (cell)
    for j=1:n_ch
        
        vol_ch = vol_ch_cells{j};
        
        if isempty(vol_ch)
            continue;
        end
        
        [~, ~, n_frames_ch] = size(vol_ch);
        vol_ch_reshaped = reshape(vol_ch, [], n_frames_ch);
        
        for i=1:n_roi
            roi_img{i,j} = vol_ch_reshaped(roi_reshaped(:,i), :);
            roi_mean{i,j} = mean(roi_img{i, j}, 1); % mean over rows (pixels in ROI). 
        end
    end
    
end