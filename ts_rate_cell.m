function rate = ts_rate_cell(ts, t_window, bintime, smoothing)
% ts should be N X 1 cells
% output:
%       rate - 2D array [n_exp by t_edges-1]
    
    if ~iscell(ts)
        disp('ts is not a cell.');
        rate = ts_rate(ts, t_window, bintime, smoothing);
    end
    
    if nargin < 4
        smoothing = 0;
    end
    if nargin < 3
        bintime = 0.02;
    end
    
    %
    t_edge = t_window(1):bintime:t_window(2);
    n_exp = numel(ts);
    
    %
    rate = zeros(n_exp, length(t_edge)-1); % # of spacing is N-1 of bin #. (histcounts)
    
    for i = 1:n_exp
        r = ts_rate(ts{i}, t_window, bintime, smoothing);
        rate(i, :) = r;
    end

end