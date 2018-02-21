function plot_avg(r, id_roi)    
    if nargin>1
        % plot single roi avg trace
        plot(r.s_times, r.avg_trace(:,id_roi));
    else
        % No id for ROI: plot all trace
        
        % figure info
        pos_new = get(0, 'DefaultFigurePosition');
        figure('Position', [pos_new(1), 100, pos_new(3)*2.4, pos_new(4)*2]);
        axes('Position', [0  0  1  0.9524], 'Visible', 'off');
        title(r.ex_name);
        
        % ex info
        S = sprintf('ROI %d*', 1:r.numRoi); C = regexp(S, '*', 'split'); % C is cell array.
        str_smooth_info = sprintf('smooth size %d (~%.0f ms bin)', r.smoothing_size, r.ifi*r.smoothing_size*1000);
        str_events_info = sprintf('stim duration: %.1fs', r.stim_duration); 
        str_info = sprintf('%s\n%s', str_events_info, str_smooth_info);
        
        % subplot parameters
        n_row = 4;
        n_col = ceil(r.numRoi/n_row);
        
        % stimulus
        ev = r.stim_times;
        interval = ev(2)-ev(1);
        
        % double times in case for drawing 2 periods
        if strfind(r.ex_name, 'flash')
            s_times = [r.s_times, r.s_times + r.stim_duration];
        else
            s_times = r.s_times;
        end
        
        for rr = 1:r.numRoi % loop over rois
            
            subplot(n_row, n_col, rr);
            
            % smoothed trace
            y = r.avg_trace(:, rr);
            
            % 2 periods in case of flash stimulus
            if strfind(r.ex_name, 'flash')
                y = [y; y];
            end
            
            plot(s_times, y, 'LineWidth', 1.5); hold on
                axis on;
                ax = gca; Fontsize = 10;
                ax.XAxis.FontSize = Fontsize;
                ax.YAxis.FontSize = Fontsize;
                
                if strfind(r.ex_name, 'flash')
                    ax.XLim = [0 2*interval];
                    ax.XTick = 0:(interval/2):(2*interval);                  
                    % Additional line for On-Off transition.
                    plot([0 0], ax.YLim, 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
                    plot([interval, interval], ax.YLim, 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
                    plot([interval*0.5, interval*0.5], ax.YLim, '--', 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
                    plot([interval*1.5, interval*1.5], ax.YLim, '--', 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]); 

                else
                    % moving bar or etc.
                    ax.XLim = [0 interval];
                    ax.XTick = [];
                end
                hold off
                xtickformat('%.0f');     
                text(ax.XLim(end), ax.YLim(1), C{rr}, 'FontSize', 9, 'Color', 'k', ...
                    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
                
                % bottom-most subplot: x label
                if any([rr == r.numRoi])
                    xlabel('sec');
                end
                
             
        end
        % Text comment on final subplot
        subplot(n_row, ceil(r.numRoi/n_row), n_row*ceil(r.numRoi/n_row));
        ax = gca; axis off;
        text(ax.XLim(end), ax.YLim(1), str_info, 'FontSize', 11, 'Color', 'k', ...
                    'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
        text(ax.XLim(end), ax.YLim(1), ['exp: ', r.ex_name], 'FontSize', 11, 'Color', 'k', ...
                'VerticalAlignment', 'top', 'HorizontalAlignment','right');
        %
        saveas(gcf, [r.ex_name,'_ROI_avg_trace__smoothging',num2str(r.smoothing_size),'_tiled.png']);
        
    end
            
end