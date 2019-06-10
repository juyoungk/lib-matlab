function [aligned, t_aligned] = align_trace_to_avg_triggers(r, Trace, times)
% For given Trace (array or char type) and related times, this function
% will sample a chuck of data at times defined in r.avg_trigger_times with
% duration defined in r.avg_duration.
%
% Input variables:
%               Trace, times
%
% Output variables:
%               aligned   - 
%               t_aligned -
%
% A fraction of repeated trace will be sampled at timed manner according to
% variable 'times'. 
% 'Trace' can be a string. (e.g. 'raw', 'smoothed_norm', ..)
%
% 2019 0312 first wrote.
% 2019 0610 add comments.
% (c) Juyoung Kim

    if nargin < 2 
        Trace = r.roi_smoothed_norm;
        times = r.f_times;
    end
    
    if ischar(Trace)
        switch Trace
            case 'raw'
                Trace = r.roi_trace;
                times = r.f_times;
            case 'smoothed'
                Trace = r.roi_smoothed;
                times = r.f_times;
            case 'smoothed_norm'
                Trace = r.roi_smoothed_norm;
                times = r.f_times;
            case 'smoothed_detrend_norm'
                Trace = r.roi_smoothed_detrend_norm;
                times = r.f_times_norm;
            case 'filtered'
                Trace = r.roi_filtered;
                times = r.f_times_fil;
            case 'filtered_norm'
                Trace = r.roi_filtered_norm;
                times = r.f_times_fil;
            otherwise
                error('Unknown trace type.');
        end
    end

    % check whether 'Trace' has a same length with frames.
    % f_times 
    % f_times_norm
    [num_data, ~] = size(Trace);
    
    if num_data ~= length(times)
        error('Mismatch bwetween trace (%d) and times (%d).', num_data, length(times));
    end
    
    triggers = r.avg_trigger_times + r.s_phase * r.avg_duration;
    duration = r.n_cycle * r.avg_duration;

    [aligned, t_aligned] = align_rows_to_events(Trace, times, triggers, duration);
    
    % Shift t_aligned so that avg_trigger_times may be at zero.
    t_aligned = t_aligned + r.s_phase * r.avg_duration;

end