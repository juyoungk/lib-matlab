function FOV = FOV_scim(zoom)
%
% FOV of our 2P scope run by Scanimage
% unit: micron
%

% It depends on scan+tube lens setting and objective lens
% 2016 0728 measurement done @ zoom 2
% 40x Zeiss lens, Z = - 8.2
% obj move by 10 um & 2.8 um Iron Oxide particles
nPixels = 256;
One_Pixel_in_Micron = 0.52;

% other measurements:
% nPixels = 256;
% One_Pixel_in_Micron = 0.5;

% FOV @ zoom 2
FOV_Zoom_2 = One_Pixel_in_Micron * nPixels;

% FOV for other zooms
FOV = FOV_Zoom_2 * 2 / zoom;

end