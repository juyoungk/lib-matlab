function vol = snaps_avg(g, id_pd_events)
% avg snaps during the first half and the last half over repeats

    % select times by session (major trigger) id.
    times = g.pd_events_within(id_pd_events);
    
    interval = times(2:end) - times(1:end-1);
    interval = min(interval);
    
    % snaps
	snaps1 = g.snaps_after(times, interval/2.);
    snaps2 = g.snaps_after(times+interval/2., interval/2.);
    
    vol = cat(mean(snaps1, 3), mean(snaps2, 3), 3);
    
    imvol(vol, 'globalContrast', true);
end