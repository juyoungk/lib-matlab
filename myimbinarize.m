function [cc, hfig] = myimbinarize(J, varargin)
% Create imbinarize image with interactive adjustment of sensitivity
% New figure will be created unless fig or axes handles are not given.
% TIP for heterogeneous size dist: 
%   Saturate high & low pixels. 
%
% output:
%
    
    %default values
    sensitivity_0 = 0.25;
    P_connected_0 = 25; % depending on magnification (zoom) factor
    bw = []; % binary b&w image (for global variable)
    cc = [];
    
    p = ParseInput(varargin{:});
    s_title = p.Results.title;
    hfig = p.Results.hfig;
    ax = p.Results.axes;
    %hfig_sync = p.Results.sync;
    SAVE_png = p.Results.png;
    FLAG_txt = p.Results.verbose;
    FLAG_remove_small = false;
    
    % str of input variable
    if isempty(s_title)
        s_title = inputname(1);
    end
    
    if ishandle(hfig)
        % if fig handle is given, give focus to the figure.
        figure(hfig);
    elseif ishandle(ax)
        % if axes handle is given, figure out the container handle.
        axes(ax);
        hfig = ax.Parent;
    else
        if ~isempty(hfig)
            disp('(my im binarize) The input fig handle was not appropriate. New figure was created.');
        end
        hfig = figure();
    end
    hfig.Color = 'none';
    hfig.PaperPositionMode = 'auto';
    hfig.InvertHardcopy = 'off';   
    axes('Position', [0  0  1  0.9524], 'Visible', 'off');
    
    % Set the callback on figure
    %set(fig, 'KeyPressFcn', @(fig, evnt)keypress(h, evnt))
    set(hfig, 'KeyPressFcn', @keypress)
    
    % sensitivity for adaptive binarization
    [y, x] = size(J); 
    sensitivity = sensitivity_0;
    P_connected = P_connected_0; % depending on magnification (zoom) factor
    
    function redraw()
        % get focus
        figure(hfig);
        
        bw = imbinarize(J, 'adaptive', 'Sensitivity', sensitivity);

        if FLAG_remove_small
            bw = bwareaopen(bw, P_connected);
        end
        
        if ~isempty(ax) % if ax exists, focus ax.
            axes(ax); 
        end
        
        imshow(bw);
        
        ax = gca;
        
        title(s_title, 'FontSize', 17, 'Color', 'w');
        % text. where? on the image
        % advantage of text on the image. automatic clear.
        if SAVE_png    
            saveas(hfig, [s_title,'.png']);
            SAVE_png = false; % save only one time
        end
        
        if FLAG_txt
            str1 = sprintf('Sensitivity=%.2f P_conn=%.2f', sensitivity, P_connected);
            % x,y for text. Coordinate for imshow is different from plot
            text(ax.XLim(1), ax.YLim(end), str1, 'FontSize', 17, 'Color', 'w', ...
                'VerticalAlignment', 'top', 'HorizontalAlignment','left');
        end
        
    end

    % Update the display of the surface
    redraw();
    
    %
    function keypress(~, evnt)
        % step for tolerance or contrast
        s = 0.05;
        s_pixel = 5;
        
        switch lower(evnt.Key)
            case 'rightarrow'
                sensitivity = min(sensitivity + s, 1); 
            case 'leftarrow'
                sensitivity = max(0, sensitivity - s); 
            case 'uparrow' % ignore disconnected dots. remove noise.
                P_connected = P_connected + s_pixel;
            case 'downarrow'
                P_connected = max(0, P_connected - s_pixel);
            case 'space'
                FLAG_remove_small = ~FLAG_remove_small;
            case 'm' % merge with bw
            
            case 'c'
                cc = bwconncomp(bw, 4);
                labeled = labelmatrix(cc);
                %RGB_label = label2rgb(labeled, @spring, 'c', 'shuffle');
                RGB_label = label2rgb(labeled);
                figure; imshow(RGB_label);
                
            case 's'
                SAVE_png = true;
            
            case 'v' % verbose output
                FLAG_txt = ~FLAG_txt;
                
            case 'q' % default contrast
                sensitivity = sensitivity_0;
                P_connected = P_connected_0;
            otherwise
                return;
        end

        redraw();
    end
end

function p =  ParseInput(varargin)
    
    p  = inputParser;   % Create an instance of the inputParser class.
    
    addParamValue(p,'title', []);
    addParamValue(p,'hfig', []);
    addParamValue(p,'axes', []);
    %addParamValue(p,'sync', []);
    addParamValue(p,'verbose', true, @(x) islogical(x));
    addParamValue(p,'png', false, @(x) islogical(x));
    
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end