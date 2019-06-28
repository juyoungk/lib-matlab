%% analysis for RF

% Check time alignment between PTB and scanimage



numStimGroups = numel(r.stim);

for i=1:numStimGroups
    
    att = r.stim(i).Attributes;
    
    
    if contains(att(1).Name, 'function')
        % look for 'jumpevery'? --> future feature.
        
        if contains(att(1).Value, 'whitenoise')
            pd_event_every = 60; % frames. 'jumpevery' for naturalscene function.
            
        elseif contains(att(1).Value, 'naturalmovie')
            pd_event_every = 60; % frames. 'jumpevery' for naturalscene function.
        
        else
            disp('Default value.');
            pd_event_every = 60;
        end
        
    else
        
    end
    
    timestamps = r.stim(i).timestamps;
    
    nflips = length(timestamps);
    
    trigger = ~mod((1:nflips)-1, pd_event_every); % logical array labeling flips with pd triggers. 
    
    trigger_times_in_PTB = r.stim(i).starttime + timestamps(trigger);
    trigger_times_in_Scanimage = r.stim_triggers_within(r.stim(i).session_id);
    
    
    % compare
    if i == 1 % Plot only for the 1st group.
        figure;
        plot(trigger_times_in_PTB, '-*'); hold on
        plot(trigger_times_in_Scanimage, '-*'); hold off
        ff;
    end

end

