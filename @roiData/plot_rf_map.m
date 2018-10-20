function plot_rf_map(r, rf, s)
% 's' is stat of the rf
%
    if nargin <3 
        nearby = 0;
        s = rf_stat(r, rf, nearby);
    end

    [num_x, num_t] = size(rf);
    
    imshow(rf, s.clim, 'Colormap', bluewhitered(64, s.clim)); % jet, parula, winter ..
        axis on;
        ax =gca; colorbar('TickLabels', []);
        
        time_tick_label = 1:2:(num_t*r.ifi*10); % [ 100 ms]
        time_tick_locs = time_tick_label * 0.1 / r.ifi;
        ax.XTick = time_tick_locs;
        S = sprintf('%.0f*', time_tick_locs*r.ifi*10 ); time_label = regexp(S, '*', 'split'); % C is cell array.
        ax.XTickLabel = {time_label{1:end-1}}; 
        xlabel('[x100 ms]');
        %
        x_tick_spacing = 0.5; % [mm]
        if isempty(r.stim_size) || isnan(r.stim_size)
            disp('stim_size was not yet given. default w_bar = 50 um is used.');
            w_bar = 0.05;
        else    
            w_bar = r.stim_size/num_x;
        end
        x_center = num_x/2.;
        x = 0:(x_tick_spacing/w_bar):(num_x/2.); % half size 
        x = unique([-x, x]);
        ax.YTick = x + x_center;
        S = sprintf('%.1f*', x*w_bar ); C = regexp(S, '*', 'split'); % C is cell array.
        ax.YTickLabel = {C{1:end-1}};
        ylabel('[mm]');
        ax.FontSize = 12;
end