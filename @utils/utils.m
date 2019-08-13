classdef utils
% collection of (static) functions which wil support gdata and roiData
% classes. Static methods don't need to instantiate on object.
    
    methods (Static)
    % Specify the attributes and define the finction in an separate file.    
    % Do not include 'function' and 'end' keywords.
        
    
        %% Image averaging functions
        % mean images from vol data at trigger times
        [images, times] = mean_images_after_triggers(vol, f_times, trigger_times, duration)
        % mean image of last duration of vol data
        [image, time] = mean_image_last_duration(vol, f_times, duration)
    
        
        %% Image patch out of ROI pixel list struct.
        % Get (Crop) image patch around the given pixel list.
        [patch_img, patch_bw] = getPatchFromPixelList(img, pixelIdxList, padding)
        % visualize
        J = plot_PixelIdxList_patch(img, pixelIdxList, padding)
        
        % Get image patches (cell array) from pixelIdxList array
        function patches = getPatchesFromPixelLists(img, pixelIdxList, padding)
            R = numel(pixelIdxList);
            patches = cell(1, R);
            for r = 1:R
                patches{r} = utils.getPatchFromPixelList(img, pixelIdxList{r}, padding);
            end
        end
    
        
        %% Image offset (up to sub-pixel correlation)
        offset = getSingleImageShift(img1, img2)
        
        %% Shift between ref and images
        roi_shift = roi_shift_from_ref(ref, images, PixelIdxList, roi_ids, padding)
        
        %% x(t), y(t) offset vector --> interger list
        [xlist, ylist] = integer_xy_offset_lists(x_offset, y_offset)
        
        %% Shifted pixel list by (integer) offset vector
        shiftedPixelIdxList = getShiftedPixelList(pixelIdxList, offset, numRows, numCols)
        
        
        %% Visualization tools
        %
        bwmask = pixels_to_bwmask(PixelIdxList, ImageSize)
        %
        [bw_selected, bw_array] = cc_to_bwmask(cc, id_selected)
        %
        function [J, MinMax] = myadjust(I, c)
            % Contrast-enhanced mapping to [0 1] of matrix I
            % Input: contrast value (%)
            I = mat2gray(I); % Normalize to [0 1]. 
            Tol = [c*0.01 1-c*0.01];
            MinMax = stretchlim(I,Tol);
            J = imadjust(I, MinMax);
        end
        %
        function J = myshow(I, c)
            %imshow with contrast value (%)
            if isempty(I)
                J = [];
            else
                if nargin < 2
                    c = 0.2;
                end
                J = utils.myadjust(I, c);
                imshow(J);
            end
        end
        %
         function hf = figure()
            % create figure with appropriate size.
            %pos = get(0, 'DefaultFigurePosition');
            hf = figure;
            hf.Color = 'none';
            hf.PaperPositionMode = 'auto';
            hf.InvertHardcopy = 'off';
            axes('Position', [0  0  1  0.9524], 'Visible', 'off'); % space for title
        end
        
        [N, EDGES] = myhistplot(x, num_bin)
        
    end
end
    