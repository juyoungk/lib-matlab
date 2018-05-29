function plot_rf2(r, id_roi, traceType, maxlag, upsampling)
    
    if nargin < 5
        upsampling = 5; % stimulus upsampling factor
        
    end
    
    if nargin < 4
        maxlag = 1.2; %sec
    end
    

    if nargin>1 && numel(id_roi) == 1 && isnumeric(id_roi)
        
        if nargin < 3
            traceType = 'smoothed_norm';
        end
        
        [rf, s] = rf_corr(r, id_roi, traceType, maxlag, upsampling); % sampled at f_times_norm
        
        subplot(1, 4, [1, 2]);
        plot_rf_map(r, rf, s);
        
        % time slice
        subplot(1, 4, 3);
        plot_rf_slice_t(r, rf, s);

        % x slice
        subplot(1, 4, 4);
        plot_rf_slice_x(r, rf, s);

            
    else
        % plot rf for all rois
        
        if nargin > 1 && ischar(id_roi)
            traceType = id_roi;
        else
            traceType = 'smoothed_norm';
        end

        % ex info
        S = sprintf('ROI %d*', 1:r.numRoi); C = regexp(S, '*', 'split'); % C is cell array.
        str_smooth_info = sprintf('smooth size %d (~%.0f ms bin)', r.smoothing_size, r.ifi*r.smoothing_size*1000);
        %str_events_info = sprintf('stim duration: %.1fs', r.stim_duration); 
        str_events_info = [];
        str_info = sprintf('%s\n%s', str_events_info, str_smooth_info);
        
        % subplot params
        n_row = 4;
        n_col = 5; % n_cells per figure
        
        %        
        if nargin < 2
            roi_array = 1:r.numRoi; % loop over all rois
        else
            roi_array = id_roi;     % loop over selected rois
        end
        
        n_cells = numel(roi_array);
        id_cell = 1; % cell index
        k = 1;       % subplot index
        x_fig = 0;
        make_figure(x_fig);
        
        while id_cell <= n_cells
        

            [rf, s] = rf_corr(r, roi_array(id_cell), traceType, maxlag, upsampling); % sampled at f_times_norm
            
            % map
            subplot(n_col, n_row, (k-1)*4 + [1, 2])
            plot_rf_map(r, rf, s);
                ax = gca;
                text(ax.XLim(end), ax.YLim(1), ['ROI: ', num2str(roi_array(id_cell))], 'FontSize', 11, 'Color', 'k', ...
                'VerticalAlignment', 'top', 'HorizontalAlignment','right');

            % time slice
            subplot(n_col, n_row, (k-1)*4 + 3);
            plot_rf_slice_t(r, rf, s);

            % x slice
            subplot(n_col, n_row, (k-1)*4 + 4);
            plot_rf_slice_x(r, rf, s);            
            
            % next cell
            id_cell = id_cell + 1; 
            
            % next subplot
            k = k+1;
            
            if k> n_col
                x_fig = x_fig + 800;
                make_figure(x_fig);
                k = 1;
            end
            
        end
        
            
        % Text comment on final subplot: (k+1) row
        subplot(k+1, 4, (k+1)*4);
        ax = gca; axis off;
        text(ax.XLim(end), ax.YLim(1), str_info, 'FontSize', 11, 'Color', 'k', ...
                    'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
        text(ax.XLim(end), ax.YLim(1), ['exp: ', r.ex_name], 'FontSize', 11, 'Color', 'k', ...
                'VerticalAlignment', 'top', 'HorizontalAlignment','right');
        %
        %saveas(gcf, [r.ex_name,'_ROI_whitenoise_corrRF.png']);

        
        

    end


end

% function plot_rf_map(r, rf, s)
% 
%     [num_x, num_t] = size(rf);
%     
%     imshow(rf, s.clim, 'Colormap', bluewhitered(64, s.clim)); % jet, parula, winter ..
%         axis on;
%         ax =gca; colorbar('TickLabels', []);
%         
%         time_tick_label = 1:2:(num_t*r.ifi*10); % [ 100 ms]
%         time_tick_locs = time_tick_label * 0.1 / r.ifi;
%         ax.XTick = time_tick_locs;
%         S = sprintf('%.0f*', time_tick_locs*r.ifi*10 ); time_label = regexp(S, '*', 'split'); % C is cell array.
%         ax.XTickLabel = {time_label{1:end-1}}; 
%         xlabel('[x100 ms]');
%         %
%         x_tick_spacing = 0.5; % [mm]
%         w_bar = r.stim_size/num_x;
%         x_center = num_x/2.;
%         x = 0:(x_tick_spacing/w_bar):(num_x/2.); % half size 
%         x = unique([-x, x]);
%         ax.YTick = x + x_center;
%         S = sprintf('%.1f*', x*w_bar ); C = regexp(S, '*', 'split'); % C is cell array.
%         ax.YTickLabel = {C{1:end-1}};
%         ylabel('[mm]');
%         ax.FontSize = 12;
% end
% 
% function plot_rf_slice_t(r, rf, s)
%     [num_x, num_t] = size(rf);
%     plot(s.slice_t, 'LineWidth', 1.5);
%         ax = gca;
%             time_tick_label = 1:2:(num_t*r.ifi*10); % [ 100 ms]
%             time_tick_locs = time_tick_label * 0.1 / r.ifi;
%             S = sprintf('%.0f*', time_tick_locs*r.ifi*10 ); time_label = regexp(S, '*', 'split'); % C is cell array.
%         ax.XTick = time_tick_locs;
%         ax.XTickLabel = {time_label{1:end-1}};
%         ax.YTick = 0;
%         %ax.YTickLabel = [];
%         ax.FontSize = 12;
%         xlabel('[x100 ms]');
%         ylabel('[a.u.]');
%         grid on
%         ylim([s.min s.max]);
% end
% 
% function plot_rf_slice_x(r, rf, s)
%     [num_x, num_t] = size(rf);
%     plot(s.slice_x, 'LineWidth', 1.5);
%         ax = gca;
% 
%         x_tick_spacing = 0.3; % [mm]
% 
%         w_bar = r.stim_size/num_x;
%         x_center = num_x/2.;
%         x = 0:(x_tick_spacing/w_bar):(num_x/2.); % half size 
%         x = unique([-x, x]);
%         x_tick_locs = x + x_center;
%         S = sprintf('%.1f*', x*w_bar ); C = regexp(S, '*', 'split'); % C is cell array.
% 
%         ax.XTick = x_tick_locs;
%         ax.XTickLabel = {C{1:end-1}};
%         ax.YTick = 0;
%         %ax.YTickLabel = [];
%         xlim([-0.1 num_x+0.1]);
%         xlabel('[mm]');
%         ylabel('[a.u.]');
%         grid on
%         ax.FontSize = 12;
%         ylim([s.min s.max]);
% end


function make_figure(x_shift, y_shift)
    
    if nargin < 2
        y_shift = 0;
    end
    if nargin < 1
        x_shift = 0;
    end
    
    pos_new = get(0, 'DefaultFigurePosition');
    %figure('Position', [pos_new(1) + x_shift, 100 + y_shift, 800, 1500]);
    figure('Position', [150 + x_shift, 100 + y_shift, 800, 1000]);
    axes('Position', [0  0  1  0.9524], 'Visible', 'off');
end