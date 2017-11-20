function [C] = imvolmerge(vol1, vol2, varargin)
% inputs:
%           imvolmerge(vol1, vol2)
%           imvolmerge(vol{ch1, ch2}) - in the future

    p = ParseInput(varargin{:});
    s_title = p.Results.title;
    hfig = p.Results.hfig;
    SAVE_png = p.Results.png;

    % Create figure for merged image
    if ishandle(hfig)
        % do nothing or give focus to
        figure(hfig);
    else
        if ~isempty(hfig)
            disp('(imvol) The input fig handle was not appropriate. New figure was created.');
        end
        pos     = get(0, 'DefaultFigurePosition');
        hfig = figure('Position',[pos(1)+pos(3)+100, pos(2), pos(3)*3, pos(4)]);
    end
    hfig.Color = 'none';
    hfig.PaperPositionMode = 'auto';
    hfig.InvertHardcopy = 'off';
    % extend current axes to full canvas
    axes('Position', [0  0  1  0.9524], 'Visible', 'off');
    
    % Set the callback
    set(hfig, 'WindowKeyPressFcn', @keypress);

    % children figures inside parent figure
    ax1 = subplot(1, 3, 1); % 1 by 2, select 1. subplot creats axes if it doesn't exist.
    ax2 = subplot(1, 3, 2);

    [A, param1] = imvol(vol1,'axes', ax1);
    [B, param2] = imvol(vol2,'axes', ax2); 
    
    function redraw()
        A = getimage(ax1);
        B = getimage(ax2);
        %figure(hfig); % give focus to parent figure
        subplot(1, 3, 3);
        [C, ~] = imfuse(A,B,'ColorChannels',[2 1 0]);
        imshow(C);
    end
    
    % update image
    redraw();

    function keypress(~, evnt)
            
            redraw();
    end

end


function p =  ParseInput(varargin)
    
    p  = inputParser;   % Create an instance of the inputParser class.
    
    addParamValue(p,'title', []);
    addParamValue(p,'hfig', []);
    addParamValue(p,'verbose', true, @(x) islogical(x));
    addParamValue(p,'png', false, @(x) islogical(x));
    
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end