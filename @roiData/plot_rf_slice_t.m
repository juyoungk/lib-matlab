function plot_rf_slice_t(r, s)
% inputs:
%       s - stat of rf. Output of corr_rf function.
    
    rf = s.rf;

    [num_x, num_t] = size(rf);
    plot(s.slice_t, 'LineWidth', 1.5);
        ax = gca;
        ax.XTick = s.XTick(end-3:end);
        ax.XTickLabel = s.XTickLabel(end-3:end);
        ax.YTick = 0;
        ax.FontSize = s.FontSize;
        ax.XLim(2) = num_t;
        xlabel('[x100 ms]');
        %ylabel('[a.u.]');
        grid on
        %ylim([s.min s.max]);
end
