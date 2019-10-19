function update_filtered_trace(r)
% update_smoothed_trace should be called in advance. 

    % calculating filters
    %fil_low   = designfilt('lowpassiir', 'PassbandFrequency',  .3,  'StopbandFrequency', .5, 'PassbandRipple', 1, 'StopbandAttenuation', 60); % default
    fil_low   = designfilt('lowpassiir', 'PassbandFrequency',  r.w_filter_low_pass,  'StopbandFrequency', r.w_filter_low_stop, 'PassbandRipple', 1, 'StopbandAttenuation', 60);
    %fil_trend = designfilt('lowpassiir', 'PassbandFrequency', .0002, 'StopbandFrequency', .004, 'PassbandRipple', 1, 'StopbandAttenuation', 60); % 2018 1022. Narutal movies are more dynamic
    fil_trend = designfilt('lowpassiir', 'PassbandFrequency', .002, 'StopbandFrequency', .008, 'PassbandRipple', 1, 'StopbandAttenuation', 60);  % Short repeat(e.g. flash 0223 data) 2018 1023
    fil_trend = designfilt('lowpassiir', 'PassbandFrequency', .03, 'StopbandFrequency', .06, 'PassbandRipple', 1, 'StopbandAttenuation', 60);  % 1016 data 23s repeat
    %fil_high  = designfilt('highpassiir', 'PassbandFrequency', .008, 'StopbandFrequency', .004, 'PassbandRipple', 1, 'StopbandAttenuation', 60);
    
    % update ignore_sec
    r.ignore_sec = r.stim_trigger_times(1);
    r.ignore_sec = 5; % cut off first 5 sec
    t = r.ignore_sec; 
    
    % time
    r.f_times_fil = r.f_times(r.f_times > t);
    r.f_times_norm = r.f_times_fil;
    numframes = numel(r.f_times_fil);
    
    
    %
    r.roi_filtered = zeros(numframes, r.numRoi);
    r.roi_normalized = zeros(numframes, r.numRoi);
    r.roi_trend = zeros(numframes, r.numRoi);
    r.roi_smoothed_detrend = zeros(numframes, r.numRoi);
    r.roi_smoothed_detrend_norm = zeros(numframes, r.numRoi);
    r.roi_filtered_norm = zeros(numframes, r.numRoi);

    for i=1:r.numRoi
            y = r.roi_trace(:,i); % raw data (bg substracted)
            
            %
            y_smoothed = r.roi_smoothed(:,i);       % raw data (bg substracted)
            
            % Low-pass filtering: all data
            y_filtered = filtfilt(fil_low, y);
            
            % Select data after stimulus onset: For de-trending
            y_smoothed = y_smoothed(r.f_times > t); 
            y_filtered = y_filtered(r.f_times > t); 
            
            % High-pass filter
            y_trend = filtfilt(fil_trend, y_filtered);

            % detrend & normalization
            y_smoothed_detrend = y_smoothed - y_trend; 
            y_smoothed_detrend_norm = ((y_smoothed - y_trend)./y_trend)*100;
            y_filtered_norm = ((y_filtered - y_trend)./y_trend)*100;

            %
            r.roi_filtered(:,i) = y_filtered;          % set by filter definition?
            r.roi_trend(:,i) = y_trend;
            %
            r.roi_smoothed_detrend(:,i) = y_smoothed_detrend;
            r.roi_smoothed_detrend_norm(:,i) = y_smoothed_detrend_norm;
            r.roi_filtered_norm(:,i) = y_filtered_norm;
    end

    %disp('Currently, filtering was turned off. (you can activate it in roiData/update_filtered_trace.m');
    
    % Perform average analysis if avg analysis was done before. 
    if r.avg_FLAG
        r.average_analysis;
    end
   
end