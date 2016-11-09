function [img, tiff] = tiffuiopen
% Direct data import from TIF file
% Open TIFF file in UI dialog box via TIFFStack class
% Output can be integer (uint16) or double.
% Ineger classes are often not supported by some functions.

[name, dir] = uigetfile('*.*');
tiff = TIFFStack([dir, name]);
% sImageInfo;

Dim = ndims(tiff);
if Dim ==2
    disp(['Dim of TIFF image is ',num2str(Dim)]);
    img = tiff(:,:);
elseif Dim ==3
    disp(['Dim of TIFF image is ',num2str(Dim)]);
    img = tiff(:,:,:);
elseif Dim == 4
    disp(['Dim of TIFF image is ',num2str(Dim)]);
    img = tiff(:,:,:,:);
elseif Dim == 5
    disp(['Dim of TIFF image is ',num2str(Dim)]);
    img = tiff(:,:,:,:,:);
else
    disp('Dim of TIFF image is more than 5. Loading failed.');
    img = 0, info = 0;
end

disp([' ']);

end