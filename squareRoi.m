function [in, h, pos] = squareRoi(img, varargin)
%
% sqaureRoi(img, varargin)
%
% input: 
%       img - image data (2-D)
%
% output in : 2-D logical array
% Let's make logical matrix which indicates whether each pixel is inside or
% outside. Then, reshape!

% nVarargs = numel(varargin);
% if nVarargs == 1
    %figure('position', [185, 400, 840, 700])
    %img = varargin{1};  
%end

%myshow(img, 2); % 2% outliers.
%
h = imrect; 

if isempty(h)
   error('squareRoi: ROI is not selected'); 
end

pos = getPosition(h); pos = double(pos);
%
xmin = pos(1);
ymin = pos(2);
width = pos(3);
height = pos(4);
    % redefine pos
    % for roi labeling in multiRoi function
    %pos = [xmin+width, ymin+height]; 
%
a = width/2;
b = height/2;
x0 = xmin + a;
y0 = ymin + b;
[row, col] = size(img);
%
% square mask (test)
in_x = 1:col>=xmin & 1:col<=(xmin+width); % For x, col number should be used.
in_y = 1:row>=ymin & 1:row<=(ymin+height);% For y, row number should be used.
[x, y] = meshgrid(in_x, in_y);
in = x & y;

% confirm the area of logical area (in) 
%C = merge(img, in); imshow(C);

end


