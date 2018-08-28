function update_smoothed_trace(r)
    % initialize array
    r.roi_smoothed = zeros(size(r.roi_trace));

    % smooth trace
    for i=1:r.numRoi
        y = r.roi_trace(:,i);
        r.roi_smoothed(:,i) = smoothdata(y, r.smoothing_method, r.smoothing_size);
    end

    % avg trace and variance
    if r.avg_FLAG
       % Align roi traces to stim_times
       [roi_aligned, ~] = align_rows_to_events(r.roi_smoothed, r.f_times, r.avg_trigger_times, r.avg_trigger_interval);

       % Avg & Std over trials (dim 3)
       r.avg_trace      = mean(roi_aligned, 3);
       % Normalized and Centered trace
       r.avg_trace_norm = normc(r.avg_trace) -0.5;
       % Pearson correlation over repeats
       r.p_corr.smoothed = corr_avg(roi_aligned);
    end
    
    % filtered_trace
    r.update_filtered_trace;
end