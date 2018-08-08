function [hfig] = imvol2(vol, varargin)
% imshow() with interactive navigation 
% input 'vol' should be image or 3-D matrix
% keypress -> create new figure handle h from imshow. You can't stroe
% information in previous h created by imshow.
% output:
%   hfig: contains all data including handle.
    
    p = ParseInput(varargin{:});
    hfig = p.Results.hfig;
    ax = p.Results.axes;
    %hfig_sync = p.Results.sync;
    g.s_title = p.Results.title;
    g.FLAG_txt = p.Results.verbose;
    g.SAVE_png = p.Results.png;
    g.hfig_merge = p.Results.hfig_merge;
    vol_inputname = inputname(1);
    
    % str of input variable
    if isempty(g.s_title)
        g.s_title = vol_inputname;
    end
    
    N = ndims(vol);
    if N > 3
        error('image stack (vol) has too high dims >3');
    elseif N < 2
        error('Not image (ndims <2)');
    end
    % Normalization and get frame numbers
    vol = scaled(vol);
    [rows, cols, n_frames] = size(vol);
    
    % Figure setting
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
    
    % Default parameters
    g.vol = vol;
    g.i = 1; % index for stack
    g.imax = n_frames;

    g.tols = [0, 0.05, 0.1:0.1:0.9, 1:0.2:2, 2.5:0.5:5, 6:1:11, 12:2:20, 25:5:95]; % percentage; tolerance for saturation
    g.n_tols = length(g.tols);
    g.id_tol = 5; % initial tol = 0.05;
    g.id_add_lower = 1; % initial tol = 0.05;
    
    % assign data in figure handle
    hfig.UserData = g;    
    
    % Set the callback on figure (,not an axes which is created and refreshed by imshow) 
    %set(fig, 'KeyPressFcn', @(fig, evnt)keypress(h, evnt))
    set(hfig, 'KeyPressFcn', @keypress)
    
    % Update the display of the surface
    redraw(hfig);
    
end

function keypress(hfig, evnt)
        
        g = hfig.UserData;
        
        switch lower(evnt.Key)
            case 'rightarrow'
                g.i = min(g.i + 1, g.imax); 
            case 'leftarrow'
                g.i = max(1, g.i - 1);
            case 'uparrow'
                g.id_tol = min(g.id_tol + 1, g.n_tols);
            case 'downarrow'
                g.id_tol = max(1, g.id_tol - 1); 
            case '1'
                g.id_add_lower = max(1, g.id_add_lower - 1); 
            case '2'
                g.id_add_lower = min(g.id_add_lower + 1, g.n_tols);
            case 's'
                g.SAVE_png = true;
            case 'v' % verbose output
                g.FLAG_txt = ~g.FLAG_txt;
            case 'q' % default contrast
                g.id_tol = 5;
                g.id_add_lower = 1;
            otherwise
                return;
        end
        
        redraw(hfig);
        if g.hfig_merge
            %redraw(g.hfig_merge);
            % call one of the callback Fcn of merge figure handle.
            g.hfig_merge.KeyPressFcn(0,0);
        end
        hfig.UserData = g;     
end


function redraw(hfig)
        % get focus to figure
        figure(hfig);
        ax = findall(gcf, 'Type', 'axes');
        %
        g = hfig.UserData;
        %
        tols   = g.tols;
        id_tol = g.id_tol;
        id_add_lower = g.id_add_lower;
        %
        N = ndims(g.vol);
        if N == 2
            I = g.vol;
        else
            I = comp(g.vol, g.i);
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
        %ax = gca;
        title(g.s_title, 'FontSize', 17, 'Color', 'w');
        % text. where? on the image
        % advantage of text on the image. automatic clear.
        if g.SAVE_png
            saveas(hfig, [s_title,'.png']);
            g.SAVE_png = false; % save only one time
        end
        
        if g.FLAG_txt
            str1 = sprintf('low=%.3f upp=%.3f', lower, upper);
            str2 = sprintf('%d/%d', g.i, g.imax);
            %title(str, 'Color', 'w', 'FontSize',17, 'Position', [cols-length(str)-10, 0]);
            
            % x,y for text. Coordinate for imshow is different from plot
            text(ax.XLim(1), ax.YLim(end), str1, 'FontSize', 17, 'Color', 'w', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment','left');
            text(ax.XLim(2), ax.YLim(end), str2, 'FontSize', 17, 'Color', 'w', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
        end
        
        % save image parameters
        hfig.UserData = g;
end


function p =  ParseInput(varargin)
    
    p  = inputParser;   % Create an instance of the inputParser class.
    
    addParamValue(p,'title', []);
    addParamValue(p,'hfig', []);
    addParamValue(p,'hfig_merge', []);
    addParamValue(p,'axes', []);
    %addParamValue(p,'sync', []);
    addParamValue(p,'verbose', true, @(x) islogical(x));
    addParamValue(p,'png', false, @(x) islogical(x));
    
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end