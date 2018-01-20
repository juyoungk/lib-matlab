function [J, param] = imvol(vol, varargin)
% imshow() with interactive navigation
% New figure will be created unless fig or axes handles are not given.
% input 'vol' should be image or 3-D matrix
% keypress -> create new figure handle h from imshow. You can't stroe
% information in previous h created by imshow.
% output:
%   param: struct for parameters used for image
    
    p = ParseInput(varargin{:});
    s_title = p.Results.title;
    FLAG_txt = p.Results.verbose;
    hfig = p.Results.hfig;
    ax = p.Results.axes;
    %hfig_sync = p.Results.sync;
    SAVE_png = p.Results.png;
    vol_inputname = inputname(1);
    
    % str of input variable
    if isempty(s_title)
        s_title = vol_inputname;
    end
    
    N = ndims(vol);
    if N > 3
        error('image stack (vol) has too high dims >3');
    elseif N < 2
        error('Not image (ndims <2)');
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
            disp('(imvol) The input fig handle was not appropriate. New figure was created.');
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
    
    % Normalization and get frame numbers
    vol = scaled(vol);
    [rows, cols, n_frames] = size(vol);
    
    % Default parameters
    data.i = 1; % index for stack
    data.imax = n_frames;

    tols = [0, 0.05, 0.1:0.1:0.9, 1:0.2:2, 2.5:0.5:5, 6:1:11, 12:2:20, 25:5:95]; % percentage; tolerance for saturation
    n_tols = length(tols);
    id_tol = 5; % initial tol = 0.05;
    id_add_lower = 1; % initial tol = 0.05;
    
    % sensitivity for adaptive binarization
    sensitivity = 0.25;
    
    % Nested function definition for easy access to stack 'vol'
    function redraw()
        % get focus
        figure(hfig);
        if N == 2
            I = vol;
        else
            I = comp(vol, data.i);
        end
        
        upper = max(1 - tols(id_tol)*0.01, 0);
        lower = min((tols(id_tol) + tols(id_add_lower))*0.01, upper);
        
        Tol = [lower upper];
        MinMax = stretchlim(I,Tol);
        J = imadjust(I, MinMax);
        if ~isempty(ax)
            axes(ax); 
        end
        imshow(J);
        ax = gca;
        title(s_title, 'FontSize', 17, 'Color', 'w');
        % text. where? on the image
        % advantage of text on the image. automatic clear.
        if SAVE_png
            saveas(hfig, [s_title,'_',num2str(data.i),'of',num2str(n_frames),'.png']);
            SAVE_png = false; % save only one time
        end
        
        if FLAG_txt
            str1 = sprintf('low=%.3f upp=%.3f', lower, upper);
            str2 = sprintf('%d/%d', data.i, data.imax);
            %title(str, 'Color', 'w', 'FontSize',17, 'Position', [cols-length(str)-10, 0]);
            
            % x,y for text. Coordinate for imshow is different from plot
            text(ax.XLim(1), ax.YLim(end), str1, 'FontSize', 17, 'Color', 'w', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment','left');
            text(ax.XLim(2), ax.YLim(end), str2, 'FontSize', 17, 'Color', 'w', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
        end
        
        % save image parameters
        param.hfig = hfig;
        param.Tol = Tol;

        % trigger redraw of merged image?
        
    end

    % Update the display of the surface
    redraw();
    
    %
    function keypress(~, evnt)
        % step for tolerance or contrast
        s = 0.1;
        
        switch lower(evnt.Key)
            case 'rightarrow'
                data.i = min(data.i + 1, data.imax); 
            case 'leftarrow'
                data.i = max(1, data.i - 1);
            case 'uparrow'
                id_tol = min(id_tol + 1, n_tols);
            case 'downarrow'
                id_tol = max(1, id_tol - 1); 
            case '1'
                id_add_lower = max(1, id_add_lower - 1); 
            case '2'
                id_add_lower = min(id_add_lower + 1, n_tols);
            case 's'
                SAVE_png = true;
            case 'b' % open binarization figure
                    pos     = get(0, 'DefaultFigurePosition');
                    pos_new = [pos(1)+pos(3) pos(2) pos(3) pos(4)];
                    set(0, 'DefaultFigurePosition', pos_new);
                [~, hfig_b] = myimbinarize(J);
                figure(hfig_b);
                    %set(0, 'DefaultFigurePosition', pos);
            case 'v' % verbose output
                FLAG_txt = ~FLAG_txt;
            case 'q' % default contrast
                id_tol = 5;
                id_add_lower = 1;
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