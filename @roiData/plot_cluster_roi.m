function plot_cluster_roi(r, k, k2)
% Display spatial locations of clustered ROIs
        
        if nargin < 3
            k2 = k;
        end
    
        I = 1:r.numRoi;
        id_cluster = I(r.c == k);
        
        % BW mask for clustered (selected) ROIs
        bw1 = cc_to_bwmask(r.roi_cc, id_cluster);
        
        % Comparison: second cluster as gray
        if k2 ~= k
            bw2 = cc_to_bwmask(r.roi_cc, I(r.c == k2));
            bwmask = bw1 + 0.5 * bw2;
        else
            bwmask = bw1;
        end
        
        imagesc(bwmask, [0 1]);
        colormap gray; 
        hold on
        
        % Contour
        visboundaries(bw1,'Color','r','LineWidth', 0.7); 

        % ROI number display
        s = regionprops(r.roi_cc, 'extrema');
        for ii = 1:numel(s)
           if ismember(ii, id_cluster)
               e = s(ii).Extrema;
               text(e(4,1), e(4,2), sprintf('%d', ii), 'Color', 'r', ... %5th comp: 'bottom-right'
                   'VerticalAlignment', 'bottom', 'HorizontalAlignment','left', 'FontSize',10); 
           end
        end
        hold off
end

function [bw_selected, bw_array] = cc_to_bwmask(cc, id_selected)
% convert cc to bwmask array and totla bw for selected IDs.

    if nargin < 2
        id_selected = 1:cc.NumObjects;
    end

    bw_array = false([cc.ImageSize, cc.NumObjects]);

    for i = 1:cc.NumObjects
        grain = false(cc.ImageSize);
        grain(cc.PixelIdxList{i}) = true;
        bw_array(:,:,i) = grain;
    end
    % Total bw for selected IDs
    bw_selected = max( bw_array(:,:,id_selected), [], 3);
end