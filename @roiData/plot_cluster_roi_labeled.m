function bw = plot_cluster_roi_labeled(r, c_list, varargin)
%PLOT_CLUSTER_ROI_LABELED(c_list)
%
% 1. Display color-coded clustered ROI locations in current axes or in new
% figure
% 2. Output is BlackWhite image stack (roi x col x cluster-ids)

if nargin < 2
    c_list = unique(r.c(r.c~=0));
end

p=ParseInput(varargin{:});
BACKGROUND = p.Results.background;
FIGURE = p.Results.figure;

c_max = max(r.c(r.c~=0));
c_num = length(c_list);

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

% labeled RGB image by cluster id
%rgb = label2rgb(labeled, @parula, 'k', 'shuffle');
rgb = label2rgb(bw_labeled, jet(c_max), 'k'); % @jet

% Add background
if BACKGROUND
    % contrast-enhanced mapping of I to [0 1].
    % saturation level is a second variable.
    image = utils.myadjust(r.image, 0.05); 
    % conversion to uint8
    image = 255*image;
    image = uint8(image);
    image = cat(3, image, image, image);
    image(rgb>0) = 0;
    rgb = max(rgb, image);
end

if FIGURE
    % Plot color-coded cluster locations with colorbar in a new figure
    hfig = figure('Position', [1500, 250, 835, 980], 'Name', ['Cluster ', num2str(c_list), ' (total ', num2str(c_num), ' clusters)']);
    hfig.Color = 'none';
    hfig.PaperPositionMode = 'auto';
    hfig.InvertHardcopy = 'off';
    hfig.Position(4) = hfig.Position(3); % square figure size

    % Horizontal colorbar
    %cluster_colorbar = label2rgb(sort(c_list)-min_cluster+1, jet(c_max), 'k');
    cluster_colorbar = label2rgb(sort(c_list), jet(c_max), 'k');

    % Vertical colorbar
    cluster_colorbar = label2rgb(sort(c_list).', jet(c_max), 'k');

    %axes('Position', [0  0  1  1], 'Visible', 'off');
    axes('Position', [0  0  0.94  1], 'Visible', 'off');
    imshow(rgb);

    ax = axes('Position', [0.94  0  0.03  1], 'YAxisLocation', 'right', 'color', 'white');
    imshow(cluster_colorbar);
    text(ax.XLim(end)+0.2, 1, num2str(min(c_list)), 'FontSize', 14, 'Color', 'w',...
        'VerticalAlignment','middle', 'HorizontalAlignment', 'left');
    text(ax.XLim(end)+0.2, c_num, num2str(max(c_list)), 'FontSize', 14, 'Color', 'w',...
        'VerticalAlignment','middle', 'HorizontalAlignment', 'left');
else
    % display rgb only without colorbar
    imshow(rgb);
end
    
    
    
end

function [bw_selected, bw_array] = cc_to_bwmask(cc, id_selected)
% convert cc to bwmask array and total bw for selected IDs.

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

function p =  ParseInput(varargin)
    
    p  = inputParser;   % Create an instance of the inputParser class.
    
    p.addParameter('background', true, @(x) islogical(x));
    p.addParameter('figure', true, @(x) islogical(x));
    
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end