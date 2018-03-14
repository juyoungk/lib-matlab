function [hfig] = imvol(vol, varargin)
% imshow() with interactive navigation for stack and ROI selection
% Scale bar for x25 leica obj
% New figure will be created unless fig or axes handles are not given.
% input 'vol' should be image or 3-D matrix
%
% options:
%       'roi'    - predefined cc structure for ROI mode
%       'ex_str' - name string for experiment 
% output:
%       hfig - ROI data will be saved in UserData field.
%               (hfig.UserData.cc)
    
    p = ParseInput(varargin{:});
    pos = get(0, 'DefaultFigurePosition');
    s_title = p.Results.title;
    FLAG_txt = p.Results.verbose;
    hfig = p.Results.hfig;
    ax = p.Results.axes;
    cc = p.Results.roi;
    ex_str = p.Results.ex_str;
    zoom = p.Results.scanZoom;
    %hfig_sync = p.Results.sync;
    SAVE_png = p.Results.png;
    FLAG_scale_bar = true;
    FLAG_roi = false;
    FLAG_color_segmentation = false;
    FLAG_hole_fill = true;
    %FLAG_color_segmentation = false;
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
    
    % ex str in UserData
    hfig.UserData.ex_str = ex_str;
    
    % Set the callback on figure
    %set(fig, 'KeyPressFcn', @(fig, evnt)keypress(h, evnt))
    set(hfig, 'KeyPressFcn', @keypress)
    
    % Normalization and get frame numbers
    vol = scaled(vol);
    [rows, cols, n_frames] = size(vol);
    
    % mask variables for ROI removal by user
    mask = false(rows, cols);
    white = false(rows, cols);
    r = []; c = []; % row, col for selected points by clicks
    
    % Default parameters
    data.i = 1; % index for stack
    data.imax = n_frames;

    tols = [0, 0.05, 0.1:0.1:0.9, 1:0.2:2, 2.5:0.5:5, 6:1:11, 12:2:20, 25:5:95]; % percentage; tolerance for saturation
    n_tols = length(tols);
    id_tol = 4; % initial tol = 0.05;
    id_add_lower = 1;
    id_add_upper = 3;
    
    % ROI mode parameters
    sensitivity_0 = 0.02; % sensitivity for adaptive binarization
    P_connected_0 = 75; % depending on magnification (zoom) factor
    sensitivity = sensitivity_0; 
    P_connected = P_connected_0; 
    
    % Nested function definition for easy access to stack 'vol'
    function redraw()
        % get focus
        figure(hfig);
        if N == 2
            I = vol;
        else
            I = comp(vol, data.i);
        end
        
        upper = max(1 - (tols(id_tol) + tols(id_add_upper))*0.01, 0);
        lower = min((tols(id_tol) + tols(id_add_lower))*0.01, upper);
        
        Tol = [lower upper];
        MinMax = stretchlim(I,Tol);
        J = imadjust(I, MinMax);
