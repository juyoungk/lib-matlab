function cc(varargin)
% Copy Figure to clipboard
%

% figure handle for current figure
hfig = get(groot,'CurrentFigure');
% Transparent background for figure
% fig = gcf;
hfig.Color = 'none';
hfig.PaperPositionMode = 'auto';
hfig.InvertHardcopy = 'off';
% 'on' : automatically changes the background to white for hard copy

editmenufcn(hfig, 'EditCopyFigure');


end
