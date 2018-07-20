function plot_rf_slice_t(r, rf, s)
% Display rf time course. It is mainly how to draw plot. It may not work
% for 2D whitenoise. 
% 
% inputs:
%       s - stat of rf. Output of corr_rf function.

%     if nargin < 2
%         [rf, s] = rf_corr(r, id_roi, traceType, maxlag, upsampling); % sampled at f_times_norm
%     end
%     
    if nargin < 3
        s = [];
    end

    [num_x, num_t] = size(rf);
    
    if num_x == 1
        plot(rf(:), 'LineWidth', 1.5);
    else
        plot(s.slice_t, 'LineWidth', 1.5);
    end
    
        ax = gca;
            time_tick_label = 1:2:(num_t*r.ifi*10); % [ 100 ms]
            time_tick_locs = time_tick_label * 0.1 / r.ifi;
            S = sprintf('%.0f*', time_tick_locs*r.ifi*10 ); time_label = regexp(S, '*', 'split'); % C is cell array.
        ax.XTick = time_tick_locs;
        ax.XTickLabel = {time_label{1:end-1}};
        ax.YTick = 0;
        %ax.YTickLabel = [];
        ax.FontSize = 12;
        xlabel('[x100 ms]');
        ylabel('[a.u.]');
        grid on
        %ylim([s.min s.max]);
        axis tight
end
