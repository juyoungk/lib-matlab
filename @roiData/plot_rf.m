function ax = plot_rf(r, id_roi, traceType, maxlag, upsampling)
    
    if nargin < 5
        upsampling = 2;
    end
    
    if nargin < 4
        maxlag = 1.5; %sec
    end
    

    if nargin>1 && numel(id_roi) == 1 && isnumeric(id_roi)
        
        if nargin < 3
            traceType = 'smoothed';
        end
        
        [rf, s] = rf_corr(r, id_roi, traceType, maxlag, upsampling); % sampled at f_times_norm
        
        if size(rf, 1) == 1 % uniform field
            plot_rf_slice_t(r, rf);
        else
            plot_rf_map(r, rf, s);
        end
        
    else
        % plot rf for all rois
        
        if nargin > 1 && ischar(id_roi)
            traceType = id_roi;
        else
            traceType = 'normalized';
        end

        % ex info
        S = sprintf('ROI %d*', 1:r.numRoi); C = regexp(S, '*', 'split'); % C is cell array.
        str_smooth_info = sprintf('smooth size %d (~%.0f ms bin)', r.smoothing_size, r.ifi*r.smoothing_size*1000);
        %str_events_info = sprintf('stim duration: %.1fs', r.stim_duration); 
        str_events_info = [];
        str_info = sprintf('%s\n%s', str_events_info, str_smooth_info);
        
        % subplot params
        n_row =  8;
        n_col = 10; % limit num of subplots by fixing n_col
        % Figure params
        n_cells_per_fig = 75;
        
        %        
        if nargin < 2
            roi_array = 1:r.numRoi; % loop over all rois
        else
            roi_array = id_roi;     % loop over selected rois
        end
        
        k = 1; % index in selected roi group
        while (k <= numel(roi_array))
            
            % figure creation
            make_figure(500);
            title([r.ex_name, ': reverse correlation']);

            %for rr = 1:r.numRoi % loop over rois
            for i = 1:n_cells_per_fig % subplot index
                
                    if k > numel(roi_array); break; end;

                    subplot(n_row, n_col, i);
                    rr = roi_array(k);
                    
                    % plot for roi# rr
                    plot_rf(r, rr, traceType, maxlag, upsampling);
                    
                    %
                    ax = gca;
                    text(ax.XLim(end), ax.YLim(1), C{rr}, 'FontSize', 9, 'Color', 'k', ...
                        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');                   
                   
                    % bottom-most subplot: x label
                    if any(i == n_cells_per_fig)
                        xlabel('sec');
                    end
                    
                    % increase roi id
                    k = k + 1;
            end
            
            % Text comment on final subplot
            subplot(n_row, n_col, n_row*n_col);
            ax = gca; axis off;
            text(ax.XLim(end), ax.YLim(1), str_info, 'FontSize', 11, 'Color', 'k', ...
                        'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
            text(ax.XLim(end), ax.YLim(1), ['exp: ', r.ex_name], 'FontSize', 11, 'Color', 'k', ...
                    'VerticalAlignment', 'top', 'HorizontalAlignment','right');
            %
            saveas(gcf, [r.ex_name,'_ROI_whitenoise_corrRF.png']);
        end
        
        

    end


end

function plot_rf_map(r, rf, s)

    [num_x, num_t] = size(rf);
    
    imshow(rf, s.clim, 'Colormap', bluewhitered(64, s.clim)); % jet, parula, winter ..
        axis on;
        ax =gca; colorbar('TickLabels', []);
        
        time_tick_label = 1:2:(num_t*r.ifi*10); % [ 100 ms]
        time_tick_label = 1:2:10; % up to 1s [ 100 ms]
        time_tick_locs = time_tick_label * 0.1 / r.ifi;
        ax.XTick = time_tick_locs;
        S = sprintf('%.0f*', time_tick_locs*r.ifi*10 ); time_label = regexp(S, '*', 'split'); % C is cell array.
        ax.XTickLabel = {time_label{1:end-1}}; 
        xlabel('[x100 ms]');
        %
        x_tick_spacing = 0.5; % [mm]
        w_bar = r.stim_size/num_x;
        x_center = num_x/2.;
        x = 0:(x_tick_spacing/w_bar):(num_x/2.); % half size 
        x = unique([-x, x]);
        ax.YTick = x + x_center;
        S = sprintf('%.1f*', x*w_bar ); C = regexp(S, '*', 'split'); % C is cell array.
        ax.YTickLabel = {C{1:end-1}};
        ylabel('[mm]');
        ax.FontSize = 12;
end



function make_figure(x_shift, y_shift)
    
    if nargin < 2
        y_shift = 0;
    end
    if nargin < 1
        x_shift = 0;
    end
    
    pos_new = get(0, 'DefaultFigurePosition');
    figure('Position', [pos_new(1) + x_shift, 100 + y_shift, pos_new(3)*2.4, pos_new(4)*2]);
    axes('Position', [0  0  1  0.9524], 'Visible', 'off');
end