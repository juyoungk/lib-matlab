function h5FileOpenForStimTrigger(g, h5_filename)
% g.ex_name should be defined in advance
    

    if nargin < 2
        h5_filename = g.h5_filename;
    end
    
    if isempty(h5_filename)
        disp('No h5 file.');
        return;
    end

    % h5 file: PD
    % PD recording filename: {i}
    if isempty(h5_filename)
        disp(['No corresponding h5 (e.g. photodiode) file for ', tif_filename]);
        g.numStimulus = 1; % default value for numStimulus.
    else
        % import data from h5 
        [A, times, header] = load_analogscan_WaveSufer_h5(h5_filename);
        g.h5_AI = A;
        g.h5_times  = times;
        g.h5_header = header;
        g.h5_srate  = header.srate;
        name_h5 = strsplit(h5_filename, '/');
        g.h5_filename = name_h5{end};

        % Infer 'photodiode' channel
        numAI_Ch = numel(header.AIChannelNames);
        if numAI_Ch == 1
            pd = A;
        else
            PD_CH = find(strcmp(header.AIChannelNames, g.pd_AI_name));
            if numel(PD_CH) > 1
                disp(['More than 2 AI channels names ', g.pd_AI_name, '. First CH is selected for PD.']);
                PD_CH = PD_CH(1);
            end
            pd = A(:,PD_CH); % raw pd trace including any unwanted events.
        end

        % Rectified & normed PD trace
        % baseline: first 5 sec average
        baseline = mean( pd(1:(5*header.srate)) );
        pd = max(pd - baseline, 0);
        pd = scaled(pd);
        g.pd_trace = pd;

        % event timestamps from pd
        g.setting_pd_event_params();
        i_start = g.ignore_secs * header.srate + 1; % First pd data point index for thresholding.
        trace_for_events = pd(i_start:end);         % after skipping the first few seconds.
        %
        ev_idx = th_crossing(trace_for_events, g.pd_threshold1, g.min_interval_secs * header.srate);
        ev_idx = ev_idx + i_start - 1;
        ev = times(ev_idx);
        g.pd_events1 = ev;
        n_pd_events1 = numel(ev);

        % minnor events
        ev_idx = th_crossing(trace_for_events, g.pd_threshold2, g.min_interval_secs * header.srate);
        ev_idx = ev_idx + i_start - 1;
        ev = times(ev_idx);
        g.pd_events2 = ev;
        n_pd_events2 = numel(ev);

        % Stimulus cluster for multiple events (using only events1)
        g.stims = cell(1,10);
        g.stims_ids = cell(1,10);

        % Num of stimulus (Assumed to be 1) 
        g.numStimulus = 1; 
    %                         if n_pd_events1 <= 1
    %                             % one trigger time
    %                             g.stims{1} = ev;
    %                             g.numStimulus = 1;
    %                         elseif n_pd_events1 < 4
    %                             % Regard all different stimulus
    %                             for k=1:n_pd_events1
    %                                 g.stims{k}     = ev(k);
    %                                 g.stims_ids{k} = k;
    %                             end
    %                             g.numStimulus = n_pd_events1;
    %                         else
    %                             % n_events >= 4
    %                             % detect last event of the stimulus:
    %                             % increase in interval by 20 %
    %                             ev_interval = ev(2:end) - ev(1:end-1); % indicates the last event for stimulus
    %                             i_ev = 1;   % current   ev id
    %                                k = 0;   % current stim id
    %                             while i_ev < n_pd_events1
    %                                 % new stim id
    %                                 %i_ev;
    %                                 k = k + 1;
    %                                 % identify the next odd event
    %                                 % relative index for next odd event
    %                                 odd_events = find(ev_interval(i_ev:end) > ev_interval(i_ev)*1.2);
    % 
    %                                 if isempty(odd_events)
    %                                     g.stims{k} = ev(i_ev:end);
    %                                     g.stims_ids{k} = i_ev:n_pd_events1;
    %                                     g.intervals{k} = ev_interval(i_ev);
    %                                     break;
    %                                 end
    %                                 t_ev = i_ev + odd_events(1) - 1;
    %                                 g.stims{k} = ev(i_ev:t_ev);
    %                                 g.stims_ids{k} = i_ev:t_ev;
    %                                 g.intervals{k} = ev_interval(i_ev);
    %                                 i_ev = t_ev + 1;
    %                             end
    %                             g.numStimulus = k;
    %                         end

        % plot pd trace and trigger events
        g.pd_plot;

    end   % if h5 file exists.

end