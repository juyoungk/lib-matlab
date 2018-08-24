function [yy, tt] = traceAvgPlot(r, y)
% Given one repeat siganl y (1-D or 2-D, averaged or not), shift (by s_phase) and
% multiply (by n_cycle) traces along DIM 1 (or row) for good-looking plot. 
%
% 1. make it col vector for 1-D array.
% 2. multiply & phase shift
% 3. Select times by t_range
%
% 2018 0705 wrote. 
% 2018 0821 add time range filter
%
% (c) Juyoung Kim
        
        if isrow(y)
            y = y';
        end

        [N_data, ~] = size(y);
        
        yy = circshift(y, round( r.s_phase * N_data ) );
        yy = repmat(yy, [r.n_cycle, 1]);
        
        tt = r.a_times;
        %tt = timesAvgPlot(r);
        
        % Final time range filter
        ids = (tt > r.t_range(1)) & (tt < r.t_range(2));
        
        % outputs
        yy = yy(ids, :);
        tt = tt(ids);
        
end