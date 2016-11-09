function RF = evTriggerAvg(stim, stim_binedges, num_avgbin, event_stamps)
%
% RF (or avg) = evTriggerAvg(stim, stim_binedges, num_avgbin, event_stamps)
%
% stim - stimulus data (N by M by # frames)
% stim_binedges - Real time edge stamps of the stimulus frame or bin
% num_avgbin - how long do you want to see the stimulus ahead of the
% response?
% event_stamps - Real time stamps of the events (ms)

% initialize avg matrix as an unsigned integer
%nbox = size(stim,1);
avg = zeros(size(stim,1), size(stim,2), num_avgbin,'uint32');

% how long do you want to see the stimulus that elicit the event?
% n_avgbin = 20; % frameduration 30 ms * 20 = 600 ms

% where are those events in the stim bin ?
% Convert event real-time stamps into stim bin timestamps (index)
% and # of events 
% Length(Nevent) = Length(# frame) + 1
Nevents = histc(event_stamps, stim_binedges);

% last element is adding to the former element. 
Nevents(end-1) = Nevents(end-1) + Nevents(end);
Nevents = Nevents(1:(end-1));

% gather the stim snippet
% index number for the timing when the event happened. 
idx = find(Nevents>0); 
% ignore the first few frames shorter than nframe, and last element.
idx = idx(idx>num_avgbin);
% Now, idx has same length as stim frame rate
if isempty(idx)  
    disp('FUNCTION: evTriggerAvg: no elements in idx');
    return;
end

% What are the stimulus ahead of those events?
for i = 1:length(idx)
    num = Nevents(idx(i));
    snippet = stim(:, :, (idx(i)-num_avgbin+1):idx(i) );
    avg = avg + num * cast(snippet, 'uint32');
end

RF = double(avg)/sum(Nevents(idx));
% RF = cast( double(avg)/sum(Nevents(idx)), 'uint8' );

end
