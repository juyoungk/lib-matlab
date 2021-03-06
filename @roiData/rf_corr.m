function [rf, s] = rf_corr(r, id_roi, traceType, maxlag, upsampling)
%RF_CORR Reverse correlation with single ROI trace with stimulus (e.g. whitenoise) 
% traceType = 'normalized', 'raw', 'smoothed'
% upsampling = 1 or 2 or 5 (default)
% s: stat of rf.
%   .t_slice
%   .s_slice
    
    if nargin < 5
        upsampling = 5;
    end
    
    if nargin < 4
        maxlag = 1.5; %sec
    end
    
    if nargin < 3
        traceType = 'smoothed_detrend_norm';
    end
   
    % session trigger..?
    % stimulus id? 
    i = 8;
    disp('!!! stim group was set to 8. need to be updated..');
    
    if ~isfield(r.stim(i), 'starttime') || isempty(r.stim(i).starttime)
    end
    
    t_stimflip_start = r.stim(i).starttime;
    stim_movie = r.stim(i).stim;
    fliptimes = r.stim(i).timestamps;

    if nargin>1 && numel(id_roi) == 1 && isnumeric(id_roi)

        % trace type & convert f_times to f_times_norm    
        if contains(traceType, 'normalized')
            error('No more use for the tracetype ''roi_normalized''');
            %y = r.roi_normalized(:, id_roi);
        
        % for 'raw', 'smoothed', 'smoothed_norm' traces, the frst part of
        % the data should be ignored to work with r.f_times_norm.
        elseif contains(traceType, 'raw')
            y = r.roi_trace(:, id_roi);
            y = y(r.f_times>r.ignore_sec); %- r.roi_trend(:, id_roi);
            
        elseif contains(traceType, 'smoothed')
            y = r.roi_smoothed(:, id_roi);
            %y = y(r.f_times>r.ignore_sec);
            y = y(r.f_times>r.ignore_sec) - r.roi_trend(:, id_roi);
            
        elseif contains(traceType, 'smoothed_norm')
            y = r.roi_smoothed_norm(:, id_roi);
            y = y(r.f_times>r.ignore_sec);
        
        elseif contains(traceType, 'smoothed_detrend_norm')
            y = r.roi_smoothed_detrend_norm(:, id_roi);
        
        elseif contains(traceType, 'filtered')    
            y = r.roi_filtered(:, id_roi);
            
        elseif contains(traceType, 'filtered_norm')    
            y = r.roi_filtered_norm(:, id_roi);
            
        else
            disp('trace Type should be one of ''normalized'', ''raw'', ''smoothed''. ''Normalized'' trace was used');
            y = r.roi_normalized(:, id_roi);
        end
                    
        % reverse correlation
        % Adding the trigger time is better because resample of stim movie
        % before the first time of the recording would generate errors. 
        rf = corrRF4(y, r.f_times_norm, stim_movie, fliptimes + t_stimflip_start, maxlag, upsampling);
        
        % dim of rf: time = sampling rate of imaging. space = visual stim space. 
        
        % stat. of rf
            nearby = 0;
            % whitenoise bar stimulus
            %s = rf_stat(r, rf, nearby);
            
    else
        error('roi id should be specified in rf function');
    end

end 

% function s = rf_stat(r, rf, nearby)
% 
% % only 1-D bar rf 
% %[n_xbin, n_timebin] = size(rf);
% 
%     if nargin <2
%         nearby = 1;
%     end
%     
%     % condition?
%     
%     % reshape rf
% 
%     [n_xbin, n_timebin] = size(rf);
%     
%     % find max x and max t
%     rf_norm = abs(rf - mean(rf, 2));
%     
%     % exclude the very edges
%     rf_norm(1,:) = 0;
%     rf_norm(end,:) = 0;
%     
%     [~, max_ch] = max(max(rf_norm, [], 2)); % ch for the center
%     [~, max_time] = max(rf_norm(max_ch,:));
% 
%     % 1d (time) slice: integrate neighboring channels.
%     i_ch = max(1, max_ch - nearby);
%     e_ch = min(n_xbin, max_ch + nearby);
% 
%     s.slice_t = mean( rf(i_ch:e_ch,:), 1);
% 
%     % space slice (x)
%     
%     i_t = max(1,         max_time - nearby);
%     e_t = min(n_timebin, max_time + nearby);
%     
%     s.slice_x = mean( rf(:, i_t:e_t), 2);
%     
%     % min and max
%     s.min = min(rf(:));
%     s.max = max(rf(:));
%     s.max_abs = max( abs(s.min), abs(s.max) ); 
%     s.clim = [-s.max_abs s.max_abs];
% 
% end