%         if ~isempty(ax)
%             axes(ax);    
%         end
        
        % draw image
        if ~FLAG_roi 
            imshow(J);
        else 
            % if cc is given
            if ~isempty(p.Results.roi)
                cc = p.Results.roi;
                bw = conn_to_bwmask(cc);
                bw = max(bw, [], 3);
            else
                % ROI mode
                bw = imbinarize(J, 'adaptive', 'Sensitivity', sensitivity);
                bw = bw & (~mask);    % get ROI mask and then subtract it from the image
                bw = bw | (white);
                bw = bwareaopen(bw, P_connected); % remove small area
                bw = bw - bwselect(bw, c, r, 8);  % remove mouse-clicked components
                if FLAG_hole_fill
                    bw = imfill(bw, 'hole');
                end
                cc = bwconncomp(bw, 8); % 'cc' is updated inside a local function. 
                % Filled image
                %regionprops(cc, 'FilledImage');
                % filter by ecentriccity?
                %s = regionprops(cc, 'Eccentricity');
            end

            % visualization of computed ROI
            if ~FLAG_color_segmentation
                imshow(J); 
                hold on
                    % Contour 
                    visboundaries(bw,'Color','r','LineWidth', 0.7); 

                    % ROI number display
                    s = regionprops(cc, 'extrema');
                    for k = 1:numel(s)
                       e = s(k).Extrema;
                       text(e(4,1), e(4,2), sprintf('%d', k), 'Color', 'r', ... %5th comp: 'bottom-right'
                           'VerticalAlignment', 'bottom', 'HorizontalAlignment','left'); 
                    end
                hold off
            else
                labeled = labelmatrix(cc);
                RGB_label = label2rgb(labeled, @parula, 'k', 'shuffle');
                imshow(RGB_label);
            end
            % update 'cc' whenever ROI mode is activated.
                % figure handle
                hfig.UserData.cc = cc;
                % in workspace 
                v_name = 'cc';
                assignin('base', v_name, cc);
                assignin('base', 'mask', mask);
                assignin('base', 'white', white);
                %
            disp([num2str(cc.NumObjects), ' Objects (ROIs) are selected.']);    
        end
        ax = gca;
        title(s_title, 'FontSize', 15, 'Color', 'w');
        
        % scale bar
        if FLAG_scale_bar && ~isempty(zoom)
            fov = get_FOV_size_x25_Leica(zoom);
            px_per_um = rows/fov;
            hold on;
                l_scalebar = 30; % um
                x0 = ax.XLim(end) * 0.80;
                y0 = ax.YLim(end) * 0.90;
                quiver(x0, y0, l_scalebar*px_per_um, 0, 'ShowArrowHead', 'off', 'Color', 'w', 'LineWidth', 2);
                text(x0+l_scalebar*px_per_um/2, y0, [num2str(l_scalebar),' um'], 'FontSize', 15, 'Color', 'w', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment','center');
            hold off;

%             line( [100 200], round(0.85*ax.YLim(end)), 'Color', 'w', 'LineWidth', 4);
        end
        
        if SAVE_png
            filename = strrep(s_title, ' ', '_');
            filename = strrep(filename, '(', '_');
            filename = strrep(filename, ':', '');
            if ~FLAG_roi
                saveas(hfig, [filename,'_',num2str(data.i),'of',num2str(n_frames),'.png']);
            else
                saveas(hfig, [filename,'_',num2str(data.i),'of',num2str(n_frames),'_ROI.png']);
            end
            SAVE_png = false; % save only one time
        end   
        
        if FLAG_txt
        % text. where? on the image
        % advantage of text on the image. automatic clear.
            if FLAG_roi
                str1 = sprintf('Sens.=%.2f Pconn.=%.2f.', sensitivity, P_connected);
                str2 = sprintf('Press ''d'' or ''r'' to remove ROIs. ''q'' for default settings');
                str3 = sprintf('%d/%d', data.i, data.imax);
            else
                str1 = sprintf('low=%.3f upp=%.3f', lower, upper);
                str2 = '''q'' for default contrast. ''SPACE'' for ROI mode. ''b'' scale bar';
                str3 = sprintf('%d/%d', data.i, data.imax);
            end
            
            % x,y for text. Coordinate for imshow is different from plot
            text(ax.XLim(1), ax.YLim(end), str1, 'FontSize', 12, 'Color', 'w', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment','left');
            text(ax.XLim(2), ax.YLim(end), str3, 'FontSize', 12, 'Color', 'w', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
            text((ax.XLim(1)+ax.XLim(end))/2, ax.YLim(end), str2, 'FontSize', 12, 'Color', 'w', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment','center');
        end
        
        uiresume(hfig);
    end

    % Update the display of the surface
    redraw();
    
    % Normal mode: viewer
    function keypress(~, evnt)
        
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
            case '9'
                id_add_upper = max(1, id_add_upper - 1); 
            case '0'
                id_add_upper = min(id_add_upper + 1, n_tols);
            case 'l' % line profile
                [cx,cy,c,xi,yi] = improfile;
                c_section = zeros(length(c), n_frames);
                for k = 1:n_frames
                    c_section(:,k) = improfile(vol(:,:,k),xi,yi);
                end
                px_per_um = 1024/300;
                z_step_um = 1; % um
                a_ratio = px_per_um/z_step_um;
                img = c_section.';
                [numrows, numcols] = size(img);
                C = imresize(img, [a_ratio*numrows, numcols]);
                make_im_figure(500, 0);
                myshow(C,0.2); ax = gca; 
                %scale bar?
                hold on;
                l_scalebar = 30; % um
                x0 = ax.XLim(end) * 0.80;
                y0 = ax.YLim(end) * 0.90;
                quiver(x0, y0, l_scalebar*px_per_um, 0, 'ShowArrowHead', 'off', 'Color', 'w', 'LineWidth', 2);
                text(x0+l_scalebar*px_per_um/2, y0, [num2str(l_scalebar),' um'], 'FontSize', 15, 'Color', 'w', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment','center');
                hold off;
            case 's'
                SAVE_png = true;
            case 'b'
                FLAG_scale_bar = ~FLAG_scale_bar;
            case 'space' % ROI mode switch
                FLAG_roi = ~FLAG_roi;
                set(hfig, 'KeyPressFcn', @keypress_roi)
            case 'v' % verbose output
                FLAG_txt = ~FLAG_txt;
            case 'q' % default contrast
                id_tol = 5;
                id_add_lower = 1;
            otherwise
                uiresume
                return;
        end

        redraw();
    end
    
    % ROI mode
    function keypress_roi(~, evnt)
        % step for tolerance or contrast
        s = 0.02;
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
            case '1'
                id_add_lower = max(1, id_add_lower - 1); 
            case '2'
                id_add_lower = min(id_add_lower + 1, n_tols);
            case '9'
                id_add_upper = max(1, id_add_upper - 1); 
            case '0'
                id_add_upper = min(id_add_upper + 1, n_tols);
            case 's'
                SAVE_png = true;
            case 'c' % Color map
                FLAG_color_segmentation = ~FLAG_color_segmentation;
            case 'space' 
                % Go back to imshow mode
                FLAG_roi = ~FLAG_roi;
                set(hfig, 'KeyPressFcn', @keypress)
            case 'r' % mask update. remove connected components by multiple mouse clicks
                [col, row] = getpts;
                c = [c; col];
                r = [r; row];
            case 'd' % mask update. 'Drag': remove all components in specified rect ROI.
                hrect = imrect;
                while ~isempty(hrect)
                    m = createMask(hrect);
                    mask = mask | m;
                    redraw();
                    hrect = imrect;
                end
            case 'l' % line mask
                hline = imline;
                while ~isempty(hline)
                    m = createMask(hline);
                    mask = mask | m;
                    redraw();
                    hline = imline;
                end
            case 'a' % add patch 
                h_ellip = imellipse;
                m = createMask(h_ellip);
                white = white | m;         
            case 'n' % display numbers on ROIs
            
            case 'f' % turn off automatic filling (imfill) inside the grain.
                FLAG_hole_fill = ~FLAG_hole_fill;
                
            case 'v' % verbose output
                FLAG_txt = ~FLAG_txt;
                
            case 'q' % default contrast
                sensitivity = sensitivity_0;
                P_connected = P_connected_0;
                mask = false(rows, cols);
                white = false(rows, cols);
                r = []; c = [];
           
            otherwise
                return;
        end
        
        redraw();
        
        % update traces?
        
    end

    
    
end

function roi_array = conn_to_bwmask(cc)
% convert cc to bwmask

roi_array = false([cc.ImageSize, cc.NumObjects]);

for i = 1:cc.NumObjects
    grain = false(cc.ImageSize);
    grain(cc.PixelIdxList{i}) = true;
    roi_array(:,:,i) = grain;
end

end

function fov = get_FOV_size_x25_Leica(zoom)
% x25 Leica lens in upright scope running SI 5. [um]
    % data
    scanZoom = [];
    fovSize  = [];
    
    % interporlate
    % fov = 
    switch zoom
        case 1
            fov = 600;
        case 2
            fov = 300;
        case 3
            fov = 150;
        otherwise
            
    end

end


function p =  ParseInput(varargin)
    
    p  = inputParser;   % Create an instance of the inputParser class.
    
    addParamValue(p,'title', []);
    addParamValue(p,'hfig', []);
    addParamValue(p,'axes', []);
    addParamValue(p,'roi', []);
    %addParamValue(p,'sync', []);
    addParamValue(p,'verbose', true, @(x) islogical(x));
    addParamValue(p,'png', false, @(x) islogical(x));
    addParamValue(p,'ex_str', [], @(x) ischar(x));
    addParamValue(p,'scanZoom', [], @(x) isnumeric(x));
    
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end