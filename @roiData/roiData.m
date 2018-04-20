classdef roiData < handle
% Given cc, extract roi-avg traces from vol data.
% bg remove, bandpass filtering, normalize raw traces.
% If trigger-times are given, trial-avg will be computed.
% If whitenoise stim and fliptimes are given, linear RF will be computed.
%
% Constructor input: 
%        vol - 3-D matrix. Single channel. (Each channel might have
%        different ROI.)
%    
    properties
        % given input
        ex_name
        image       % mean image (snapshot) of the vol
        header      % imaging condition
        disp        % stimulus disp params
        %
        roi_cc      % roi information (struct 'cc')
        ifi         % inter-frame interval of vol (data)
        stim_trigger_times    % absolute times when stims triggered.
        stim_trigger_interval % if triggers are non-uniform, do not use it.
        stim_end
        %
        stim_whitenoise
        stim_fliptimes     % relative times between whitenoise flip times
        stim_size          % spatial size [mm]
        
        % 
        numFrames
        numRoi
        roi_trace       % raw trace (bg substracted. only post-processing)
        roi_smoothed    % smoothed raw trace + normalization?
        roi_filtered    % lowpass filtered
        roi_trend       % trend for normalization
        roi_smoothed_norm
        roi_filtered_norm % dF/F @ dF = filtered - detrended, F = detrended_trace
        
        roi_mean_f      % mean fluorescnece level during the stimulus
        f_times         % frame times
        ignore_sec      % ignore first few secs for filtering.
        f_times_fil
        f_times_norm
        
        % statistics
        stat
        
        % smoothing params
        smoothing_method = 'movmean';
        smoothing_size  
        smoothing_size_init = 5;
                
        % filter params
        cutoff_period = 10; % secs. for high-pass filtering
        w_filter_low  = 0.5 
        w_filter_high = 0.05; % in terms of norm. (or Nyquist) freq. 
        
        % avg trace timed at stim_times
        avg_FLAG
        avg_every
        avg_trigger_times   % times for aligning between trials
        avg_stim_times  % stim times within one avg trace
        avg_trigger_interval
        avg_trace       % avg over (smoothed) trials: (times x roi#): good for 2-D plot
        avg_trace_std   % std over trials
        avg_trace_fil   % avg over (filtered) trials.
        avg_trace_smooth_norm
        %avg_trace_filter_norm
        avg_trace_norm  % avg over (normalized) trials.
        avg_projected   % projected trace onto (PCA) space.
        avg_pca_score   % roi# x dim
        avg_times   % times for one stim cycle
        a_times     % times for avg plot. Phase shifted.
        
        % whitenoise responses
        rf              % cell arrays
        
        % clusters for ROIs
        dispClusterNum = 10;
        c             % cluster id array. 0 is unallowcated or noisy group
        c_mean        % cluster mean for average trace (trace X #clusters ~100). update through plot_cluster
        c_hfig
        c_note
        roi_review
        roi_selected
        
        % properties for plot
        n_cycle = 1
        s_phase = 0 % shift phase
        t_range = [-100, 100] % avg plot range bound. secs.
        coeff   % (PCA) basis
    end
 
    properties (Hidden, Access = private)
        % old names
        stim_times      % PD trigger events
        stim_duration   % stim trigger interval
        s_times         % single trial times
        roi_normalized  % dF/F @ dF = filtered - detrended, F = detrended_trace
    end
    
    methods
        
        function load_h5(r, dirpath)
        % load stim data from 'stimulus.h5' in current directory    
            %h5info('stimulus.h5')
            %h5disp('stimulus.h5')
            if nargin < 2
                dirpath = '/Users/peterfish/Documents/1__Retina_Study/Docs_Code_Stim/Mystim';
            end
            
            % stim id for whitenoise? 
            stim = h5read([dirpath, '/stimulus.h5'], '/expt1/stim');
            times = h5read([dirpath, '/stimulus.h5'], '/expt1/timestamps');
            r.get_stimulus(stim, times);
        end
        
        function save(r)
            % struct for save
            s.cc = r.roi_cc;
            s.c = r.c;
            s.c_note = r.c_note;
            s.roi_review = r.roi_review;
            save([r.ex_name,'_roi_save'], '-struct', 's');
        end
        
        function load_c(r, c, c_note, roi_review)
            % load cluster info
            r.c = c;
            r.c_note = c_note;
            r.roi_review = roi_review;
        end
        
        function reset_cluster(r)
            %[row, col] = size(r.c);
            r.c = zeros(size(r.c));
            r.c_mean = zeros(size(r.c_mean));
            r.c_note = cell(size(r.c_note));
            r.roi_review = [];
        end
        
        function set.c(r, value)
            n_prev = numel(find(r.c~=0));
            r.c = value;
            n_new = numel(find(r.c~=0));
            if n_new ~= n_prev
                r.pca;
                disp('PCA score has been computed.');
            end
        end
        
        function swapcluster(r, i, j)
            note_temp = r.c_note{i};
            i_idx = (r.c == i);
            j_idx = (r.c == j);
            % switch note
            r.c_note{i} = r.c_note{j};
            r.c_note{j} = note_temp;
            % switch index
            r.c(i_idx) = j;
            r.c(j_idx) = i;
        end
            
        function myshow(r)
            myshow(r.image);
        end
        
        function imvol(r)
            imvol(r.image, 'roi', r.roi_cc, 'edit', false); % can be different depending on threhsold 
        end
        
        function get_stimulus(r, stims_whitenoise, fliptimes)
            % for whithenoise stim
            r.stim_whitenoise = stims_whitenoise;
            r.stim_fliptimes = fliptimes;
        end
        
        function set.smoothing_size(r, t)
            r.smoothing_size = t;
            r.update_smoothed_trace;
        end
        
        function update_smoothed_trace(r)
            % smooth trace
            for i=1:r.numRoi
                y = r.roi_trace(:,i);
                r.roi_smoothed(:,i) = smoothdata(y, r.smoothing_method, r.smoothing_size);
            end
            
            % avg trace and variance
            if r.avg_FLAG
               % Align roi traces to stim_times
               [roi_aligned, ~] = align_rows_to_events(r.roi_smoothed, r.f_times, r.avg_trigger_times, r.avg_trigger_interval);
                
               % Avg & Std over trials (dim 3)
               r.avg_trace    = mean(roi_aligned, 3);
               
               % normalization by its min?
               
               
               %r.avg_trace_std = std(roi_aligned, 1, 3);       % normalization weight = 1
               %r.avg_trace_std = r.avg_trace_std./r.avg_trace; % norm by mean. Std as fraction to mean.
               
               % stat over one trial duration
               %r.stat.mean_std_over_repeats = mean(r.avg_trace_std, 1);
            end
            % filtered_trace
            r.update_filtered_trace;
        end
        
        function update_filtered_trace(r)
        % update_smoothed_trace should be performed in advance. 
            % calculating filters
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
                    y_smoothed = r.roi_smoothed(:,i); % raw data (bg substracted)
                    y_smoothed = y_smoothed(r.f_times > t);
                    %
                    y_filtered = filtfilt(fil_low,   y);       % low-pass filtering
                    y_filtered = y_filtered(r.f_times > t);    % ignore the first secs
                    %
                    y_trend = filtfilt(fil_trend, y_filtered); 
                    
                    % normalization
                    y_smoothed_norm = ((y_smoothed - y_trend)./y_trend)*100;
                    y_filtered_norm = ((y_filtered - y_trend)./y_trend)*100;
                    
                    %
                    r.roi_filtered(:,i) = y_filtered;                                          % set by filter definition?
                    r.roi_trend(:,i) = y_trend;
                    %
                    r.roi_smoothed_norm(:,i) = y_smoothed_norm;
                    r.roi_filtered_norm(:,i) = y_filtered_norm;
            end
            
            if r.avg_FLAG
               % Align roi traces to stim_times
               [roi_aligned_fil, ~]           = align_rows_to_events(r.roi_filtered, r.f_times_fil, r.avg_trigger_times, r.avg_trigger_interval);
               [roi_aligned_smoothed_norm, ~] = align_rows_to_events(r.roi_smoothed_norm, r.f_times_norm, r.avg_trigger_times, r.avg_trigger_interval);
               [roi_aligned_filtered_norm, ~] = align_rows_to_events(r.roi_filtered_norm, r.f_times_norm, r.avg_trigger_times, r.avg_trigger_interval);

                % Avg. & Stat. over trials (dim 3)
                [r.avg_trace_fil,  ~]      = stat_over_repeats(roi_aligned_fil); 
                [r.avg_trace_smooth_norm, stat_smoothed_norm] = stat_over_repeats(roi_aligned_smoothed_norm); 
                [       r.avg_trace_norm, stat_filtered_norm] = stat_over_repeats(roi_aligned_filtered_norm); 
                
                r.stat.smoothed_norm = stat_smoothed_norm;
                r.stat.filtered_norm = stat_filtered_norm;
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
                
                % mean image
                [row, col, n_frames] = size(vol);
                n_frames_snap = min(n_frames, round(512*512*1000/row/col));
                r.image = mean(vol(:,:,1:n_frames_snap), 3);
                
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
                    
                    % stim trigger interval & end time
                    if numel(stim_trigger_times)>1
                        r.stim_trigger_interval = stim_trigger_times(end)  - stim_trigger_times(end-1); % for uniform stim triggers
                        r.stim_end = stim_trigger_times(end) + r.stim_trigger_interval;
                    else
                        % total recording time after the trigger.
                        r.stim_trigger_interval = r.f_times(end) - stim_trigger_times(1);
                        r.stim_end = r.f_times(end);
                    end
                end
                
                % Bg PMT level in images (vol)
                a = sort(vec(vol(:,:,1))); % inferred from 1st frame
                N = ceil(size(vol, 1)/10);
                bg_PMT = mean(a(1:(N*N)));
                    
                % Extract roi trace from vol.
                vol_reshaped = reshape(vol, [], r.numFrames);
                for i=1:r.numRoi
                    y = mean(vol_reshaped(cc.PixelIdxList{i},:),1);
                    y = y - bg_PMT;       % bg substraction
                    r.roi_trace(:,i) = y; % raw data (bg substracted)
                    %r.stat.mean_f(i) = mean( y(r.f_times > stim_trigger_times(1) & r.f_times < r.stim_end) ); 
                end
                r.stat.mean_f = mean( r.roi_trace(r.f_times > stim_trigger_times(1) & r.f_times < r.stim_end, :), 1);                
             
                % ignore data before the 1st stim trigger
                r.ignore_sec = stim_trigger_times(1);
                    
                % Avg trace settings
                if ~isempty(stim_trigger_times) && numel(stim_trigger_times) >=3 && ...
                        isempty(strfind(r.ex_name, 'whitenoise')) && isempty(strfind(r.ex_name, 'run')) && isempty(strfind(r.ex_name, 'runme'))
                    
                    r.avg_FLAG = true;
                    
                        % params for avg & avg plot
                        avg_every = 1;
                        r.n_cycle = 1;
                        r.s_phase = 0;
                        % special cases
                        if strfind(r.ex_name, 'typing')
                            avg_every = 12;
                            if strfind(r.ex_name, 'flash')
                                avg_every = 6;
                            end
                            % copy the trace in (-) times.
                            r.n_cycle =2;
                            r.s_phase =1;
                            r.t_range =[-0.8, 100];
                        elseif strfind(r.ex_name, 'flash')
                            r.n_cycle = 2;
                            r.s_phase = 0.25;
                        elseif strfind(r.ex_name, 'movingbar')
                            avg_every = 4;
                        elseif strfind(r.ex_name, 'jitter')
                            avg_every = 2;
                        end
                        n = input(['Avg over every ', num2str(avg_every), ' stim times ? [Y or type N]']);
                        if isempty(n)
                            n = avg_every;
                        end
                        %disp(['Avg over every ', num2str(avg_every), ' stim times.']);
                        % set avg_every
                        r.avg_every = n;

                        % cluster mean for avg trace (100 clusters max)
                        r.c_mean = zeros(length(r.avg_times), 100);
                        
                        % times (x-axis) setting for avg plot
                        r.a_times = r.timesForAvgPlot;
                else
                    r.avg_FLAG = false;
                end
                  
                % default smoothing or smoothed traces
                %r.smoothing_method = 'movmean';
                r.smoothing_size = r.smoothing_size_init;
                    
                % whitenoise stim
                if nargin > 5
                    r.stim_whitenoise = stim_whitenoise;
                    r.stim_fliptimes = stim_fliptimes;
                elseif strfind(r.ex_name, 'whitenoise')
                    r.load_h5;
                    % stim size?
                    r.stim_size = input('Stim size for whitenoise stim? [mm]: ');
                    %r.stim_size = 
                end

                % cluster parameters
                r.c = zeros(1, r.numRoi);
                r.c_note = cell(1, 100);
                r.c_hfig = [];
                r.roi_review = [];
            end
        end
        
        function set.avg_every(r, n_every)
                %
                r.avg_every = n_every;
                
                % avg trigger times
                if r.avg_every > 1 
                    id_trigger = mod(1:numel(r.stim_trigger_times), r.avg_every) == 1; % logical array
                    r.avg_trigger_times = r.stim_trigger_times(id_trigger);
                else
                    r.avg_trigger_times = r.stim_trigger_times;
                end

                % stim events within one avg
                r.avg_stim_times = r.stim_trigger_times(1:r.avg_every+1) - r.stim_trigger_times(1);

                % avg trigger interval
                if numel(r.avg_trigger_times) > 1
                    r.avg_trigger_interval = r.avg_trigger_times(2) - r.avg_trigger_times(1);
                else
                    disp('Only one trigger event for averaging over responses to (repeated) stims');
                    r.avg_trigger_interval = 10
                end
                disp(['Avg trigger interval is ', num2str(r.avg_trigger_interval), ' secs.']);

                % times for avg traces
                n = floor(r.avg_trigger_interval*(1./r.ifi)); % same as qx in align_rows_to_events function
                r.avg_times = ((1:n)-0.5)*r.ifi;
                
                % times (x-axis) setting for avg plot
                r.a_times = r.timesForAvgPlot;
        end
        
        % Function for phase shift and multiply
        function yy = traceForAvgPlot(obj, y)
            [row, col] = size(y);
            if row == 1
                yy = circshift(y, round( obj.s_phase * col ) );
                yy = repmat(yy, [1, obj.n_cycle]);
%             elseif col == 1 
%                 yy = circshift(y, round( obj.s_phase * row ) );
%                 yy = repmat(yy, [obj.n_cycle, 1]);
            else
                % assume row vector is time series.
                yy = circshift(y, round( obj.s_phase * row ) );
                yy = repmat(yy, [obj.n_cycle, 1]);
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
        
        function set.roi_filtered_norm(obj, value)
            obj.roi_filtered_norm = value;
            obj.roi_normalized = value;
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

