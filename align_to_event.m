function ts_ev = align_to_event(ts, ev, varargin)
% 
% ts: time stamps of spikes. (array)
% ev: time stamps of events (sacacdes or first frame of repeated stimulus)
% ts_ev: (Nx1) "cell" array. time stamps relative to the event stamps
% (subtraction).

N_ev = length(ev);
N_ts = length(ts);

if N_ev>1
    ev_duration = ev(2) - ev(1);
elseif N_ev == 1
    disp('Only one event stamp. ts was subtracted by the timing');
    ts_ev = ts - ev;
    return;
else
    disp('No event time stamp');
    return;
end

% Create cells
ts_ev = cell(N_ev, 1);
% first idx for ts "after" 1st event
idx_start = find( ts >= ev(1) );

for i = 1:N_ev 
    % end time of the event
    if i < N_ev 
        end_of_event = ev(i+1);
    else
        end_of_event = ev(i) + ev_duration;
    end
    
    % first ts (of spike) for the next event
    idx_next  = find( ts >= end_of_event);
    
    % last index for ts
    if isempty(idx_next)
        idx_end = N_ts; % up to the last element in the ts
    else
        idx_end = idx_next(1) - 1;
    end
    
    % timing relative to the event
    %ts_ev{i} = ts(idx_start:idx_end); 
    ts_ev{i} = ts(idx_start:idx_end) - ev(i); 
    
    % start index for the next loop
    if isempty(idx_next)
        break;
    end
    idx_start = idx_next(1);
    
end


end


