function plot(r, I)
% Create new figure with interactive keyboard navigation over roi#

    if nargin < 2
        I = 1:r.numRoi;    
    end
    i_roi = 1;
    imax = numel(I);

    hfig = figure('Position', [100 230 1300 840]);
    axes('Position', [0  0  1  0.9524], 'Visible', 'off');
    
    cc = r.roi_cc;
    
    % callback
    set(hfig, 'KeyPressFcn', @keypress)
    
    % roi # and max #
    
    S = sprintf('ROI %d  *', 1:imax); C = regexp(S, '*', 'split'); % C is cell array.
    
    % roi rgb image
    labeled = labelmatrix(cc);
    RGB_label = label2rgb(labeled, @parula, 'k', 'shuffle');
    
    % subplot info
    n_col = 3;
    n_row = 3;
    

    function redraw()
        k = I(i_roi); % roi index
        mask = false(cc.ImageSize);
        % ex info
        str_smooth_info = sprintf('smooth size %d (~%.0f ms)', r.smoothing_size, r.ifi*r.smoothing_size*1000);
        
        % 1. whole trace
        subplot(n_row, n_col, [1, n_col]);
            plot_trace_raw(r, k);
%                 ax = findobj(gca, 'Type', 'Line');
%                 ax.LineWidth = 0.8;            
        subplot(n_row, n_col, [n_col+1, 2*n_col]);
            plot_trace_norm(r, k);
%                 ax = findobj(gca, 'Type', 'Line');
%                 ax.LineWidth = 0.8;            
            
        subplot(n_row, n_col, 2*n_col+1);
            %axes('Position', [0  0  1  1], 'Visible', 'off');
            mask(cc.PixelIdxList{k}) = true;
            h = imshow(RGB_label);
            set(h, 'AlphaData', 0.9*mask+0.1);
            
            ax = gca;
            str1 = sprintf('%d/%d ROI', k, r.numRoi);
            text(ax.XLim(end), ax.YLim(1), str1, 'FontSize', 12, 'Color', 'k', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
            
        % 3. roi avg (smoothed) over multiple repeats
        subplot(n_row, n_col, 2*n_col+2);
            
            if contains(r.ex_name, 'whitenoise') || contains(r.ex_name, 'run') 
                
                r.plot_rf(k, 'smoothed');
                title('Revrse correlation (smoothed trace)');
                c = colorbar;
                c.TickLabels = {};
            else
                plot_avg(r, k);
                ax =gca;
                title('Avg response (smoothed) over trials');
                if ~isempty(ax)
                    text(ax.XLim(end), ax.YLim(1), str_smooth_info, 'FontSize', 11, 'Color', 'k', ...
                                'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
                end
            end
            
        % 4. roi avg (filtered) over multiple repeats
        subplot(n_row, n_col, 2*n_col+3);
            
            if contains(r.ex_name, 'whitenoise') || contains(r.ex_name, 'run')
%                 r.plot_rf(k, 'normalized');
%                 title('Revrse correlation (norm. trace)');
                c = colorbar;
                c.TickLabels = {};
            else
                ax = plot_avg_fil(r, k);
                title('Avg response (filtered) over trials');
                if ~isempty(ax)
                    text(ax.XLim(end), ax.YLim(1), str_smooth_info, 'FontSize', 11, 'Color', 'k', ...
                                'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
                end
            end

    end

    redraw();
    
    function keypress(~, evnt)
        a = lower(evnt.Key);
        switch a
            case 'rightarrow'
                i_roi = i_roi + 1;
                if i_roi > imax
                    i_roi = 1;
                end
            case 'leftarrow'
                i_roi = i_roi - 1;
                if i_roi < 1
                    i_roi = imax;
                end

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