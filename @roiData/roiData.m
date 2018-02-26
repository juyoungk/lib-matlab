classdef roiData
% Given cc, extract roi-avg traces from vol data.
% If trigger-times are given, trial-avg will be computed.
%
% Constructor input: 
%        vol - 3-D matrix. Single channel. Each channel might have different ROI.
%    
    properties
        % vol
        ex_name
        roi_cc
        ifi         % inter-frame interval of vol (data)
        stim_times  % stim trigger events
        smoothing_method = 'movmean'
        smoothing_size = 3;
   
        numFrames
        numRoi
        roi_trace
        roi_smoothed
        f_times     % frame times
        
        % avg trace timed at stim_times
        avg_trace       % avg over trials: (times x roi#): good for 2-D plot
        s_times         % single trial times
        stim_duration   % one trial
        
        % rf result
        rf              % cell arrays
        
        %
        roi_selected
        
        % properties for plot
        n_cycle
        s_phase % shift phase
        a_times % times for avg plot
    end
    
    methods
        % constructor
        function r = roiData(vol, cc, ex_str, ifi, stim_times)
            % ifi: inter-frame interval or log-frames-period
            if nargin > 0 % in order to create an array with no input arguments.
                r.roi_cc = cc;
                r.numRoi = cc.NumObjects;
                r.numFrames = size(vol, 3);
                r.roi_trace    = zeros(r.numFrames, r.numRoi);
                r.roi_smoothed = zeros(r.numFrames, r.numRoi);
            
                if nargin > 2
                    r.ex_name = ex_str;
                end
                if nargin > 3
                    r.ifi = ifi;
                    r.stim_times = stim_times;
                    r.f_times = (1:r.numFrames)*ifi; % frame times
                    % Duration for one trial
                    if numel(stim_times)>1
                        r.stim_duration = stim_times(2)  - stim_times(1);
                    else
                        r.stim_duration = r.f_times(end) - stim_times(1);
                    end
                end

                % Extract roi trace from vol.
                vol_reshaped = reshape(vol, [], r.numFrames);
                for i=1:r.numRoi
                    y    = mean(vol_reshaped(cc.PixelIdxList{i},:),1);
                    r.roi_trace(:,i)    = y;
                    r.roi_smoothed(:,i) = smoothdata(y, r.smoothing_method, r.smoothing_size);
                end
                
                % Avg (smoothed) trace over multiple stim repeats
                if ~isempty(stim_times) && numel(stim_times) >4 && ...
                        isempty(strfind(r.ex_name, 'whitenoise')) && isempty(strfind(r.ex_name, 'runjuyoung'))
                    % Align roi traces to stim_times
                    [roi_aligned, s_times] = align_rows_to_events(r.roi_smoothed, r.f_times, stim_times, r.stim_duration);

                    % Avg over trials (dim 3)
                    r.avg_trace = mean(roi_aligned, 3); 
                    r.s_times   = s_times;
                    r.stim_duration = s_times(end);
                end
                
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


