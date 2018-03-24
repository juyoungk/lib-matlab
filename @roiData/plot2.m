function plot2(r, I)
% PLOT version 2. 
% Axes instead of subplot. Histogram of pdist to clustered groups
% Create new figure with interactive keyboard navigation over roi#

    if nargin < 2
        I = 1:r.numRoi;    
    end
    i_roi = 1;
    imax = numel(I);
    
    % cluster id & initialize projection vector
    i_c = 1; % id in sorted cluster array
    p = zeros(size(r.c_mean, 2));
    i_sorted = zeros(1, 100);

    hfig = figure('Position', [130 400 1300 840]);
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
    n_col = 5;
    n_row = 3;
    

    function redraw()
        % delete all objects
        delete(hfig.Children);
        
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
            
        % 3. roi avg (filtered) over multiple repeats
        subplot(n_row, n_col, 2*n_col+2);
        
            if strfind(r.ex_name, 'whitenoise')
                r.plot_rf(k, 'normalized');
                title('Revrse correlation (norm. trace)');
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
            
        % 4. roi avg (smoothed) over multiple repeats
        subplot(n_row, n_col, 2*n_col+3);
            
            if strfind(r.ex_name, 'whitenoise')
                r.plot_rf(k, 'smoothed');
                title('Revrse correlation (smoothed trace)');
                c = colorbar;
                c.TickLabels = {};
            else
                y = plot_avg(r, k);
                hold on
                y0 = r.stat.smoothed_norm.trace_mean_level(k);
                y_std = r.stat.smoothed_norm.trace_std_avg(k)/2.;
                    plot(ax.XLim, [y0+y_std y0+y_std], '--', 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
                    plot(ax.XLim, [y0-y_std y0-y_std], '--', 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
                hold off
                
                ax =gca;
                title('Avg response (smoothed) over trials');
                if ~isempty(ax)
                    text(ax.XLim(end), ax.YLim(1), str_smooth_info, 'FontSize', 11, 'Color', 'k', ...
                                'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
                end
            end
            
        subplot(n_row, n_col, 2*n_col+4);
        % projection (inner product) to the mean trace
            if strfind(r.ex_name, 'whitenoise')
                
            else
                [~, numCluster] = size(r.c_mean); % default setting 100
                x = 1:numCluster;

                if iscolumn(y)
                    y = y.';
                end
                % projection
                p = y * r.c_mean;
                i_nonzero = (p~=0);
                [p_sorted, i_sorted] = sort(p, 'descend');
                i_sorted(p_sorted ==0) = [];
                
                %i_max = i_sorted(1);
                %[p_max, i_max] = max(p);
                
                bar( x(i_nonzero), p(i_nonzero) );
                ax = gca; ax.FontSize = 12;
                title('Projection to clusters');
                
                % Cluster # for max projection
                text(i_sorted(1), ax.YLim(1)*0.20, num2str(i_sorted(1)), 'FontSize', 15,...
                    'HorizontalAlignment','center');
                text(i_sorted(2), ax.YLim(1)*0.20, num2str(i_sorted(2)), 'FontSize', 12,...
                    'HorizontalAlignment','center');
                text(i_sorted(3), ax.YLim(1)*0.20, num2str(i_sorted(3)), 'FontSize', 12,...
                    'HorizontalAlignment','center');
            end
        % mean trace of the suggested cluster 
        subplot(n_row, n_col, 2*n_col+5);
            if strfind(r.ex_name, 'whitenoise')
                
            else
                c = r.c;     % cluster id array for all rois
                
                id_cluster = i_sorted(i_c);
                
                roi_clustered = find(c==id_cluster);
                r.plot_avg(roi_clustered, 'PlotType', 'mean', 'NormByCol', true, 'LineWidth', 1.2);
                title(['c', num2str(id_cluster),' mean'], 'FontSize', 14);
                %plot(r.avg_times, r.c_mean(:, i_max), 'LineWidth', 1.5);
                
            end
            
        % bottom text 
        axes('Parent', hfig, 'OuterPosition', [0.4, 0, 0.5, 0.06]); axis off;
        ax = gca;
        str = sprintf('Current Cluster #: %d  (Press ''SPACE'' if you want to include the cell in cluster %d)', r.c(k), i_sorted(i_c));
        text(ax.XLim(1), ax.YLim(end), str, 'FontSize', 15);

    end

    redraw();
    
    function keypress(~, evnt)
        a = lower(evnt.Key);
        k = I(i_roi);
        switch a
            case 'rightarrow'
                i_roi = i_roi + 1;
                if i_roi > imax
                    i_roi = 1;
                end
                i_c = 1;
            case 'leftarrow'
                i_roi = i_roi - 1;
                if i_roi < 1
                    i_roi = imax;
                end
                i_c = 1;
            case 'uparrow'
                i_c = i_c + 1;
                i_c_max = numel(i_sorted);
                if i_c_max ==0
                    i_c_max = 1;
                end
                if i_c > i_c_max
                    i_c = i_c_max;
                end
            case 'downarrow'
                i_c = i_c - 1;
                if i_c < 1
                    i_c = 1;
                end
                
            case 'r' % list of review
                r.roi_review = [r.roi_review, k];
                disp('Added in review list.');
                
            case 'space'
                % accept suggested cluster#
                c_prev = r.c(k);
                c_new = i_sorted(i_c);
                r.c(k) = c_new;
                r.plot_cluster([c_new, c_prev]); 
                    fprintf('New ROI %d is added in cluster %d,\n', k, c_new);
                % increase roi index automatically
                i_roi = i_roi + 1;
                if i_roi > imax
                    i_roi = imax;
                    disp('Last ROI selected.');
                end 
                i_c = 1;

            otherwise
                n = str2double(a);
                if (n>=0) & (n<10)
                    if n == 0
                        n = 10;
                    end
                    c_prev = r.c(k);
                    % update cluster id
                    r.c(k) = n;
                    % plot previous and new cluster group
                    r.plot_cluster([n, c_prev]); 
                    fprintf('New ROI %d is added in cluster %d,\n', k, n);
                    % increase roi index automatically
                    i_roi = i_roi + 1;
                    if i_roi > imax
                        i_roi = imax;
                        disp('Last ROI selected.');
                    end 
                    i_c = 1;
                end
        end
        figure(hfig);
        redraw();
    end

end




