function pd_events_detect(g, trace, times)
% 1. Preprocess the trace and assign it as 'pd_trace'
% 2. Detect events from the trace after g.ignore_secs.
    
    if nargin < 3 
        if ~isempty(g.pd_times)
            times = g.pd_times;
        else
            error('no input for times.');
        end
    end
    
    if nargin < 2
        if ~isempty(g.pd_trace)
            trace = g.pd_trace;
        else
            error('no input for trace.');
        end
    end
        
    % Rectified & normed PD trace
    % baseline: first 5 sec average
    baseline = mean( trace(times < 5.0) );
    trace = max(trace - baseline, 0);
    trace = scaled(trace);
    
    % Assign the rectified & normed trace to pd_trace.
    g.pd_trace = trace;
    g.pd_times = times;

    % event timestamps from pd
    g.setting_pd_event_params();
    
    % Detect events only after g.ignore_sec
    %i_start = g.ignore_secs * header.srate + 1; % First pd data point index for thresholding.
    
    trace_for_events = trace(times > g.ignore_secs);
    times_for_events = times(times > g.ignore_secs);
    interval = sum((times - times(1)) < g.min_interval_secs); % num of data points.
    % interval = g.min_interval_secs * rate ;
    
    % Minnor events
    ev_idx = th_crossing(trace_for_events, g.pd_threshold2, interval);
    ev = times_for_events(ev_idx);
    g.pd_events2 = ev;
    
    % Pick major events among minor.
    ev_idx = th_crossing(trace_for_events, g.pd_threshold1, interval);
    ev = times_for_events(ev_idx); % Detection by thresholding. Can be behind the corresponding minor trigger.
    
    n_major_ev = length(ev);
    ev_major = zeros(1,n_major_ev);
    for i=1:n_major_ev
        % Select previous or coincident events.
        prev_ev = g.pd_events2(g.pd_events2 - ev(i) <= 0);
        % Choose the latest event among previous events.
        ev_major(i) = max(prev_ev);
    end
    g.pd_events1 = ev_major;

    % plot detected events with pd trace.
    g.plot_pd;

end