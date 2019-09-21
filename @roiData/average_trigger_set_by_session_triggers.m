function average_trigger_set_by_session_triggers(r)
% List a sesstion triggers and get user input for average analysis.
    
    numStimTriggers = numel(r.stim_trigger_times);
    numSessTriggers = numel(r.sess_trigger_times);

    if numStimTriggers == numSessTriggers
        %
        str_input = sprintf('Same numberes of major nad minor triggers. Average analysis over all %d triggers? [Y]?\n (or enter how many stim triggers were in one repeat. Enter 0 if it is not repeated.)\n', numSessTriggers);
        n_every = input(str_input);
        if isempty(n_every)
            n_every = 1; 
        end
        
        switch n_every
            case 0
                % default baseline estimation & smoothing
                r.avg_FLAG = false;
                r.baseline;
            otherwise
                r.avg_every = n_every;
        end

    else
        % can be multiple scenarios.
        % 1. minor triggers are avg triggers, sess
        % triggers distinguish the set of mirror
        % triggers.
        % 2. Sess triggers are avg tiggers, minor
        % tiggers distinguish multiple kinds of stimuli
        % withing one cyle.
        disp('Average analysis between..');
        disp(['0. Major triggers (', num2str(numSessTriggers),' sessions).']);
        for i_sess = 1:numSessTriggers
            fprintf('%d. Minor triggers within session trigger %d (started at %.1f sec).\n', i_sess, i_sess, r.sess_trigger_times(i_sess));
        end
        str = sprintf('Which average analysis do you want? 0-%d [%d] or enter 99 for no average analysis.\n', i_sess, i_sess);
        which_avg = input(str);
        if isempty(which_avg); which_avg = i_sess; end

        switch which_avg
            case 0
                r.avg_trigger_times = r.sess_trigger_times;
                r.avg_FLAG = true;
                r.avg_analysis_name = 'over_all_sess_triggers'; % for save filename
            case 99
                % default baseline estimation & smoothing update
                r.avg_FLAG = false;
                r.baseline;
                r.avg_analysis_name = [];
            otherwise
                r.avg_trigger_times = r.stim_triggers_within(which_avg);
                r.avg_FLAG = true;
                r.avg_analysis_name = sprintf('stim_triggers_in_%d_session', which_avg);
                % update the representative image
                r.image = r.snaps(:,:,which_avg);
        end
    end
    
    disp(' ');
    r.average_analysis;
end