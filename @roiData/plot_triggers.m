function plot_triggers(r, ax)
% Draw stimulus lines

if nargin < 2 
    ax = gca;
end

if ~contains(r.ex_name, 'whitenoise') && length(r.sess_trigger_times) <= 100
    
    
    % Lines for stim triggers: Plot only when the num of events are less
    % than 50.
    ev = r.stim_trigger_times;        
    
    if length(ev) <= 50
        for i=1:length(ev)
            
            plot([ev(i) ev(i)], ax.YLim, ':', 'LineWidth', 1.1, 'Color',0.5*[1 1 1]);
        
            % middle line
            if contains(r.ex_name, 'flash') && numel(ev) > 1
                interval = ev(2)-ev(1);
                plot([ev(i)+interval/2, ev(i)+interval/2], ax.YLim, ':', 'LineWidth', 1.0, 'Color',0.5*[1 1 1]);
            end
        end

    end

    
    % Lines for session triggers   
    ev = r.sess_trigger_times;        
    
    for i=1:length(ev)
        plot([ev(i) ev(i)], ax.YLim, '-', 'LineWidth', 1.1, 'Color',0.6*[1 1 1]);
        
    end
        
else
    
    % Plot only start & end line
    ev = r.sess_trigger_times;        
    
    plot([ev(1) ev(1)], ax.YLim, '-', 'LineWidth', 1.1, 'Color',0.6*[1 1 1]);
    plot([ev(end) ev(end)], ax.YLim, '-', 'LineWidth', 1.1, 'Color',0.6*[1 1 1]);
    
end


end