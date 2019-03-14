function ax = plot_trace_raw(r, id_roi)
% plot roi_trace & trend

    if nargin>1 && numel(id_roi) == 1
        % plot single roi trace (smoothed)
        plot(r.f_times,     r.roi_trace(:,id_roi), 'LineWidth', 0.7); hold on
        plot(r.f_times_fil, r.roi_trend(:,id_roi), 'LineWidth', 0.7);
        %title([r.ex_name]);
        title('raw trace');
        %legend('raw trace (bg substracted)', 'F (trend)');
            ylabel('a.u.'); axis auto;
            ax = gca; 
            Fontsize = 16;
            ax.XAxis.FontSize = Fontsize;
            ax.YAxis(end).FontSize = Fontsize;
            ax.XLim = [0 r.f_times(end)];
            axis tight
            
        % stimulus lines
        ev = r.stim_trigger_times; % all 
        
        %if isempty(strfind(r.ex_name, 'whitenoise')) && isempty(strfind(r.ex_name, 'runjuyoung')) && isempty(strfind(r.ex_name, 'runme'))    
        if ~contains(r.ex_name, 'whitenoise') && length(ev) <= 400
            i_last = length(ev);
            for i=1:i_last
                % all stim trigger times 
                plot([ev(i) ev(i)], ax.YLim, '-', 'LineWidth', 1.1, 'Color',0.6*[1 1 1]);
                % middle line
                if strfind(r.ex_name, 'flash') && i < i_last 
                    interval = ev(i+1) - ev(i);
                    plot([ev(i)+interval/2, ev(i)+interval/2], ax.YLim, ':', 'LineWidth', 1.0, 'Color',0.5*[1 1 1]);
                end
            end
        else
            % 1st & last event lines
            plot([ev(1) ev(1)], ax.YLim, '-', 'LineWidth', 1.1, 'Color',0.6*[1 1 1]);
            plot([ev(end) ev(end)], ax.YLim, '-', 'LineWidth', 1.1, 'Color',0.6*[1 1 1]);
        end
        hold off
    else
        % No id for ROI: plot all trace
        % figure
        pos_new = get(0, 'DefaultFigurePosition');
        figure('Position', [pos_new(1), 100, pos_new(3)*2.4, pos_new(4)*2]);
        axes('Position', [0  0  1  0.9524], 'Visible', 'off');
        title(r.ex_name);
        
        % subplot parameters
        n_col_subplot = 3; % raw trace plot
        n_row = ceil(r.numRoi/n_col_subplot);
        
        % ex info
        S = sprintf('ROI %d*', 1:r.numRoi); C = regexp(S, '*', 'split'); % C is cell array.
        str_smooth_info = sprintf('smooth size %d (~%.0f ms bin)', r.smoothing_size, r.ifi*r.smoothing_size*1000);
        %str_events_info = sprintf('ev interval: %.1fs', r.s_times(end)); 
        %str_info = sprintf('%s\n%s', str_events_info, str_smooth_info);
        
        if nargin < 2
            roi_array = 1:r.numRoi; % loop over all rois
        else
            roi_array = id_roi;     % loop over selected rois
        end
        
        for rr = roi_array
            [ii, jj] = ind2sub([n_row, n_col_subplot], rr);
            id_subplot = sub2ind([n_col_subplot, n_row], jj, ii);
            
            %
            subplot(n_row, ceil(r.numRoi/n_row), id_subplot);
            % single roi trace plot
            ax = plot_trace_raw(r, rr);
                
            text(ax.XLim(end), ax.YLim(end), C{rr}, 'FontSize', 8, 'Color', 'k', ...
                    'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');

            % bottom-most subplot: x label
            if any([rem(rr,n_row)==0, rr == r.numRoi])
                ax.XTickLabel = linspace(ax.XTick(1),ax.XTick(end),numel(ax.XTick));
                xlabel('sec');
            end

        end
        
        % Text comment on final subplot
        subplot(n_row, n_col_subplot, n_row*n_col_subplot);
        ax = gca; axis off;
        text(ax.XLim(end), ax.YLim(1), str_smooth_info, 'FontSize', 11, 'Color', 'k', ...
                    'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
        text(ax.XLim(end), ax.YLim(1), ['exp: ', r.ex_name], 'FontSize', 11, 'Color', 'k', ...
                    'VerticalAlignment', 'top', 'HorizontalAlignment','right');
        %makeFigBlack;
        saveas(gcf, [r.ex_name,'_ROI_traces.png']);
        
    end
        
    
end