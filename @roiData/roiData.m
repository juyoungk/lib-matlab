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
        
        % smoothing params
        smoothing_method
        smoothing_size
                
        % filter params
        cutoff_period = 10; % secs. for high-pass filtering
        w_filter_low = 0.5 
        w_filter_high = 0.05; % in terms of norm. (or Nyquist) freq. 
        
        % avg trace timed at stim_times
        avg_FLAG
        avg_trace       % avg over (smoothed) trials: (times x roi#): good for 2-D plot
        avg_trace_fil   % avg over (filtered) trials.
        avg_times
        
        stim_duration   % one trial. confusing word 
        
        % whitenoise responses
        rf              % cell arrays
        
        %
        roi_selected
        
        % properties for plot
        n_cycle
        s_phase % shift phase
        a_times % times for avg plot 
    end
    properties (Hidden, Access = private)
        % old names
        stim_times  % PD trigger events
        s_times     % single trial times
    end
    
    methods
        
        function set.stim_trigger_times(obj, value)
            obj.stim_trigger_times = value;
            obj.stim_times = value; % old name
        end
        
        function set.avg_times(obj, value)
            obj.avg_times = value;
            obj.s_times = value; % old name
        end
        
        function set.smoothing_size(r, t)
            
            for i=1:r.numRoi
                y = r.roi_trace(:,i);
                r.roi_smoothed(:,i) = smoothdata(y, r.smoothing_method, t);
            end

            if r.avg_FLAG
               % Align roi traces to stim_times
               [roi_aligned, ~] = align_rows_to_events(r.roi_smoothed, r.f_times, r.stim_trigger_times, r.stim_duration);
               %[roi_aligned_fil, ~] = align_rows_to_events(r.roi_normalized, r.f_times, r.stim_trigger_times, r.stim_duration);

                % Avg over trials (dim 3)
                r.avg_trace = mean(roi_aligned, 3); 
                %r.avg_trace_fil = mean(roi_aligned_fil, 3); 
            end
            r.smoothing_size = t;
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
                r.roi_filtered = zeros(r.numFrames, r.numRoi);
                r.roi_normalized = zeros(r.numFrames, r.numRoi);
                r.roi_trend = zeros(r.numFrames, r.numRoi);
                r.rf = cell(1, r.numRoi);
                
                if nargin > 2
                    r.ex_name = ex_str;
                end
                
                % stimulus trigger times
                if nargin > 3
                    r.ifi = ifi;
                    %r.stim_times = stim_trigger_times;
                    r.stim_trigger_times = stim_trigger_times;
                    r.f_times = ((1:r.numFrames)-0.5)*ifi; % frame times. in the middle of the frame
                    
                    % Duration for single trial (stim duration. somewhat confusing)
                    if numel(stim_trigger_times)>1
                        r.stim_duration = stim_trigger_times(2)  - stim_trigger_times(1);
                    else
                        % total recording time after the trigger.
                        r.stim_duration = r.f_times(end) - stim_trigger_times(1);
                    end
                    n = floor(r.stim_duration*(1./ifi)); % same as qx in align_rows_to_events function
                    r.avg_times = ((1:n)-0.5)*ifi; 
                end
                
                % backgound PMT level
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
                    
                        % params for plot
                        if strfind(r.ex_name, 'flash')
                            r.n_cycle = 2;
                            r.s_phase = 0.25;
                        else
                            r.n_cycle = 1;
                            r.s_phase = 0;
                        end
                        r.a_times = r.timesForAvgPlot;
                        
                else
                    r.avg_FLAG = false;
                end
                
                % default smoothing or filtering:
                r.smoothing_method = 'movmean';
                r.smoothing_size = 5;
                fil_low   = designfilt('lowpassiir', 'PassbandFrequency',  .3,  'StopbandFrequency', .5, 'PassbandRipple', 1, 'StopbandAttenuation', 60);
                fil_trend = designfilt('lowpassiir', 'PassbandFrequency', .005, 'StopbandFrequency', .01, 'PassbandRipple', 1, 'StopbandAttenuation', 60);
                fil_high  = designfilt('highpassiir', 'PassbandFrequency', .008, 'StopbandFrequency', .004, 'PassbandRipple', 1, 'StopbandAttenuation', 60);
                    % trend - lowpassfilter is better than smoothdata('movmean').
                for i=1:r.numRoi
                    y = r.roi_trace(:,i); % raw data (bg substracted)
                    %
                    y_filtered = filtfilt(fil_low,   y);      % low-pass filtering
                       y_trend = filtfilt(fil_trend, y_filtered);
                    y_fil_normalized = ((y_filtered - y_trend)./y_trend)*100;
                    
                    %r.roi_smoothed(:,i) = smoothdata(y, r.smoothing_method, r.smoothing_size); % set by smoothing_size?
                    r.roi_filtered(:,i) = y_filtered;                                          % set by filter definition?
                    r.roi_normalized(:,i) = y_fil_normalized; %
                    r.roi_trend(:,i) = y_trend;
                end
                
                % whitenoise stim
                if nargin > 5
                    r.stim_whitenoise = stim_whitenoise;
                    r.stim_fliptimes = stim_fliptimes;
                end
                
            end
        end
        
        function y_filtered = h_passfilter(obj, y)
            %cutoff_period = 10; % secs
                cutoff_freq_h = 1/obj.cutoff_period;
                w_cutoff_h = cutoff_freq_h / (0.5*(1/obj.ifi));
                [b a] = butter(4, w_cutoff_h, 'high');
                y_filtered = filter(b, a, y);
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
        
    end
    
end % classdef

function aa = vec(a)
    aa = a(:);
end

