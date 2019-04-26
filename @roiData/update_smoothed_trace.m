function update_smoothed_trace(r)
    
    if isempty(r.smoothing_size)
        r.smoothing_size = r.smoothing_size_init;
    end
    disp(['Smoothing size = ', num2str(r.smoothing_size)]);

    % initialize array
    r.roi_smoothed = zeros(size(r.roi_trace));
    
    % smooth trace
    for i=1:r.numRoi
        
        y = r.roi_trace(:,i);
        r.roi_smoothed(:,i) = smoothdata(y, r.smoothing_method, r.smoothing_size);
        
        % Normalization by baseline. [%]
        baseline = r.roi_baseline(i);
        r.roi_smoothed_norm(:,i) = (r.roi_smoothed(:,i) - baseline)/baseline * 100;
        
    end
    
    % filtered_trace
    r.update_filtered_trace;
        
end