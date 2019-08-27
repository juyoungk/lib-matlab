%
img;

%% image open and close
disk_size = 7;
se = strel('disk', disk_size);

bg_open = imopen(img, se);
bg_close = imclose(img, se);

img_substracted = imtophat(img, se);

img_all = cat(3, img, img_substracted);
img_all = cat(3, img_all, bg_open);

imvol(img_all, 'title', ['disk ',num2str(disk_size)], 'globalContrast', true);

%% Saturated image for getting rid of unusually bright expression.
c_percentage = 0.3;
[J, MinMax] = utils.myadjust(img, c_percentage);
imshow(J)

% BG image 
bg_open = imopen(J, se);
J_substracted = J - bg_open;
%J_substracted = imtophat(J, se);

J = cat(3, J, J_substracted);
J = cat(3, J, bg_open);
imvol(J, 'title', ['disk ',num2str(disk_size)], 'globalContrast', true)



%%
disk_size = 13;
se = strel('disk', disk_size);
bg = imopen(J, se);
imshow(bg)
