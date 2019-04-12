function avg_to_pd_events(g)
% Avgeraged image stack over repeats relative to PD (stim) triggers.
    
    disp('Average analysis..');
    numSessTriggers = numel(g.pd_events1);
    numStimTriggers = numel(g.pd_events2);
    
    % Let's determin which tiggers are avg trigger times.
    if numStimTriggers == numSessTriggers
        %
        str_input = sprintf('Same numberes of major nad minor triggers. Average analysis over all %d triggers? [Y]?\n Enter 0 if it is not repeated.)\n', numSessTriggers);
        n = input(str_input);
        if isempty(n)
            g.avg_trigger_times = g.pd_events2;   
        elseif n == 0
            %g.avg_trigger_times = [];
            % do nothing.
        else
            disp('Wrong input.');
            return
        end
    else

        disp(['0. Major triggers (', num2str(numSessTriggers),').']);
        for i_sess = 1:numSessTriggers
            fprintf('%d. Minor triggers within session trigger %d (at %.1f sec).\n', i_sess, i_sess, g.pd_events1(i_sess));
        end
        str = sprintf('Which average analysis do you want? 0-%d [%d] or enter 99 for no average analysis.\n', i_sess, i_sess);
        which_avg = input(str);
        if isempty(which_avg); which_avg = i_sess; end

        switch which_avg
            case 0
                g.avg_trigger_times = g.pd_events1;
            case 99
                % default actions
            otherwise
                g.avg_trigger_times = g.pd_events_within(which_avg);
        end
        
    end
    
    % smoothing ..
    
    
     
    n_repeat = length(g.avg_trigger_times);
    interval = g.frameid(g.avg_trigger_times(2) - g.avg_trigger_times(1)); % in terms of num of frames.
    
    ch = g.roi_channel;
    avg_vol = zeros([g.size, interval, n_repeat]); % 4D tensor
    
    for i = 1:n_repeat
        
        i_start = g.frameid(g.avg_trigger_times(i));
        range = i_start:(i_start+interval-1);
        avg_vol(:,:,:,i) = g.AI{ch}(:,:,range);
        
    end
    
    g.avg_vol = mean(avg_vol, 4);
    %
    imvol(g.avg_vol, 'title', 'avg stack', 'scanZoom', g.header.scanZoomFactor, 'globalContrast', true);
end
