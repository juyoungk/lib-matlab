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
        stim_times
        smoothing_method
        smoothing_size
   
        numFrames
        numRoi
        roi_trace
        roi_smoothed
        avg_trace   % avg over trials: (times x roi#): good for 2-D plot
        f_times     % frame times
        s_times     % single trial times
        stim_duration % one trial
        
        % properties for plot
        n_cycle
        s_phase % shift phase
        p_times % times for plot
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
                r.smoothing_method = 'movmean';
                r.smoothing_size = 3;
            
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
                if ~isempty(stim_times) & numel(stim_times) >1
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
                r.p_times = r.adjustForPlot(s_times);
            end
        end
        
        % Function for phase shift and multiply
        function aa = adjustForPlot(obj, y)
            [row, col] = size(y);
            if row == 1
                aa = circshift(y, round( obj.phase * col ) );
                aa = repmat(aa, [1, obj.n_cycle]);
            elseif col == 1
                aa = circshift(y, round( obj.phase * row ) );
                aa = repmat(aa, [obj.n_cycle, 1]);
            else
                error('Trace should be either row or col vector');
            end
        end
        
    end
    
    methods(Static)

    end
    
end % classdef