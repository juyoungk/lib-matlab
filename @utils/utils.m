classdef utils
% collection of (static) functions which wil support gdata and roiData
% classes. Static methods don't need to instantiate on object.
    
    methods (Static)
    % Specify the attributes and define the finction in an separate file.    
    % Do not include 'function' and 'end' keywords.
        
        
        % Get image patch around the given pixel list.
        patch = getPatchFromPixelList(img, pixelIdxList, padding)
        
        % Get image patches (cell array) from pixelIdxList array
        function patches = getPatchesFromPixelLists(img, pixelIdxList, padding)
            R = numel(pixelIdxList);
            patches = cell(1, R);
            for r = 1:R
                patches{r} = getPatchFromPixelList(img, pixelIdxList{r}, padding);
            end
        end
    
        
        % image offset (up to sub-pixel correlation)
        offset = getSingleImageShift(img1, img2)
        
        
        % shifted pixel list by (integer) offset vector
        shiftedPixelIdxList = getShiftedPixelList(pixelIdxList, offset, numRows, numCols)
        
        
    end
end
    