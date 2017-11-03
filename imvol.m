function [J] = imvol(vol, hfig)
% imshow() with interactive navigation 
% input 'vol' should be image or 3-D matrix
% keypress -> create new figure handle h from imshow. You can't stroe
% information in previous h created by imshow.
    
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

    % Set the callback and pass the surf handle
    %set(fig, 'KeyPressFcn', @(fig, evnt)keypress(h, evnt))
    set(hfig, 'KeyPressFcn', @keypress)
    
    % Default parameters
    data.i = 1; % index for stack
    data.imax = n_frames;
 
    tols = [0, 0.05, 0.1:0.1:0.9, 1:1:9, 10:5:95]; % percentage; tolerance for saturation
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
        
        lower = min((tols(id_tol) + tols(id_add_lower))*0.01, 1);
        upper = max(1 - tols(id_tol)*0.01, 0);
        Tol = [lower upper];
        MinMax = stretchlim(I,Tol);
        J = imadjust(I, MinMax);
        imshow(J); 
        str = sprintf('%d/%d low=%.3f upp=%.3f',data.i, data.imax, lower, upper);
        title(str, 'Color', 'w', 'FontSize',17, 'Position', [cols-length(str)-10, 0]);
        
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

            case 'space' % default contrast
                id_tol = 2;
            otherwise
                return;
        end

        redraw();
    end 


end