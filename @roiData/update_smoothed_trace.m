function update_smoothed_trace(r)
% don't call this function? instead r.smoothing_size = size

    disp(['Smoothing size = ', num2str(r.smoothing_size),'. Now update...']);

    % initialize array
    r.roi_smoothed = zeros(size(r.roi_trace));
    r.roi_smoothed_norm = zeros(size(r.roi_trace));
    
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