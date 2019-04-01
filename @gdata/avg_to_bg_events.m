function avg_vol = avg_to_bg_events(g)
% Avgeraged image stack over repeats relative to (bg cross-talk) triggers.
%
% Currently, avg over bg_event

%     if isempty(g.avg_trigger)
%         disp('No trigger times for average analysis');
%     elseif length(g.avg_trigger) < 2
%         disp('Only one trigger.');
%     else
%         % print avg_trigger?
%     end
%     
%     interval = g.avg_trigger(2) - g.avg_trigger(1);

    interval = g.bg_event_id(2) - g.bg_event_id(1);
    
    ch = g.roi_channel;
    
    n_repeat = length(g.bg_event_id);
    
    avg_vol = zeros([g.size, interval+1, ]);
    
    for i = 1:n_repeat
        
        i_start = bg_event_id(i);
        range = i_start:(i_start+interval);
        avg_vol(:,:,i) = g.AI{ch}(:,:,range);
        
    end
    
    avg_vol = mean(avg_vol, 4);
        
end