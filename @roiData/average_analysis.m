function average_analysis(r, FIRST_EXCLUDE)
% Relative to avg_trigger_times, it samples and compute various statistics.
% Also, set times for average traces.
    
    if nargin < 2
        FIRST_EXCLUDE = r.AVG_FIRST_EXCLUDE;
    end
    
    if r.avg_FLAG == 0
        disp('roiData average anlysis: avg_FLAG is off.');
        return;
    end
    
    if isempty(r.avg_trigger_times)
        disp('No trigger times for average analysis,');
        return;
    end

    % Align and sample. Output is 3D tensor.
    %[roi_aligned_raw, ~] = r.align_trace_to_avg_triggers('raw');
    [roi_aligned_smoothed,  ~] = r.align_trace_to_avg_triggers('smoothed');
    [roi_aligned_fil,       ~] = r.align_trace_to_avg_triggers('filtered');
    [roi_aligned_smoothed_norm, t_aligned] = r.align_trace_to_avg_triggers('smoothed_norm');
    [roi_aligned_filtered_norm,         ~] = r.align_trace_to_avg_triggers('filtered_norm');
    
    % Number of repeats
    [~,~,n_repeats] = size(roi_aligned_smoothed_norm);
    
    
    % Exclude 1st response? 
    if FIRST_EXCLUDE 
        if n_repeats > 1
        
            roi_aligned_smoothed = roi_aligned_smoothed(:,:,2:end);
            roi_aligned_fil      = roi_aligned_fil(:,:,2:end);
            roi_aligned_smoothed_norm = roi_aligned_smoothed_norm(:,:,2:end);
            roi_aligned_filtered_norm = roi_aligned_filtered_norm(:,:,2:end);
            
        else
            disp('You can''t exclude the 1st response since there is only one repeat.');
        end
    end
    
    % Avg. & Stat. over trials (dim 3)
    [r.avg_trace,             r.stat.smoothed]      = stat_over_repeats(roi_aligned_smoothed);
    [r.avg_trace_fil,         r.stat.filtered]      = stat_over_repeats(roi_aligned_fil);
    [r.avg_trace_smooth_norm, r.stat.smoothed_norm] = stat_over_repeats(roi_aligned_smoothed_norm); 
    [                      ~, r.stat.filtered_norm] = stat_over_repeats(roi_aligned_filtered_norm); 

    % Pearson correlation over repeats
    r.p_corr.smoothed       = corr_avg(roi_aligned_smoothed);
    r.p_corr.smoothed_norm  = corr_avg(roi_aligned_smoothed_norm);
    r.p_corr.filtered       = corr_avg(roi_aligned_fil);
    r.p_corr.filtered_norm  = corr_avg(roi_aligned_filtered_norm);
    
    % Normalized and Centered trace
    r.avg_trace_norm = normc(r.avg_trace) - 0.5; % for raw trace.
    
    % Times for averaged trace
    r.a_times = t_aligned;
    
end