function plot_stim_lines(r)
    
    hold on
    
    ax = gca;
    
    times = r.stim_trigger_times;
    n = length(times);
    
    for i = 1:n
        x = times(i);
        plot([x x], ax.YLim, '-', 'LineWidth', 1.0, 'Color', 0.4*[1 1 1]);
        
        % middle line
        if contains(r.ex_name, 'flash') && i < n 
            interval = times(i+1) - times(i);
            plot([x+interval/2, x+interval/2], ax.YLim, ':', 'LineWidth', 1.0, 'Color', 0.4*[1 1 1]);
        end
        
    end
    
    hold off
end