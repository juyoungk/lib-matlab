classdef roiData < handle
% Given cc, extract roi-avg traces from vol data.
% bg remove, bandpass filtering, normalize raw traces.
% If trigger-times are given, trial-avg will be computed.
% If whitenoise stim and fliptimes are given, linear rf will be computed.
%
% Constructor input: 
%        vol - 3-D matrix. Single channel. Each channel might have different ROI.
%    
    properties
        % given input
        ex_name
        roi_cc
        ifi         % inter-frame interval of vol (data)
        stim_trigger_times % absolute times when stims triggered.
        stim_trigger_interval
        %
        stim_whitenoise
        stim_fliptimes     % relative times between whitenoise flip times
        
        % 
        numFrames
        numRoi
        roi_trace       % raw trace (bg substracted. only post-processing)
        roi_smoothed    % smoothed raw trace
        roi_filtered    % lowpass filtered
        roi_trend
        roi_normalized  % dF/F @ dF = filtered - detrended, F = detrended_trace
        f_times         % frame times
        ignore_sec = 10; % ignore first few secs for filtering.
        f_times_fil
        f_times_norm
        
        % smoothing params
        smoothing_method
        smoothing_size
                
        % filter params
        cutoff_period = 10; % secs. for high-pass filtering
        w_filter_low = 0.5 
        w_filter_high = 0.05; % in terms of norm. (or Nyquist) freq. 
        
        % avg trace timed at stim_times
        avg_FLAG
        avg_every
        avg_trigger_times
        avg_trigger_interval
        avg_trace       % avg over (smoothed) trials: (times x roi#): good for 2-D plot
        avg_trace_fil   % avg over (filtered) trials.
        avg_trace_norm  % avg over (normalized) trials.
        avg_times
        a_times     % times for avg plot. Phase shifted.
        
        % whitenoise responses
        rf              % cell arrays
        
        %
        roi_selected
        
        % properties for plot
        n_cycle
        s_phase % shift phase
    end
    %properties (Constant, Access = private)
    
    %end
    properties (Hidden, Access = private)
        % old names
        stim_times      % PD trigger events
        stim_duration   % stim trigger interval
        s_times         % single trial times
    end
    
    methods
        
        function load_h5(r)
        % load stim data from 'stimulus.h5' in current directory    
            %h5info('stimulus.h5')
            %h5disp('stimulus.h5')
            stim = h5read('stimulus.h5', '/expt1/stim');
            times = h5read('stimulus.h5', '/expt1/timestamps');
            r.get_stimulus(stim, times);
        end
        
        function get_stimulus(r, stims_whitenoise, fliptimes)
            % for whithenoise stim
            r.stim_whitenoise = stims_whitenoise;
            r.stim_fliptimes = fliptimes;
        end
        
        function set.smoothing_size(r, t)
            for i=1:r.numRoi
                y = r.roi_trace(:,i);
                r.roi_smoothed(:,i) = smoothdata(y, r.smoothing_method, t);
            end

            if r.avg_FLAG
               % Align roi traces to stim_times
               %[roi_aligned, ~] = align_rows_to_events(r.roi_smoothed, r.f_times, r.stim_trigger_times, r.stim_duration);
               [roi_aligned, ~] = align_rows_to_events(r.roi_smoothed, r.f_times, r.avg_trigger_times, r.avg_trigger_interval);
                % Avg over trials (dim 3)
                r.avg_trace = mean(roi_aligned, 3); 
            end
            r.smoothing_size = t;
        end
        
        function update_filtered_trace(r)
            fil_low   = designfilt('lowpassiir', 'PassbandFrequency',  .3,  'StopbandFrequency', .5, 'PassbandRipple', 1, 'StopbandAttenuation', 60);
            fil_trend = designfilt('lowpassiir', 'PassbandFrequency', .002, 'StopbandFrequency', .008, 'PassbandRipple', 1, 'StopbandAttenuation', 60);
            %fil_high  = designfilt('highpassiir', 'PassbandFrequency', .008, 'StopbandFrequency', .004, 'PassbandRipple', 1, 'StopbandAttenuation', 60);
            
            t = r.ignore_sec; 
            r.f_times_fil = r.f_times(r.f_times > t);
            r.f_times_norm = r.f_times_fil;
            numframes = numel(r.f_times_fil);
            
            r.roi_filtered = zeros(numframes, r.numRoi);
            r.roi_trend = zeros(numframes, r.numRoi);
            r.roi_normalized = zeros(numframes, r.numRoi);

            for i=1:r.numRoi
                    y = r.roi_trace(:,i); % raw data (bg substracted)
                    %
                    y_filtered = filtfilt(fil_low,   y);       % low-pass filtering
                    y_filtered = y_filtered(r.f_times > t);    % ignore the first 5 secs
                       y_trend = filtfilt(fil_trend, y_filtered); 
                    y_fil_normalized = ((y_filtered - y_trend)./y_trend)*100;
                    
                    %
                    r.roi_filtered(:,i) = y_filtered;                                          % set by filter definition?
                    r.roi_normalized(:,i) = y_fil_normalized; %
                    r.roi_trend(:,i) = y_trend;
            end
            
            if r.avg_FLAG
               % Align roi traces to stim_times
               [roi_aligned_fil, ~] = align_rows_to_events(r.roi_filtered, r.f_times_fil, r.avg_trigger_times, r.avg_trigger_interval);
               [roi_aligned_norm, ~] = align_rows_to_events(r.roi_normalized, r.f_times_norm, r.avg_trigger_times, r.avg_trigger_interval);

                % Avg over trials (dim 3)
                r.avg_trace_fil = mean(roi_aligned_fil, 3); 
                r.avg_trace_norm = mean(roi_aligned_norm, 3); 
            end
            
        end
        
        % constructor
        function r = roiData(vol, cc, ex_str, ifi, stim_trigger_times, stim_whitenoise, stim_fliptimes)
            % ifi: inter-frame interval or log-frames-period
            if nargin > 0 % in order to create an array with no input arguments.
                r.roi_cc = cc;
                r.numRoi = cc.NumObjects;
                r.numFrames = size(vol, 3);
                r.roi_trace    = zeros(r.numFrames, r.numRoi);
                r.roi_smoothed = zeros(r.numFrames, r.numRoi);
                r.rf = cell(1, r.numRoi);
                
                if nargin > 2
                    r.ex_name = ex_str;
                end
                
                % Align frames (vol) with stimulus trigger times
                if nargin > 3
                    % inter-frame interval
                    r.ifi = ifi;
                    r.f_times = ((1:r.numFrames)-0.5)*ifi; % frame times. in the middle of the frame
                    
                    % stim trigger times
                    r.stim_trigger_times = stim_trigger_times;
                    
                    % stim trigger interval
                    if numel(stim_trigger_times)>1
                        r.stim_trigger_interval = stim_trigger_times(2)  - stim_trigger_times(1);
                    else
                        % total recording time after the trigger.
                        r.stim_trigger_interval = r.f_times(end) - stim_trigger_times(1);
                    end
                end
                
                % backgound PMT level in images (vol)
                a = sort(vec(vol(:,:,1))); % inferred from 1st frame
                N = ceil(size(vol, 1)/10);
                bg_PMT = mean(a(1:(N*N))) 
                    
                % Extract roi trace from vol.
                vol_reshaped = reshape(vol, [], r.numFrames);
                for i=1:r.numRoi
                    y = mean(vol_reshaped(cc.PixelIdxList{i},:),1);
                    y = y - bg_PMT;                           % bg substraction
                    r.roi_trace(:,i) = y; % raw data (bg substracted)
                end
                    
                % Avg (smoothed) trace over multiple stim repeats
                if ~isempty(stim_trigger_times) && numel(stim_trigger_times) >=3 && ...
                        isempty(strfind(r.ex_name, 'whitenoise')) && isempty(strfind(r.ex_name, 'runjuyoung')) && isempty(strfind(r.ex_name, 'runme'))
                    
                    r.avg_FLAG = true;
                    
                        % params for avg & avg plot
                        r.avg_every = 1;
                        r.n_cycle = 1;
                        r.s_phase = 0;
                        
                        if strfind(r.ex_name, 'flash')
                            r.n_cycle = 2;
                            r.s_phase = 0.25;
                        elseif strfind(r.ex_name, 'movingbar')
                            r.avg_every = 4;
                        elseif strfind(r.ex_name, 'jitter')
                            
                        end
                        
                        % avg trigger times
                        if r.avg_every > 1 
                            id_trigger = mod(1:numel(stim_trigger_times), r.avg_every) == 1; % logical array
                            r.avg_trigger_times = r.stim_trigger_times(id_trigger);
                        else
                            r.avg_trigger_times = r.stim_trigger_times;
                        end
                        
                        % avg trigger interval
                        if numel(r.avg_trigger_times) > 1
                            r.avg_trigger_interval = r.avg_trigger_times(2) - r.avg_trigger_times(1);
                        else
                            disp('Only one trigger event for averaging over responses to (repeated) stims');
                            r.avg_trigger_interval = 10
                        end
                        
                        % times for avg traces
                        n = floor(r.avg_trigger_interval*(1./ifi)); % same as qx in align_rows_to_events function
                        r.avg_times = ((1:n)-0.5)*ifi; 
                        % times for avg trace plot
                        r.a_times = r.timesForAvgPlot;
                else
                    r.avg_FLAG = false;
                end
                
                % default smoothing or smoothed traces
                r.smoothing_method = 'movmean';
                r.smoothing_size = 5;
                
                % filtered trace
                r.update_filtered_trace;
                
                % whitenoise stim
                if nargin > 5
                    r.stim_whitenoise = stim_whitenoise;
                    r.stim_fliptimes = stim_fliptimes;
                end
                
            end
        end
        
        % Function for phase shift and multiply
        function yy = traceForAvgPlot(obj, y)
            [row, col] = size(y);
            if row == 1
                yy = circshift(y, round( obj.s_phase * col ) );
                yy = repmat(yy, [1, obj.n_cycle]);
            elseif col == 1
                yy = circshift(y, round( obj.s_phase * row ) );
                yy = repmat(yy, [obj.n_cycle, 1]);
            else
                error('Trace should be either row or col vector');
            end
        end
 
        function tt = timesForAvgPlot(obj)
            N = length(obj.avg_times);
            % extend times
            tt = repmat(obj.avg_times, [1, obj.n_cycle]);
            c = meshgrid(0:(obj.n_cycle-1), 1:N);
            tt = tt + (vec(c).')*obj.avg_times(end);
            % phase shift
            tt = tt - obj.s_phase * obj.avg_times(end);
        end
        
        function set.stim_trigger_times(obj, value)
            obj.stim_trigger_times = value;
            obj.stim_times = value; % old name
        end
        
        function set.avg_times(obj, value)
            obj.avg_times = value;
            obj.s_times = value; % old name
        end
        
        function set.stim_trigger_interval(obj, value)
            obj.stim_trigger_interval = value;
            obj.stim_duration = value; % old name
        end 
    end
    
end % classdef

function aa = vec(a)
    aa = a(:);
end

