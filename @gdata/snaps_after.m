function vol = snaps_after(g, times, duration)
% mean snap over the duration after triggers in times array.
% times : array of times (e.g. major triggers)

    if nargin < 3
        duration = 5; %secs
    end

    if nargin < 2
        times = g.pd_events1;
    end

    ch = g.roi_channel;
    n = length(times);
    vol = zeros([g.size, n]);

    if duration > g.f_times(end) - times(1)
        error('Not enough time even after the first trigger time.');
    else
        duration = g.frameid(duration);
    end

    for i=1:n
        id = g.frameid(times(i));
        range = id:id+duration-1;
        vol(:,:,i) = mean(g.AI{ch}(:,:,range), 3);
    end

    imvol(vol, 'globalContrast', true);

end