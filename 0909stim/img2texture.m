function tex = img2texture(s, img, patch_size, tex_size, contrast, rs)       
%
% Take a subpart of the image, then resize, make a texture at the window object with a given
% contrast
%
% s.window, s.color.gray should be defined. 

% patch_size = [x y]
% tex_size = [x y]

if nargin < 6
    rs = 150 % random seed
end;

row = max(randi(rs, size(img,1) - patch_size), 1);    % if shift is larger than img size, col = 1
col = max(randi(rs, size(img,2) - patch_size), 1);
row_end = min(row + patch_size(2) - 1, size(img,1));
col_end = min(col + patch_size(1) - 1, size(img,2));

rowPixels = row:row_end;
colPixels = col:col_end;
patch = 2 * img(rowPixels, colPixels) * contrast + (1 - contrast);
patch_res = imresize(patch, [tex_size(2) tex_size(1)]); %[row col]
tex = Screen('MakeTexture', s.window, s.color.gray * patch_res);

end

% row = max(randi(rs, size(img,1) - maxshift_BgImg), 1);    % if shift is larger than img size, col = 1
% col = max(randi(rs, size(img,2) - maxshift_BgImg), 1);
% rowPixels = row:(row + L_patch_Bg(2) - 1 + maxshift_BgImg);
% colPixels = col:(col + L_patch_Bg(1) - 1 + maxshift_BgImg);
% patch = 2 * img(rowPixels, colPixels) * me.contrast + (1 - me.contrast);
% patch_resizeToBg = imresize(patch, [Bg_visiblesize + maxBgshift, Bg_visiblesize + maxBgshift]);
% tex_Natural_Bg = Screen('MakeTexture', s.window, gray * patch_resizeToBg);