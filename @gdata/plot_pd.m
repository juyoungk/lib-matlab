function plot_pd(g)
% plot pd_trace, pd_times with detected thresholding events. 

    if isempty(g.pd_trace)
        disp('No trace was assigned to pd_trace.');
        return;
    end

    pos = gdata.figure_setting();
    pos_plot = [1800,            pos(2), pos(3), pos(3)*2./3.];
    figure; set(gcf, 'Position', pos_plot);
    
    % Plot pd_trace
    times = g.pd_times;
    plot(times(times > g.ignore_secs), g.pd_trace(times > g.ignore_secs)); 
    hold on; % PD trace
    
    % PD trigger events 1
    for ii = 1:g.numStimulus % color coding for clustered PD events.    
        %plot( g.pd_events1(g.stims_ids{ii}), g.pd_threshold1, 'o'); %g.pd_trace( ev_idx(g.stims_ids{ii})
        plot( g.pd_events1, g.pd_threshold1, 'o');
    end
    
    % PD trigger events 2
    for ii = 1:g.numStimulus % color coding for clustered PD events.    
        plot( g.pd_events2, g.pd_threshold2, 'o'); %g.pd_trace( ev_idx(g.stims_ids{ii})
    end
    
    text = sprintf('Trigger Event 1: %d\nTrigger Event 2: %d', length(g.pd_events1), length(g.pd_events2));
    legend(text, 'Location', 'southeast');
    
    hold off
    
    disp(text);
end
