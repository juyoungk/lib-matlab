classdef roiData
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
        roi_trace       % raw trace
        roi_smoothed    % smoothed trace
        roi_filtered    % lowpass filtered
        roi_trend
        roi_normalized  % dF/F and (detrended)
        f_times         % frame times
        
        %
        cutoff_period = 10; % secs. for high-pass filtering
        w_filter_low = 0.5 
        w_filter_high = 0.; % in terms of norm. (or Nyquist) freq. 
        smoothing_method = 'movmean'
        smoothing_size = 3;
        
        % avg trace timed at stim_times
        avg_trace       % avg over (smoothed) trials: (times x roi#): good for 2-D plot
        avg_trace_fil   % avg over filtered trials.
        s_times         % single trial times
        stim_duration   % one trial
        
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
    end
    
    methods
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
                fil_low  =  designfilt('lowpassiir', 'PassbandFrequency', .3, 'StopbandFrequency', .5, 'PassbandRipple', 1, 'StopbandAttenuation', 60);
                fil_trend = designfilt('lowpassiir', 'PassbandFrequency', .005, 'StopbandFrequency', .01, 'PassbandRipple', 1, 'StopbandAttenuation', 60);
                fil_high = designfilt('highpassiir', 'PassbandFrequency', .008, 'StopbandFrequency', .004, 'PassbandRipple', 1, 'StopbandAttenuation', 60);
                % trend - lowpassfilter is better than
                % smoothdata('movmean').
                
                if nargin > 2
                    r.ex_name = ex_str;
                end
                if nargin > 3
                    r.ifi = ifi;
                    r.stim_times = stim_trigger_times;
                    r.stim_trigger_times = stim_trigger_times;
                    r.f_times = (1:r.numFrames)*ifi; % frame times
                    % Duration for one trial
                    if numel(stim_trigger_times)>1
                        r.stim_duration = stim_trigger_times(2)  - stim_trigger_times(1);
                    else
                        r.stim_duration = r.f_times(end) - stim_trigger_times(1);
                    end
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
                    y_filtered = filtfilt(fil_low,   y);  % low-pass filtering
                       y_trend = filtfilt(fil_trend, y_filtered);
                    y_normalized = ((y_filtered - y_trend)./y_trend)*100;
                    
                    r.roi_trace(:,i) = y;
                    r.roi_smoothed(:,i) = smoothdata(y, r.smoothing_method, r.smoothing_size);
                    r.roi_filtered(:,i) = y_filtered;
                    r.roi_normalized(:,i) = y_normalized;
                    r.roi_trend(:,i) = y_trend;
                end
                    
                % Avg (smoothed) trace over multiple stim repeats
                if ~isempty(stim_trigger_times) && numel(stim_trigger_times) >=3 && ...
                        isempty(strfind(r.ex_name, 'whitenoise')) && isempty(strfind(r.ex_name, 'runjuyoung')) && isempty(strfind(r.ex_name, 'runme'))
                    % Align roi traces to stim_times
                    [roi_aligned, s_times] = align_rows_to_events(r.roi_smoothed, r.f_times, stim_trigger_times, r.stim_duration);
                    [roi_aligned_fil, ~] = align_rows_to_events(r.roi_normalized, r.f_times, stim_trigger_times, r.stim_duration);

                    % Avg over trials (dim 3)
                    r.avg_trace = mean(roi_aligned, 3); 
                    r.avg_trace_fil = mean(roi_aligned_fil, 3); 
                    r.s_times   = s_times;
                    r.stim_duration = s_times(end);
                    
                    % params for plot
                    if strfind(r.ex_name, 'flash')
                        r.n_cycle = 2;
                        r.s_phase = 0.25;
                    else
                        r.n_cycle = 1;
                        r.s_phase = 0;
                    end
                    r.a_times = r.timesForAvgPlot;
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
            N = length(obj.s_times);
            % extend times
            tt = repmat(obj.s_times, [1, obj.n_cycle]);
            c = meshgrid(0:(obj.n_cycle-1), 1:N);
            tt = tt + (vec(c).')*obj.s_times(end);
            % phase shift
            tt = tt - obj.s_phase * obj.s_times(end);
        end
        
    end
    
end % classdef

function aa = vec(a)
    aa = a(:);
end

