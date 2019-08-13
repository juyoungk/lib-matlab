function plot3(r, I)
% Plot version 3.

    if nargin < 2
        if ~isempty(r.roi_good)
            I = r.roi_good;
        else
            I = 1:r.numRoi;
        end
    end
    
    n_cells_per_fig = 8;
    i_fig = 1;

    hfig = figure('Position', [100 230 1300 840]);
    axes('Position', [0  0  1  0.9524], 'Visible', 'off');
    
    % callback
    set(hfig, 'KeyPressFcn', @keypress)
    
    % roi # and max # 
    numcell = numel(I);
    S = sprintf('ROI %d  *', 1:numcell); C = regexp(S, '*', 'split'); % C is cell array.
    
    % subplot info
    n_col = 6;
    
    function redraw()
        
        if (i_fig - 1) * n_cells_per_fig + 1 > numel(I)
            i_fig = i_fig - 1;
            i_fig = max(i_fig, 1);
        end
        
        ids = (i_fig-1)*n_cells_per_fig+1:i_fig*n_cells_per_fig;
        ids = ids(ids<=numel(I));
        
        rois = I(ids);
        
        for i = 1:numel(rois)
            
            % roi id
            k = rois(i);
            
            subplot(n_cells_per_fig, n_col, (i-1)*n_col+ 1);
            r.plot_roi_patch(k, 18);
            
            subplot(n_cells_per_fig, n_col, (i-1)*n_col+ [2, n_col-1]);
            r.plot_trace_norm(k);
            
            subplot(n_cells_per_fig, n_col, (i-1)*n_col+ n_col);
            r.plot_avg(k);
            
        end

    end

    redraw();
    
    function keypress(~, evnt)
        a = lower(evnt.Key);
        switch a
            case 'rightarrow'
                i_fig = i_fig + 1;
            
            case 'leftarrow'
                i_fig = i_fig - 1;
                i_fig = max(i_fig, 1);
            
            otherwise
%                 n = str2double(a);
%                 if (n>=0) & (n<10)
%                     k = I(i_roi);
%                     r.c(k) = n;
%                     %r.c{n} = [k, r.c{n}];
%                     r.plot_cluster(4, n);
%                     fprintf('New ROI %d is added in cluster %d,\n', k, n);
%                     % increase roi index automatically
%                     i_roi = i_roi + 1;
%                     if i_roi > imax
%                         i_roi = 1;
%                     end 
%                 end
        end
        figure(hfig);
        redraw();
    end

end