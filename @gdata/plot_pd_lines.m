function plot_pd_lines(g, shift)
% pd_event2 (minor events) plot

    if nargin < 2
        shift = 0;
    end
    
    hold on
    
    ax = gca;
    
    times = g.pd_events2 + shift;
    n = length(times);
    
    for i = 1:n
        x = times(i);
        plot([x x], ax.YLim, '-', 'LineWidth', 1.0, 'Color', 0.4*[1 1 1]);
        
        % middle line
        if contains(g.ex_name, 'flash') && i < n 
            interval = times(i+1) - times(i);
            plot([x+interval/2, x+interval/2], ax.YLim, ':', 'LineWidth', 1.0, 'Color', 0.4*[1 1 1]);
        end
        
    end
    
    hold off
end