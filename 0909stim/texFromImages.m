function tex = texFromImages(s, images, patch_size, tex_size, contrast, rs)

if nargin < 6
    rs = 150 % random seed
end;

numimages = numel(images);
patch_size = round(patch_size);
tex_size = round(tex_size);

% Pick one image and rescale (function defined in the below by Lane)
img = rescale(images{randi(rs, numimages)}); 

% image size check
if min(size(img)) < patch_size
    disp('! The chosen image has smaller pixel numbers than wanted image patch. Patch size is adjusted.');
    patch_size = size(img)
end

tex = img2texture(s, img, patch_size, tex_size, contrast, rs);    

end

%         img = rescale(images{randi(rs, numimages)}); % rescale the range of values in image (function defined in the below by Lane)
%         if min(size(img)) <= 2*L_patch_Bg %size check
%             disp('! Natural image for Bg is smaller than 2 times of the patch size needed in pixels. Smaller number of pixels were selected for the patch.');
%             L_patch_Bg = floor(0.5*size(img))
%         end
        %tex_Nat_Bg = img2texture(s, img, L_patch_Bg + maxshift_BgImg, Bg_visiblesize + maxBgshift, me.contrast, rs);

