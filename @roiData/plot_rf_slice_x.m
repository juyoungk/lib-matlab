function plot_rf_slice_x(r, rf, s)
    [num_x, num_t] = size(rf);
    plot(s.slice_x, 'LineWidth', 1.5);
        ax = gca;

        x_tick_spacing = 0.3; % [mm]

        w_bar = r.stim_size/num_x;
        x_center = num_x/2.;
        x = 0:(x_tick_spacing/w_bar):(num_x/2.); % half size 
        x = unique([-x, x]);
        x_tick_locs = x + x_center;
        S = sprintf('%.1f*', x*w_bar ); C = regexp(S, '*', 'split'); % C is cell array.

        ax.XTick = x_tick_locs;
        ax.XTickLabel = {C{1:end-1}};
        ax.YTick = 0;
        %ax.YTickLabel = [];
        xlim([-0.1 num_x+0.1]);
        xlabel('[mm]');
        ylabel('[a.u.]');
        grid on
        ax.FontSize = 12;
        ylim([s.min s.max]);
end