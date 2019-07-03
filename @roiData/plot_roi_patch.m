function J = plot_roi_patch(r, roi_id, padding)
% Draw roi boundary with cropped image of "snap_ref" (no shift).

if nargin < 3
    padding = 18;
end

if roi_id > r.numRoi
    error('roi id is out of range.');
end

img = r.snap_ref;
img = r.snaps(:,:,2);
pixelIdxList = r.roi_cc.PixelIdxList{roi_id};

[patch_img, patch_bw] = utils.getPatchFromPixelList(img, pixelIdxList, padding);

% you can get new pixellist from patch_bw.


contrast = 0.4;
J = utils.myshow(patch_img, contrast);
%J = utils.myshow(patch_bw, contrast);
hold on

% add contour
visboundaries(patch_bw,'Color','r','LineWidth', 0.6); 

hold off


end