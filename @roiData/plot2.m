function plot2(r, I, varargin)
% PLOT version 2. For clustering analysis and projection to PCA.
% Axes instead of subplot. Histogram of pdist to clustered groups
% Create new figure with interactive keyboard navigation over roi#
    
    p=ParseInput(varargin{:});
    c_given = p.Results.Cluster;
    
    if nargin < 2
        I = 1:r.numRoi;    
    end
    i_roi = 1;
    imax = numel(I);
    
    % cluster id & initialize projection vector
    i_c = 1; % id in sorted cluster array
    p = zeros(size(r.c_mean, 2));
    i_sorted = zeros(1, 100);
    
    % open plot_cluster for calculating c_mean
    if ~ishandle(r.c_hfig)
        r.plot_cluster;
    end
    
    % color for clusters;
    c_list = unique(r.c(r.c~=0)); 
    c_list_num = numel(c_list);
    color = jet(c_list_num); 
    % color index? color(c_list == r.c(k), :)
    
    % Figure 
    hfig = figure('Position', [10 300 800 900]);
    %axes('Position', [0  0  1  0.9524], 'Visible', 'off');
    
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
        % delete all objects
        delete(hfig.Children);
        
        k = I(i_roi); % roi index. Real index
        mask = false(cc.ImageSize);
        % ex info
        str_smooth_info = sprintf('smooth size %d (~%.0f ms)', r.smoothing_size, r.ifi*r.smoothing_size*1000);
        
        % 1. whole trace
        %subplot(n_row, n_col, [1, n_col]);
        axes('Position', [0.05  0.81  0.9  0.15], 'Visible', 'off');
            plot_trace_raw(r, k);
