function RF = stimAvg_aheadEvents(stim, stim_binedges, event_stamps)
% stim - stimulus data (N by M by # frames)
% stim_binedges - Real time edge stamps of the stimulus frame or bin
% event_stamps - Real time stamps of the events (ms)
stimSnippetAvg = [];

% how long do you want to see the stimulus that elicit the event?
nframe = 20; % frameduration 30 ms * 20 = 600 ms

totframeN = max(size(stim));

% where are those events in the stim bin ?
% Convert event real-time stamps into stim bin timestamps (index)
% and # of events 
% Length(Nevent) = Length(# frame) + 1
Nevents = histc(event_stamps, stim_binedges);

% last element is adding to the former element. 
Nevents(end-1) = Nevents(end-1) + Nevents(end);
Nevents = Nevents(1:end-1);

% gather the stim snippet
% index number for the timing when the event happened. 
idx = find(Nevents>0); 
% ignore the first few frames shorter than nframe, and last element.
idx = idx(idx>nframe);
% Now, idx has same length as stim frame rate

% What are the stimulus ahead of those events?
for i = 1:max(size(idx))
    % i should be >nframe
    stimSnippetAvg = stimSnippetAvg + ...
        Nevents(idx(i))*stim(:, :, (idx(i)-nframe):idx(i) );
end

RF = stimSnippetAvg;

end
