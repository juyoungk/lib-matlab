function J = plot_PixelIdxList_patch(img, pixelIdxList, padding)

if nargin < 3
    padding = 18;
end


[patch_img, patch_bw] = utils.getPatchFromPixelList(img, pixelIdxList, padding);

contrast = 0.2;
J = utils.myshow(patch_img, contrast);
hold on

% add contour using patch_bw
visboundaries(patch_bw,'Color','r','LineWidth', 0.7); 


hold off


end