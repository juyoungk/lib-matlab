function makeBlankFigure(mode)
% Create black blank figure
% plot function usually come after this. 

hfig = figure();

hfig.Color = 'none';
hfig.PaperPositionMode = 'auto';
hfig.InvertHardcopy = 'off';   
axes('Position', [0  0  1  0.9524], 'Visible', 'off');

end