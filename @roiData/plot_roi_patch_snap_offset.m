function plot_roi_patch_snap_offset(r, roi_id, snap_id, NO_SHIFT)
% Apply shifted roi pixellist. 
% Check whether the shifted (or offset) roi pixellist 
% aligns well with the snap image accordingly.
%
% inputs: 
%
%       NO_SHIFT - if true, 


if nargin < 4
    NO_SHIFT = false;
end

if nargin < 3
    snap_id = 1;
    disp('The first snap is selected.');
end

if snap_id > size(r.snaps, 3)
    error('Too large index for snap images.');
end

if roi_id > r.numRoi
    error('roi id is out of range.');
end

padding = 20;

img = r.snaps(:,:,snap_id);

% offset
x = r.roi_shift_snaps.x(snap_id, roi_id); 
y = r.roi_shift_snaps.y(snap_id, roi_id);
fprintf('snap %d offset [x, y] = %.1f, %.1f \n', snap_id, x, y);

% shifted pixel list
if NO_SHIFT
    pixelIdxList = r.getShiftedPixelList(roi_id, [0, 0]);
    fprintf('Original roi pixellist is selected (NO_SHIFT option).\n');
else
    pixelIdxList = r.getShiftedPixelList(roi_id, [x, y]);
end

[patch_img, patch_bw] = utils.getPatchFromPixelList(img, pixelIdxList, padding);

% Plot
contrast = 0.2;
utils.myshow(patch_img, contrast);
%utils.myshow(patch_bw, contrast);
hold on

% Add contour
visboundaries(patch_bw,'Color','r','LineWidth', 1.7); 

hold off


end