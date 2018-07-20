function s = rf_stat(r, rf, nearby)

% only 1-D bar rf 
%[n_xbin, n_timebin] = size(rf);

    if nargin <2
        nearby = 1;
    end
    
    if size(rf, 1) == 1
        nearby = 0;
    end
    
    % condition?
    
    % reshape rf

    [n_xbin, n_timebin] = size(rf);
    
    % find max x and max t
    rf_norm = abs(rf - mean(rf, 2));
    
    % exclude the very edges
    rf_norm(1,:) = 0;
    rf_norm(end,:) = 0;
    
    [~, max_ch] = max(max(rf_norm, [], 2)); % ch for the center
    [~, max_time] = max(rf_norm(max_ch,:));

    % 1d (time) slice: integrate neighboring channels.
    i_ch = max(1, max_ch - nearby);
    e_ch = min(n_xbin, max_ch + nearby);

    s.slice_t = mean( rf(i_ch:e_ch,:), 1);

    % space slice (x)
    
    i_t = max(1,         max_time - nearby);
    e_t = min(n_timebin, max_time + nearby);
    
    s.slice_x = mean( rf(:, i_t:e_t), 2);
    
    % min and max
    s.min = min(rf(:));
    s.max = max(rf(:));
    s.max_abs = max( abs(s.min), abs(s.max) ); 
    s.clim = [-s.max_abs s.max_abs];

end