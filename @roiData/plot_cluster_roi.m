function plot_cluster_roi(r, k, varargin)
% PLOT_CLUSTER_ROI
% Display boundaries of clustered ROIs on real image or Black%White
% gray scsale
% inputs:
%         k - cluster id you want to draw boundaries
%         
% varargin options:
%
%          "compare"    - 0 (default). No comparison. 
%                         1-99 or array (e.g. 1:5)
%           "imageType"    - "image" or "bw"
%           "label"        - True (defualt) or False 
%
        p=ParseInput(varargin{:});
        imageType = p.Results.imageType;
        k2 = p.Results.compare;
        FLAG_label = p.Results.label;
        
        %
        I = 1:r.numRoi;
        id_cluster_k = I(r.c == k);
        bw_k = cc_to_bwmask(r.roi_cc, id_cluster_k); % BW mask for clustered (selected) ROIs
        
        % Comparison: second cluster as gray
        id_k2 = [];
        if sum(k2)>0
            for i = k2
                id_k2 = [id_k2, I(r.c == i)];
            end
            bw2 = cc_to_bwmask(r.roi_cc, id_k2);
            bwmask = bw_k + 0.5 * bw2;
        else
            bwmask = bw_k;
        end
        
        if contains(imageType, 'bw')
            imagesc(bwmask, [0 1]);
            colormap gray;
            axis off;
        elseif contains(imageType, 'image')
            r.myshow;
            
        end
        hold on
        
        % Contour (k cluster only, not k2)
        visboundaries(bw_k,'Color','r','LineWidth', 0.7); 

        % ROI number display
        if FLAG_label
            s = regionprops(r.roi_cc, 'extrema');
            for ii = 1:numel(s)
               if ismember(ii, id_cluster_k)
                   e = s(ii).Extrema;
                   text(e(4,1), e(4,2), sprintf('%d', ii), 'Color', 'r', ... %5th comp: 'bottom-right'
                       'VerticalAlignment', 'bottom', 'HorizontalAlignment','left', 'FontSize',10); 
               end
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


function p =  ParseInput(varargin)
    
    p  = inputParser;   % Create an instance of the inputParser class.
    
    p.addParameter('imageType', 'image', @(x) strcmp(x,'bw') || ...
        strcmp(x,'image'));
    p.addParameter('compare', 0, @(x) isnumeric(x));
    p.addParameter('label', true, @(x) islogical(x));
    
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end