function makeFigTransparent(hfig)

if nargin <1
    hfig = get(groot,'CurrentFigure');
end

% Transparent background for figure
hfig.Color = 'none';
hfig.PaperPositionMode = 'auto';
hfig.InvertHardcopy = 'off';

end