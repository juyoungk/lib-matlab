function [in, h] = ellipseRoi(img, varargin)
%
% Select elliptical ROI from an image
% No image, No confirmation.
%
% output in : 2-D logical array
% Let's make logical matrix which indicates whether each pixel is inside or
% outside. Then, reshape!

% nVarargs = numel(varargin);
% if nVarargs == 1
    %figure('position', [185, 400, 840, 700])
    %img = varargin{1};  
%end

%myshow(img);
%
h = imellipse;
if isempty(h)
   error('ellipseRoi: ROI is not selected'); 
end
pos = getPosition(h); pos = double(pos);
%
xmin = pos(1);
ymin = pos(2);
width = pos(3);
height = pos(4);
a = width/2;
b = height/2;
x0 = xmin + a;
y0 = ymin + b;
[row, col] = size(img);

% ellipse mask
distX = (1:col) - x0;
distY = (1:row) - y0;
[x, y] = meshgrid(distX, distY);
in = ((x/a).^2+(y/b).^2) <= 1;

% confirm the area of logical area (in) 
% C = merge(img, in); imshow(C);

end