%                 ax = findobj(gca, 'Type', 'Line');
%                 ax.LineWidth = 0.8;            

        % 3.Projected scores onto (PCA) space dims
        axes('Position', [0.53  0.39  0.4  0.36], 'Visible', 'off');
            
                i = 1; j = 2;

                % all avg traces
                X = r.avg_pca_score;

                for c = c_list
                    % only non-zero cluster data
                    scatter(X(r.c==c, i),X(r.c==c, j), 15, color(c_list==c,:));
                        ax = gca;
                        ax.Color = 'k'; % background color
                        xlabel(['PCA ', num2str(i)], 'FontSize', 12);
                        ylabel(['PCA ', num2str(j)], 'FontSize', 12);
                        grid on
                        hold on
                end
                % un-assigned cluster 0: gray plot
                c0_color = [0.4 0.4 0.4];
                scatter(X(r.c==0, i),X(r.c==0, j), 12, c0_color, 'filled');

                % k-index ROI
                if r.c(k)
                    % cluster 0 : cluster is not assigned or noisy data.
                    k_color = color(c_list==r.c(k), :);
                    k_color = [1 1 1];
                else
                    k_color = c0_color;
                end
                %scatter(X(k, i),X(k, j), 18, color(c_list==r.c(k), :), 'filled');
                plot(X(k, i),X(k, j), 'kd', 'MarkerSize', 13, 'LineWidth', 1.8, 'Color', k_color); 
                hold off

                cluster_colorbar = label2rgb(vec(1:c_list_num), @jet, 'k');
                axes('Position', [0.93  0.45  0.05  0.2], 'Visible', 'off');
                imshow(cluster_colorbar);
            
        % 4. roi avg (smoothed) trace
        subplot(n_row, n_col, 2*n_col+1);
            
            if strfind(r.ex_name, 'whitenoise')
                r.plot_rf(k, 'smoothed');
                title('Revrse correlation (smoothed trace)');
                c = colorbar;
                c.TickLabels = {};
            else
                y = plot_avg(r, k);
                y = normc(y);
                hold on
                %y0 = r.stat.smoothed_norm.trace_mean_level(k);
                y0 = r.stat.smoothed_norm.avg_mean(k);
                y_std = r.stat.smoothed_norm.trace_std_avg(k)/sqrt(numel(r.avg_trigger_times));
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
            
        subplot(n_row, n_col, 2*n_col+2);
        % projection (inner product) to the mean trace
            if strfind(r.ex_name, 'whitenoise')
                
            else
                [~, numCluster] = size(r.c_mean); % default setting 100
                x = 1:numCluster;

                if iscolumn(y)
                    y = y.';
                end
                % (weighted?) projection
                    % Reduced weight below noise floor ?
                    % y = y * weight;
                p = y * r.c_mean;
                i_nonzero = (p~=0);
                [p_sorted, i_sorted] = sort(p, 'descend');
                i_sorted(p_sorted ==0) = [];
                
                %
                bar( x(i_nonzero), p(i_nonzero) );
                ax = gca; ax.FontSize = 12;
                title('Projection to clusters');
                
                % Cluster # for max projection
                text(i_sorted(1), ax.YLim(1)*0.20, num2str(i_sorted(1)), 'FontSize', 15,...
                    'HorizontalAlignment','center');
                if length(i_sorted) > 1
                    text(i_sorted(2), ax.YLim(1)*0.20, num2str(i_sorted(2)), 'FontSize', 12,...
                        'HorizontalAlignment','center');
                end
                if length(i_sorted) > 2
                    text(i_sorted(3), ax.YLim(1)*0.20, num2str(i_sorted(3)), 'FontSize', 10,...
                        'HorizontalAlignment','center');
                end
            end
            
        % mean trace of the suggested cluster 
        subplot(n_row, n_col, 2*n_col+3);
            if strfind(r.ex_name, 'whitenoise')
                
            else
                c = r.c;     % cluster id array for all rois
                
                c_suggested = i_sorted(i_c);
                
                roi_clustered = find(c==c_suggested);
                r.plot_avg(roi_clustered, 'PlotType', 'mean', 'NormByCol', true, 'LineWidth', 1.4);
                
                hold on
                yy = r.traceForAvgPlot(y);
                plot(r.a_times, yy, 'LineWidth', 0.7);
                hold off
                
                ax = gca;
                title( {r.c_note{c_suggested} }, 'FontSize', 14);
                text(ax.XLim(end), ax.YLim(end), ['C', num2str(c_suggested)], 'FontSize', 15, 'Color', 'k', ...
                                'VerticalAlignment', 'top', 'HorizontalAlignment','right');
            end

        % bottom text 
        %axes('Parent', hfig, 'OuterPosition', [0.1, 0, 0.5, 0.06]); axis off;
        axes('Parent', hfig, 'OuterPosition', [0, 0, 1, 0.06]); axis off;
        ax = gca;
        str = sprintf('Current Cluster #: %d  (Press ''SPACE'' to move to c%d:  %s )', r.c(k), i_sorted(i_c), r.c_note{c_suggested});
        text(ax.XLim(1), ax.YLim(end), str, 'FontSize', 15);
        
        % 2. ROI spatial pattern
        %subplot(n_row, n_col, [n_col+1, 2*n_col]);
        ax_roi = axes('Position', [0.05  0.39  0.4  0.36], 'Visible', 'off');
            if c_given > 0
               r.plot_cluster_roi(c_given, 'compare', c_suggested, 'imageType', 'bw');
               hold on
                   s = regionprops(r.roi_cc, 'centroid');
                   center = s(k).Centroid;
                   plot(center(1), center(2), 's', 'MarkerSize', 24, 'LineWidth', 1.5, 'Color', 'y')
                   str1 = sprintf(' C%d (n=%d)', c_given, sum(r.c==c_given));
                   text(ax_roi.XLim(1), ax_roi.YLim(1)+5, str1, 'FontSize', 12, 'Color', 'w', ...
                    'VerticalAlignment', 'top', 'HorizontalAlignment','left');
                   text(ax_roi.XLim(end), ax_roi.YLim(1)+5, ['ROI ',num2str(k),' '], 'FontSize', 12, 'Color', 'w', ...
                    'VerticalAlignment', 'top', 'HorizontalAlignment','right');
               hold off
            else
                mask(cc.PixelIdxList{k}) = true;
                h = imshow(RGB_label);
                set(h, 'AlphaData', 0.9*mask+0.1);

                ax = gca;
                str1 = sprintf('%d/%d ROI', k, r.numRoi);
                text(ax.XLim(end), ax.YLim(1), str1, 'FontSize', 12, 'Color', 'k', ...
                    'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
            end
    end

    redraw();
    
    function keypress(~, evnt)
        a = lower(evnt.Key);
        k = I(i_roi);
        %fprintf('key event is: %s\n', evnt.Key);
        switch a
            case 'rightarrow'
                i_roi = i_roi + 1;
                if i_roi > imax
                    i_roi = imax;
                end
                i_c = 1;
            case 'leftarrow'
                i_roi = i_roi - 1;
                if i_roi < 1
                    i_roi = 1;
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
                
            case 'backspace'
                c_noise = 0;
                % move to noisy cluster
                c_prev = r.c(k);
                % update cluster id
                r.c(k) = c_noise;
                % plot previous and new cluster group
                r.plot_cluster(c_prev); 
                fprintf('New ROI %d is moved to noise cluster %d,\n', k, c_noise);
                % increase roi index automatically
                i_roi = i_roi + 1;
                if i_roi > imax
                    i_roi = imax;
                    disp('Last ROI selected.');
                end 
                i_c =1;

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

function aa = vec(a)
aa = a(:);
end

function p =  ParseInput(varargin)
    
    p  = inputParser;   % Create an instance of the inputParser class.
    
    p.addParameter('Cluster', 0, @(x) x>=0);
      
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end

function [bw_selected, bw_array] = cc_to_bwmask(cc, id_selected)
% convert cc to bwmask array and totla bw for selected IDs.

    if nargin < 2
        id_selected = 1:cc.NumObjects;
    end

    bw_array = false([cc.ImageSize, cc.NumObjects]);

    for i = 1:cc.NumObjects
        grain = false(cc.ImageSize);
        grain(cc.PixelIdxList{i}) = true;
        bw_array(:,:,i) = grain;
    end
    % Total bw for selected IDs
    bw_selected = max( bw_array(:,:,id_selected), [], 3);
end