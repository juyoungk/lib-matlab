function pd_plot(g)
    
    pos = gdata.figure_setting();
    
    i_start = g.ignore_secs * g.h5_header.srate + 1; % first pd data point index for thresholding.
    
    % plot pd % event stamps

%     n = g.header.n_channelSave;
%     n = 3;
%     pos_plot = [pos(1)+pos(3)*n, pos(2), pos(3), pos(3)*2./3.];
    
    pos_plot = [1800,            pos(2), pos(3), pos(3)*2./3.];
    figure; set(gcf, 'Position', pos_plot);
    plot(g.h5_times(i_start:end), g.pd_trace(i_start:end)); hold on; % PD trace
    
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
