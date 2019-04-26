function vol = snaps_after_avg(g, times)
% Average snaps during the first half and the last half of the interval.
% e.g. ON vs OFF duration snap images.
    
    if nargin < 2
        id = input('PD events1 (major) session id?');
        % select times by session (major trigger) id.
        times = g.pd_events_within(id);
    end

    interval = times(2:end) - times(1:end-1);
    interval = min(interval);
    
    % snaps
	snaps1 = g.snaps_after(times, interval/2.);
    snaps2 = g.snaps_after(times+interval/2., interval/2.);
    snap1 = mean(snaps1, 3);
    snap2 = mean(snaps2, 3);
    
    % baseline snap
    before = 5;  % secs
    duration = 5; % secs
    base = g.snaps_before(times(1) - before, duration);
    
    % mapped on [0, 1]
    vv = cat(3, base, snap1, snap2);
    minI = min(vv(:));
    maxI = max(vv(:));
    
    base = (base - minI)/(maxI - minI);
    snap1 = (snap1 - minI)/(maxI - minI);
    snap2 = (snap2 - minI)/(maxI - minI);
    
    % norm by base.
    %snap1 = norm(snap1, base);
    %snap2 = norm(snap2, base);
    
    % output vol
    vol = cat(3, base, snap1, base, snap2);
    
    %
    hf = g.figure;
    imvol(vol, 'globalContrast', true, 'hfig', hf, 'title', 'baseline, snap1, baseline, snap2');
    
    % contrast adjusted snaps?
%     snap1 = myshow(snap1, 0.1);
%     snap2 = myshow(snap2, 0.1);
%     base = myshow(base, 0.1);
%     
    % snap1-2
    g.figure;
    imshowpair(snap1, snap2); % contrast adjust by myshow()
    title('snap1-snap2', 'FontSize', 15, 'Color', 'w');
    
    % base-ON
    g.figure;
    imshowpair(base, snap1); % contrast adjust by myshow()
    title('base-snap1', 'FontSize', 15, 'Color', 'w');
    
    % base-OFF
    g.figure;
    imshowpair(base, snap2); % contrast adjust by myshow()
    title('base-snap2', 'FontSize', 15, 'Color', 'w');
    
end

function normed_snap = norm(snap, base)

normed_snap = (snap - base) ./ base;
normed_snap = (snap - base);



end