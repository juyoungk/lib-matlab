function make_im_figure(x_shift, y_shift)
    
    if nargin < 2
        y_shift = 0;
    end
    
    if nargin < 1
        x_shift = 0;
    end
    
    pos = get(0, 'DefaultFigurePosition');
    hfig = figure('Position', [pos(1) + x_shift, pos(2) + y_shift, pos(3), pos(4)]);
    
    hfig.Color = 'none';
    hfig.PaperPositionMode = 'auto';
    hfig.InvertHardcopy = 'off';   
    
    axes('Position', [0  0  1  0.9524], 'Visible', 'off'); % space for title
end