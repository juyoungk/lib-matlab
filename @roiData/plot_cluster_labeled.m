function bw = plot_cluster_labeled(r)
% Output is BlackWhite image stack (roi x col x cluster-ids)

bw = zeros([r.roi_cc.ImageSize, r.dispClusterNum]);
bw_labeled = false(r.roi_cc.ImageSize);
I = 1:r.numRoi;
%
c_list = unique(r.c(r.c~=0));
%num_cluster = r.dispClusterNum;
num_cluster = numel(c_list);

for k = c_list
    
    id_cluster = I(r.c == k);
    
    % bw to labeled matrix
    bwmask = cc_to_bwmask(r.roi_cc, id_cluster);
    bw_k_labeled = k * bwmask;
    bw_labeled = bw_labeled + bw_k_labeled; 
    
    bw(:,:,k) = bwmask;
end

% figure
hfig = figure;
    hfig.Color = 'none';
    hfig.PaperPositionMode = 'auto';
    hfig.InvertHardcopy = 'off';   
    
%cluster_RGB_label = label2rgb(labeled, @parula, 'k', 'shuffle');
cluster_RGB_label = label2rgb(bw_labeled, @jet, 'k');
cluster_colorbar = label2rgb(1:num_cluster, @jet, 'k');
        
axes('Position', [0  0.1  1  0.8524], 'Visible', 'off');
imshow(cluster_RGB_label);
axes('Position', [0  0  1  0.05], 'Visible', 'off');
imshow(cluster_colorbar);

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