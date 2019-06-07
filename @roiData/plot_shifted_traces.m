function plot_shifted_traces(r, roi)
% Compare traces of various shift values.

    if nargin < 2
        error('roi id should be specified.');
    end

    figure;
    
    numSnaps = size(r.snaps, 3);
    
    % traces
    for i=1:numSnaps % = num of optimized shifts 
        
        y = r.roi_trace_single_shift_aligned_to_snap(i, roi);
        
        plot(r.f_times, y);
        
        hold on
        
    end

    hold off
    
    
    % roi boundaries
    
   
end