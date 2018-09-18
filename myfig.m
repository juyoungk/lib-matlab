function hfig = myfig(pos, hfig)
% setting for new figure for image analysis
% if figure handle is given, setting can change the given figure.
% input:
%       pos - position col vector for figure. See figure reference page.

if nargin < 2
    % No input for fig handle
    hfig = [];
end

if nargin < 1
    % No input for fig pos 
    pos = get(0, 'DefaultFigurePosition');
end

% 
if ishandle(hfig)
    % if fig handle is given, give focus to the figure.
    figure(hfig);
    hfig.Position = pos;
else
    hfig = figure('Position', pos);
end

hfig.Color = 'none';
hfig.PaperPositionMode = 'auto';
hfig.InvertHardcopy = 'off';   
axes('Position', [0  0  1  0.9524], 'Visible', 'off');
    
end