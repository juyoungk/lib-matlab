function [y_aligned, qx] = align_analog_signal_to_events(y, x, events, duration)
%
% Collect a fixed amount of data right after the events and align relative
% to the events
% (roi_traces, f_times, events, duration)
% inputs:
    % y - signal of interest (row index ~ ROI or cell or experiments, col ~
    % time)
    % x - timed timestamps
    % events   - array of times
    % duration - for which you want to copy after the event
% Output:
    % y_aligned - (n_cells, n_sampling, n_events) matrix 

if size(x) < 2
    error('Timestamps(x) is too short. Not enough data.');
end

% calculate ifi fusing the first two time points
ifi = x(2)-x(1);
%
n_sampling = floor(duration*(1./ifi));

%
[n_cells, n_times] = size(y);
n_events = length(events);
%
y_aligned = zeros(n_cells, n_sampling, n_events);

for i=1:length(events)
    
    % id for the event
    a = events(i);
    idx = find(x>=a);
    id = idx(1);

    %qx = x(idx);
    if (id+n_sampling-1) > n_times
        error('Event +duration goes over the recorded signal');
    end
    
    qy = y(:,id:id+n_sampling-1);

    y_aligned(:,:,i) = qy;
    
end

qx = (1:n_sampling)*ifi;

end