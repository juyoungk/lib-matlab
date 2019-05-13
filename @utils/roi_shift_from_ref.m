function roi_shift = roi_shift_from_ref(ref, images, PixelIdxList, roi_ids, padding)
% PixelIdxList - cell array of PixelList

% roi_shift.x(images, roi_ids)
% roi_shift.y(images, roi_ids)

if nargin < 5
    padding = 10;
end

if nargin < 4
    roi_ids = 1:numel(PixelIdxList);
end


% ref image for all rois (cell array)
roi_ref = utils.getPatchesFromPixelLists(ref, PixelIdxList, padding);
                
numImages = size(images, 3);
numRoi = length(roi_ids);

% return struct
roi_shift.x = zeros(numImages, numRoi);
roi_shift.y = zeros(numImages, numRoi);

%

i = 0;

for k = roi_ids
    
    i = i + 1; % current ROI id

    for s = 1:numImages
        
        roi_patch_image = utils.getPatchFromPixelList(images(:,:,s), PixelIdxList{k}, padding);
        
        offset = utils.getSingleImageShift(roi_ref{k}, roi_patch_image);
        roi_shift.x(s, i) = offset(1); 
        roi_shift.y(s, i) = offset(2);
        
    end
    
end


end