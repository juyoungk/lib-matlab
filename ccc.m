function ccc(varargin)
% Copy Figure to clipboard
%

% figure handle for current figure
hfig = get(groot,'CurrentFigure');
% Transparent background for figure
% fig = gcf;

s = input('InvertHardcopy ? [off] ', 's'); 
if isempty(s)
    hfig.InvertHardcopy = 'off';
elseif contains(s, 'off')
    hfig.InvertHardcopy = 'off';
elseif contains(s, 'on')
    % 'on' : automatically changes the background to white for hard copy
    hfig.InvertHardcopy = 'on';
else
    disp('No appropriate inputs.');
end

hfig.Color = 'white';
hfig.PaperPositionMode = 'auto';


editmenufcn(hfig, 'EditCopyFigure');


end
