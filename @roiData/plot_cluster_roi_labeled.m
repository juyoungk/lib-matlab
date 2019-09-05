function bw = plot_cluster_roi_labeled(r, c_list)
%PLOT_CLUSTER_ROI_LABELED(c_list)
%
% 1. Display color-coded clustered ROI locations
% 2. Output is BlackWhite image stack (roi x col x cluster-ids)

if nargin < 2
    c_list = unique(r.c(r.c~=0));
end

c_max = max(r.c(r.c~=0));

if c_max < 1
    error('Max cluster id is 0. Not clustered yet or no cluster info.');
end

%
bw = zeros([r.roi_cc.ImageSize, r.dispClusterNum]);
bw_labeled = false(r.roi_cc.ImageSize);
I = 1:r.numRoi;

for k = c_list
    
    id_cluster = I(r.c == k);
    
    % bw to labeled matrix
    bwmask = cc_to_bwmask(r.roi_cc, id_cluster);
    
    bw_k_labeled = k * bwmask;
    
    %bw_labeled = bw_labeled + bw_k_labeled; 
    % For overlapped ROIs
    bw_labeled = max(bw_labeled, bw_k_labeled);
    
    bw(:,:,k) = bwmask;
end

% figure
hfig = figure('Name', ['Cluster ',num2str(c_list)]);
    hfig.Color = 'none';
    hfig.PaperPositionMode = 'auto';
    hfig.InvertHardcopy = 'off';
    hfig.Position(4) = hfig.Position(3); % square figure size
    
%cluster_RGB_label = label2rgb(labeled, @parula, 'k', 'shuffle');
cluster_RGB_label = label2rgb(bw_labeled, jet(c_max), 'k'); % @jet
%cluster_colorbar = label2rgb(sort(c_list)-min_cluster+1, jet(c_max), 'k');
cluster_colorbar = label2rgb(sort(c_list), jet(c_max), 'k');


%axes('Position', [0  0.1  1  0.8524], 'Visible', 'off');
axes('Position', [0  0  1  1], 'Visible', 'off');
imshow(cluster_RGB_label);

% axes('Position', [0  0  1  0.05], 'Visible', 'off');
% imshow(cluster_colorbar);

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