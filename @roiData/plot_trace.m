function plot_trace(r, id_roi)
    if nargin>1
        % plot single roi trace
        plot(r.f_times, r.roi_trace(:,id_roi));
        
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
        
        % stimulus
        ev = r.stim_times;
        interval = ev(2)-ev(1);
        
        % ex info
        S = sprintf('ROI %d*', 1:r.numRoi); C = regexp(S, '*', 'split'); % C is cell array.
        str_smooth_info = sprintf('smooth size %d (~%.0f ms bin)', r.smoothing_size, r.ifi*r.smoothing_size*1000);
        str_events_info = sprintf('ev interval: %.1fs', interval); 
        str_info = sprintf('%s\n%s', str_events_info, str_smooth_info);

        for rr = 1:r.numRoi % loop over rois
            [ii, jj] = ind2sub([n_row, n_col_subplot], rr);
            id_subplot = sub2ind([n_col_subplot, n_row], jj, ii);
            %
            subplot(n_row, ceil(r.numRoi/n_row), id_subplot);
            
            % raw trace vs smoothed trace?
            plot(r.f_times, r.roi_smoothed(:,rr), 'LineWidth', 1.5); hold on
            
                ylabel('a.u.');
                axis auto;
                ax = gca; Fontsize = 10;
                ax.XAxis.FontSize = Fontsize;
                ax.YAxis.FontSize = Fontsize;
                ax.XLim = [0 r.f_times(end)];
                
            text(ax.XLim(end), ax.YLim(end), C{rr}, 'FontSize', 8, 'Color', 'k', ...
                    'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
            for i=1:length(ev)
                plot([ev(i) ev(i)], ax.YLim, '-', 'LineWidth', 1.1, 'Color',0.6*[1 1 1]);
                %plot([ev(i)+interval/2, ev(i)+interval/2], ax.YLim, ':', 'LineWidth', 1.0, 'Color',0.5*[1 1 1]);
            end   
            hold off

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