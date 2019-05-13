function plot_roi_patch_snap_offset(r, roi_id, snap_id)
% Check whether the estimated offset pruduces the shifted set of
% PixelIdxList and aligns well with the snap image accordingly.

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

padding = 18;

img = r.snaps(:,:,snap_id);

% offset
x = r.roi_shift_snaps.x(snap_id, roi_id); 
y = r.roi_shift_snaps.y(snap_id, roi_id);
fprintf('snap %d offset [x, y] = %.1f, %.1f \n', snap_id, x, y);

% shifted pixel list
pixelIdxList = r.getShiftedPixelList(roi_id, [x, y]);


[patch_img, patch_bw] = utils.getPatchFromPixelList(img, pixelIdxList, padding);

contrast = 0.2;
J = utils.myshow(patch_img, contrast);
%J = utils.myshow(patch_bw, contrast);
hold on

% add contour
visboundaries(patch_bw,'Color','r','LineWidth', 0.7); 

hold off


end