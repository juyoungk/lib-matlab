function plot_rf_slice_t(r, s)
% inputs:
%       s - stat of rf. Output of corr_rf function.
    
    rf = s.rf;

    [num_x, num_t] = size(rf);
    plot(s.slice_t, 'LineWidth', 1.5);
        ax = gca;
        ax.XTick = s.XTick(end-3:end);
        ax.XTickLabel = s.XTickLabel(end-3:end);
        
        if abs(s.min) > abs(s.max)
            ax.YTick = [ax.YTick(1), 0];
        else
            ax.YTick = [0, ax.YTick(end)];
        end
        
        ax.FontSize = s.FontSize;
        ax.XLim(2) = num_t;
%         xlabel('delay (x0.1 s)');
%         ylabel('Filter (s^{-1})');
        %ylabel('correlation (norm.)')
        grid on
        %ylim([s.min s.max]);
end
