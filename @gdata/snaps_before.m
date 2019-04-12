function snaps = snaps_before(g, times, duration)
% times : array of times (e.g. major triggers)

if nargin < 3
    duration = 5; %secs
end

if nargin < 2
    times = g.pd_events1;
end

ch = g.roi_channel;
n = length(times);
snaps = zeros([g.size, n]);

if duration > times(1)
    disp('Not enough time before the first trigger time. Duration was modified.');
    duration = g.frameid(times(1));
else
    duration = g.frameid(duration);
end

for i=1:n
    id = g.frameid(times(i));
    range = id-duration+1:id; % before the trigger time
    snaps(:,:,i) = mean(g.AI{ch}(:,:,range), 3);
end

end