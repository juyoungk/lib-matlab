function yy = traceAvgPlot(r, y)
% Given arbitrary siganl y (1-D or 2-D), translate and multiply traces
% according to n_cycle and s_phase defined in roiData along DIM 1.
%
% 1. make it col vector for 1-D array.
% 2. multiply & phase shift
%
% 
%
% 2018 0705 Juyoung Kim
        
        if isrow(y)
            y = y';
        end

        [N_data, ~] = size(y);
        
        
         yy = circshift(y, round( r.s_phase * N_data ) );
         yy = repmat(yy, [r.n_cycle, 1]);
        
end