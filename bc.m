function bc(varargin)
%
% Copy Figure to clipboard for black background
% See also the function 'cc' for just copying the figure to the clipboard
% 
%
h = makeFigBalck();

editmenufcn(h, 'EditCopyFigure');


end
