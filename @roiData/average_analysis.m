function average_analysis(r, times, duration, FIRST_EXCLUDE)
% Relative to avg_trigger_times, it samples snippet of data relative to the trigger times, and compute various statistics.
% Also, set times for average traces.
% inputs: 
%           times - times for average triggers
%           duration - duration for snippet

    if r.avg_FLAG == 0
        disp('roiData average anlysis: avg_FLAG is off.');
        return;
    end
    
    r.avg_FLAG = false; % not to call average_analysis function in a nested way.

    if nargin < 4
        FIRST_EXCLUDE = r.avg_FIRST_EXCLUDE;
    end
    
    if nargin < 3
        if isempty(r.avg_duration)
            % user input for duration
            duration = input('Duration for average analysis in secs?');
            r.avg_duration = duration;
        else
            % preset duration
            fprintf('Current avg duration value was set to %.1f (sec).\n', r.avg_duration);
        end
    else
        r.avg_duration = duration;
    end
    
    if nargin < 2
        % default r.avg_trigger_times.
        if isempty(r.avg_trigger_times)
            disp('error: avg trigger times should be given as an input or set previously.');
            return;
        end
    else
        r.avg_trigger_times = times;
    end
    
    if isempty(r.avg_trigger_times)
        disp('No trigger times for average analysis,');
        return;
    end
    
    % Check whether the last trial was withing the recordign time.
    % Compute stim_end
    id_out_of_range = find(r.avg_trigger_times+r.avg_duration > r.f_times(end), 1);
    if ~isempty(id_out_of_range)        
        r.avg_trigger_times = r.avg_trigger_times(1:id_out_of_range-1);
    end
    r.stim_end = r.avg_trigger_times(end) + r.avg_duration;
    numAvgTrigger = numel(r.avg_trigger_times);
    fprintf('Num of full duration of repeats in the recording: %d\n', numAvgTrigger);
    
    % Compute the baseline level just before the first average tigger time.
    r.baseline; % smoothing > filtering > average_anlaysis if FLAG is on.
    
    %
    r.avg_FLAG = true;
    
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
            disp('The 1st reponse was excluded for average anlysis. Change AVG_FIRST_EXCLUDE to flase to include.'); 
            
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