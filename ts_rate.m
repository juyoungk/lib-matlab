function rate = ts_rate(ts, t_window, bintime, smoothing)
% bintime : [secs]
% rate: column vector

    if nargin < 4
        smoothing = false;
    end
    if nargin < 3
        bintime = 0.02;
    end

    t_edge = t_window(1):bintime:t_window(2);
    
    % histc: the last bin wil count only if any values match with EDGE(end)
    rate = histcounts(ts, t_edge)/bintime;
    rate = rate';
        
    % Smoothing of firing rate?
    if smoothing
        rate = double(rate);
        rate = smooth(rate, smoothing, 'moving');
    end

end
