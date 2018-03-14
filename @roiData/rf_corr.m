function [rf, rf_time] = rf_corr(r, id_roi, traceType, maxlag, upsampling)
% traceType = 'normalized', 'raw', 'smoothed'
% upsampling = 1 (default) or 2
    
    if nargin < 5
        upsampling = 2;
    end
    
    if nargin < 4
        maxlag = 1.5; %sec
    end
    
    if nargin < 3
        traceType = 'smoothed';
    end
        
    
    if nargin>1 && numel(id_roi) == 1 && isnumeric(id_roi)

        % trace type & convert f_times to f_times_norm    
        if contains(traceType, 'normalized')
            y = r.roi_normalized(:, id_roi);
            
        elseif contains(traceType, 'raw')
            y = r.roi_trace(:, id_roi);
            y = y(r.f_times>r.ignore_sec) %- r.roi_trend(:, id_roi);
            
        elseif contains(traceType, 'smoothed')
            y = r.roi_smoothed(:, id_roi);
            %y = y(r.f_times>r.ignore_sec);
            y = y(r.f_times>r.ignore_sec) - r.roi_trend(:, id_roi);
            
        else
            disp('trace Type should be one of ''normalized'', ''raw'', ''smoothed''. ''Normalized'' trace was used');
            y = r.roi_normalized(:, id_roi);
        end
                    
        % reverse correlation
        rf = corrRF4(y, r.f_times_norm, r.stim_whitenoise, r.stim_fliptimes + r.stim_trigger_times(1), maxlag, upsampling);
        
        % stat. of rf
        % whitenoise bar stimulus
        [n_ch, ~] = size(rf);
        rf_norm = abs(rf - mean(rf, 2));
        [~, ch] = max(max(rf_norm, [], 2)); % ch for the center
        
        % 1d (time) slice: integrate neighboring channels.
        nearby = 2;
        i_ch = max(1, ch - nearby);
        e_ch = min(n_ch, ch + nearby);
        
        rf_time = mean( rf(i_ch:e_ch,:), 1);
        
    else
        error('roi id should be specified in rf function');
    end

end 

