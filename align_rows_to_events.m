function [y_aligned, qx] = align_rows_to_events(y, x, events, duration)
%
% Collect a fixed amount of data right after the events and align relative
% to the events. If you want to compute Pearson correlation from the output
% 'y_aligned', please see the function CORR_AVG.
%
% inputs:
    % y - signal of interest (row index ~ time-varying signal, col ~
    % roi#)
    % x - timestamps of signal
    % events   - array of timestamps
    % duration - for which you want to copy after the event
% Output:
    % y_aligned - (n_sampling(e.g. time), n_cells, n_events) matrix 

if size(x) < 2
    error('Timestamps(x) is too short. Not enough data.');
end

% calculate ifi fusing the first two time points
ifi = x(2)-x(1);

%
n_sampling = floor(duration*(1./ifi));

% 
[n_times, n_cells] = size(y);
if n_times ~= length(x)
    error('time mismatch.');
end

% Events number given by user.
n_events = length(events);

% Count only available events. 
%n_repeats = floor((x(end) - events(1))/duration);
n_repeats = sum((events + duration) < x(end));

if n_repeats < n_events
    fprintf('Event duraion = %.2f. Last data timepoint = %.1f, Last event timestamp = %.1f. Only %d repeats was in dataset (y).\n', duration, x(end), events(end), n_repeats);
end

% Create zero array for output.
y_aligned = zeros(n_sampling, n_cells, n_repeats);

for i=1:n_repeats
    % index for the onset of the event
    a = events(i);
    idx = find(x>=a);
    id = idx(1);

%     if (id+n_sampling-1) > n_times
%         disp('ERROR: Event +duration goes over the recorded signal. ');
%         disp([num2str(i-1), ' repeats were aligned relative to event times. (supposed to be ', num2str(length(events)),' repeats)']);
%         break; 
%     end
    
    qy = y(id:id+n_sampling-1,:);

    y_aligned(:,:,i) = qy;
    
end

qx = ((1:n_sampling)-0.5)*ifi;
% why -0.5? 
% First index after the event can have a delay of (0 ifi).

end