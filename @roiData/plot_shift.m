function plot_shift(r, roi)
% compare traces of various shift values.

    if nargin < 2
        error('roi id should be specified.');
    end

    figure;
    
    numSnaps = size(r.snaps, 3);
    
    % traces
    
    for i=1:numSnaps
        
        y = r.roi_trace_interpolated_aligned_to_snap(i, roi);
        
        plot(r.f_times, y);
        
        hold on
        
    end

    hold off
    
    
    % roi boundaries
    
    

end