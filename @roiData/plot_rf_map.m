function plot_rf_map(r, rf, s)
% VIsualize RF by using imshow. 's' is stat of the rf
%
    if nargin <3 
        s = rf_stat(r, rf);
    end

    [num_x, num_t] = size(rf);
    % axis ratio for space
    im_ratio = (2 * num_t) / (3 * num_x);
    
    imshow(rf, s.clim, 'Colormap', bluewhitered(64, s.clim)); % jet, parula, winter ..
    
        axis on;
        
        ax =gca; 
        ax.DataAspectRatio = [im_ratio 1 1];
        
        colorbar('Ticks', s.clim, 'TickLabels', [{'-'},{'+'}]);
       
        ax.XTick = s.XTick;
        ax.XTickLabel = s.XTickLabel;
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
        ax.YTick = [];
        
        S = sprintf('%.0f*', x*w_bar * 1000 ); C = regexp(S, '*', 'split'); % C is cell array.
        ax.YTickLabel = {C{1:end-1}};
        
        %ylabel('[um]');
        
        ax.FontSize = s.FontSize;
end