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
        
        colorbar('Ticks', [s.clim(1), 0, s.clim(2)], 'TickLabels', [{'OFF'}, {'0'}, {'ON'}], 'FontSize', 16);
       
        ax.XTick = s.XTick(end-3:end);
        ax.XTickLabel = s.XTickLabel(end-3:end);
        
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
        
        S = sprintf('%.0f*', x*w_bar * 1000 ); C = regexp(S, '*', 'split'); % C is cell array.
        ax.YTickLabel = {C{1:end-1}};
        
        %
        ax.YTick = [1, num_x];
        ax.YTickLabel = [{num2str(r.stim_size/2)}, {num2str(-r.stim_size/2)}];
        
        %xlabel('delay (x0.1 s)');
        %ylabel('[um]');
        
        
        ax.FontSize = s.FontSize;
end