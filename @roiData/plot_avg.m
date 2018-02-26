function ax = plot_avg(r, id_roi, varargin)

    duration = r.s_times(end);
    
    if nargin >1
        % plot single roi avg trace
        y = r.avg_trace(:,id_roi);
        y = r.traceForAvgPlot(y);
        
        plot(r.a_times, y, 'LineWidth', 1.5, varargin{:}); hold on;
        ax = gca;  Fontsize = 10; 
        ax.XLim = [r.a_times(1), r.a_times(end)];
        ax.XAxis.FontSize = Fontsize;
        ax.YAxis.FontSize = Fontsize;
        % XTick positions: independent of phase value
        ax.XTick = (0:0.5:(r.n_cycle)) * duration;
%         ax.XTickLabel = linspace(- r.s_phase * duration, (r.n_cycle-r.s_phase)*duration, length(ax.XTick));  
        xtickformat('%.0f');
        
        % additional lines
        for n = 1:r.n_cycle
            x = (n-1) * duration;
            plot([x x], ax.YLim, 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
            % middle line
            if strfind(r.ex_name, 'flash')
                x = (n-1) * duration + duration/2.;
                plot([x x], ax.YLim, '--', 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
            end
        end
        hold off;

    else
    % No id for ROI: plot all trace
        
        % ex info
        S = sprintf('ROI %d*', 1:r.numRoi); C = regexp(S, '*', 'split'); % C is cell array.
        str_smooth_info = sprintf('smooth size %d (~%.0f ms bin)', r.smoothing_size, r.ifi*r.smoothing_size*1000);
        str_events_info = sprintf('stim duration: %.1fs', r.stim_duration); 
        str_info = sprintf('%s\n%s', str_events_info, str_smooth_info);
                
        % subplot params
        n_row = 4;
        n_col = 8; % limit num of subplots by fixing n_col
        % Figure params
        n_cells_per_fig = 30;
        
        %        
        rr = 1;
        while (rr <= r.numRoi)
        %while (rr <= 30)
        
            % figure info
            pos_new = get(0, 'DefaultFigurePosition');
            figure('Position', [pos_new(1), 100, pos_new(3)*2.4, pos_new(4)*2]);
            axes('Position', [0  0  1  0.9524], 'Visible', 'off');
            title(r.ex_name);

            %for rr = 1:r.numRoi % loop over rois
            for i = 1:n_cells_per_fig % subplot index
                
                    if rr > r.numRoi; break; end;

                    subplot(n_row, n_col, i);
                    % plot for roi# rr
                    ax = r.plot_avg(rr);
                    
                    text(ax.XLim(end), ax.YLim(1), C{rr}, 'FontSize', 9, 'Color', 'k', ...
                        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');                   
                   
                    % bottom-most subplot: x label
                    if any(i == n_cells_per_fig)
                        xlabel('sec');
                    end
                    % increase roi id
                    rr = rr + 1;
            end
            
            % Text comment on final subplot
            subplot(n_row, n_col, n_row*n_col);
            ax = gca; axis off;
            text(ax.XLim(end), ax.YLim(1), str_info, 'FontSize', 11, 'Color', 'k', ...
                        'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
            text(ax.XLim(end), ax.YLim(1), ['exp: ', r.ex_name], 'FontSize', 11, 'Color', 'k', ...
                    'VerticalAlignment', 'top', 'HorizontalAlignment','right');
            %
            saveas(gcf, [r.ex_name,'_ROI_avg_trace__smoothging',num2str(r.smoothing_size),'_tiled.png']);
        end
    end
            
end