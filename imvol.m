function [J, hfig] = imvol(vol, hfig, varargin)
% imshow() with interactive navigation 
% input 'vol' should be image or 3-D matrix
% keypress -> create new figure handle h from imshow. You can't stroe
% information in previous h created by imshow.
    
    p = ParseInput(varargin{:});
    s_title = p.Results.title;

    N = ndims(vol);
    if N > 3
        error('image stack (vol) has too high dims >3');
    elseif N < 2
        error('Not image (ndims <2)');
    end
    
    [rows, cols, n_frames] = size(vol);
    vol = scaled(vol);
    %
    if (nargin > 1) && ishandle(hfig)
         % do nothing   
    else
        hfig = figure();
            hfig.Color = 'none';
            hfig.PaperPositionMode = 'auto';
            hfig.InvertHardcopy = 'off';   
    end
    
    axes('Position', [0  0  1  0.9524], 'Visible', 'off');
    %ax1 = axes('Position', [0 0.1 1 0.95], 'Visible', 'off');
    %ax1 = axes('Position', [0 0.05 1 0.95], 'Visible', 'off');
    %ax2 = axes('Position', [0.00 0  1 0.1], 'Visible', 'off');
    
    % Set the callback and pass the surf handle
    %set(fig, 'KeyPressFcn', @(fig, evnt)keypress(h, evnt))
    set(hfig, 'KeyPressFcn', @keypress)
    
    % Default parameters
    data.i = 1; % index for stack
    data.imax = n_frames;
    FLAG_txt = true;
 
    tols = [0, 0.05, 0.1:0.1:0.9, 1:0.2:2, 2.5:0.5:5, 6:1:11, 12:2:20, 25:5:95]; % percentage; tolerance for saturation
    n_tols = length(tols);
    id_tol = 5; % initial tol = 0.05;
    id_add_lower = 1; % initial tol = 0.05;
    
    % Nested function definition for easy access to stack 'vol'
    function redraw()
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
        %axes(ax1); 
        imshow(J);
        ax = gca;
        title(s_title, 'FontSize', 17, 'Color', 'y');
        % text. where? on the image
        % advantage of text on the image. automatic clear. 
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

            case 't'
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
    
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end