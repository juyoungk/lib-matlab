function copyto_clipboard(varargin)

nVarargs = numel(varargin);
if nVarargs >= 1
    hfig = varargin{1}; 
else
    hfig = get(groot,'CurrentFigure');
end

% Transparent background for figure
hfig.Color = 'none';
hfig.PaperPositionMode = 'auto';
hfig.InvertHardcopy = 'off';
% 'on' : automatically changes the background to white for hard copy

editmenufcn(hfig, 'EditCopyFigure');

end
