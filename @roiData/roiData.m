classdef roiData < matlab.mixin.Copyable
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
        ex_name
        image       % Snapshot of the vol (mean)
        header      % Imaging condition
        ex_stim     % Stim parameters struct
        %
        roi_cc      % roi information (struct 'cc')
        ifi         % inter-frame interval of vol (data)
        stim_trigger_times % Absolute times when stims (or PD) were triggered. Fine triggers.
        sess_trigger_times % Absolute times of session (or major) triggers. Should be a subset of stim_triggers, but the value can be a little off from it.
        sess_trigger_ids   % Session triggers as ids of stim_trigger_times. Used in select_data().
        stim_end
        %
        stim_movie
        stim_fliptimes     % relative times between whitenoise flip times. Should start from 0.
        stim_size          % spatial size [mm]
        stim_disp          % stimulus disp params
        % 
        numFrames
        numRoi
        roi_trace       % raw trace (bg substracted. No other post-processing)
        roi_smoothed    % smoothed raw trace
        roi_smoothed_detrend % trend substracted
        roi_smoothed_norm    % norm by trend of detrended: dF/F
        roi_filtered    % lowpass filtered
        roi_trend       % trend for normalization
        roi_filtered_norm % dF/F @ dF = filtered - detrended, F = detrended_trace
        
        roi_mean_f      % mean fluorescnece level during the stimulus
        f_times         % frame times
        ignore_sec      % ignore first few secs for filtering. SHould be updated before updateing filtering. (default: until 1st trigger)
        f_times_fil     % Times for all traces except raw and smoothed traces.
        f_times_norm    % Currently, same as f_times_fil.
        
        % statistics
        stat
        p_corr % between repeats ['.smoothed', '.smoothed_norm']. Only available for avg analysis.
               % computed @ updated_smoothed_trace 
        
        % smoothing params
        smoothing_method = 'movmean';
        smoothing_size  
        smoothing_size_init = 3;
                
        % params:  Norm. (or Nyquist) freq. 
        w_filter_low_pass  = 0.4 
        w_filter_low_stop  = 0.6
        w_filter_trend_pass 
        w_filter_trend_stop 
        
        % avg trace timed at avg_trigger_times (always smoothed at least)
        avg_FLAG = false
        avg_every
        avg_trigger_times % Times for aligning between trials. A subset of stim_trigger_times. Might be same as sess_trigger_times
        avg_stim_times  % stim times within one avg trace [0 duration]
        avg_stim_plot   % structure for plot properties of each stim triggers.
        avg_stim_tags
        avg_trigger_interval
        avg_trace       % avg over trials. SMOOTHED. (times x roi#): good for 2-D plot
        avg_trace_norm  % Normed and centered. Not detrended.
        avg_trace_fil   % avg over (filtered) trials.
        avg_trace_smooth_norm
        avg_trace_std   % std over trials
        %avg_trace_filter_norm
        avg_projected   % projected trace onto (PCA) space.
        avg_pca_score   % roi# x dim
        avg_times   % times for one stim cycle
        a_times     % times for avg plot. Full cycles (e.g. 2 cycles). Phase shifted.
        t_range = [-1.5, 100] % Time filter for avg plot range (last filter). can be arbitrarily time points. [secs]
        
        % whitenoise responses
        rf              % cell arrays
        
        % clusters for ROIs
        dispClusterNum = 10;
        totClusterNum = 100;
        c             % cluster id array. 0 is unallowcated or noisy group
        c_mean        % cluster mean for average trace (trace X #clusters ~100). update through plot_cluster
        c_hfig
        c_note
        roi_review
        roi_selected
        roi_good % selected ids for good cells (e.g. high correlation over repeats) 
        
        % properties for plot of averaged trace: use traceAvgPlot.
        n_cycle = 2 
        s_phase = 1 % Shift phase toward negative time direction. 
        %c_range = [0, 1]; % Cycle range. Not used yet. 
        coeff   % (PCA) basis
    end
 
    properties (Hidden, Access = private)
        stim_trigger_interval % if triggers are irregular, meaningless. Do not use it.
        % old names
        stim_times      % (= stim_trigger_times)
        stim_duration   % stim trigger interval
        s_times         % single trial times
        roi_normalized  % (= roi_filtered_norm) dF/F @ dF = filtered - detrended, F = detrended_trace
        stim_whitenoise
    end
    
    methods
        
        function  rr = select_data(r, stim_ids, trigger_type)
            % Given stim trigger ids (not avg repeat triggers), create new instance of roiDATA
            % stim trigger times id. (e.g. [2, 3, 4])
            % trigger id = 0 means from the first data point.
            % avg triggers should be a subset of stim ids.
            if nargin < 3
                trigger_type = 'sess';
                disp('select_data trigger_type: session');
            end
            
            if nargin < 2
                error('Trigger ids (default: session triggers) must be given as a variable (e.g. 6:10).');
            end
            
            rr = copy(r);
            
            % Trigger type
            switch trigger_type
                case 'sess'
                    % start stim trigger id
                    if stim_ids(1) == 0
                        init_stim_trigger_id = 0;
                    else    
                        init_stim_trigger_id = r.sess_trigger_ids(stim_ids(1));
                    end
                    % end stim trigger id
                    if stim_ids(end) == numel(r.sess_trigger_times)
                        % last session.
                        end_stim_trigger_id = numel(r.stim_trigger_times);
                    else
                        % not last sessoin.
                        next_session_stim_trigger_id = r.sess_trigger_ids( stim_ids(end) + 1 );
                        end_stim_trigger_id = next_session_stim_trigger_id - 1;
                    end
                    % range as stim trigger ids
                    stim_ids = init_stim_trigger_id:end_stim_trigger_id;
                case 'stim'
                    
                otherwise
            end
            
            % Time range
            if stim_ids(1) == 0
                t_init = 0.;
                disp('Stim trigger id 0: start t = 0.');
                % exclude id =0
                stim_ids = stim_ids(2:end);
            else
                t_init = rr.stim_trigger_times( stim_ids(1) );
            end
            
            % Is the ending index the last trigger?
            if stim_ids(end) >= length(rr.stim_trigger_times)
                t_end = rr.f_times(end);
            else 
                t_end = rr.stim_trigger_times( stim_ids(end)+1 );
            end
            
            % Select data for [t_init, t_end]
            ids = (rr.f_times>=t_init) & (rr.f_times<=t_end); 
            rr.roi_trace = rr.roi_trace(ids, :);
            rr.f_times   = rr.f_times(ids) - t_init; % frame times
            rr.stim_end = rr.f_times(end);
            
            % Shift 'stim trigger times'
            rr.stim_trigger_times = rr.stim_trigger_times(stim_ids); 
            rr.stim_trigger_times = rr.stim_trigger_times - t_init;
            
            % Shift igonre_sec 
            rr.ignore_sec = rr.stim_trigger_times(1);           
            
            % Avg triggers every N stim triggers for new instance?
            if r.avg_FLAG
                str_input = sprintf('Stim trigger events: %d.\nAvg over every N triggers? [Default N = %d (%s)]',...
                                length(stim_ids), r.avg_every, r.ex_name);
                n = input(str_input);
                if isempty(n)
                    n = r.avg_every; % case default number
                end
                % set avg_every (set.avg_every)
                rr.avg_every = n; % include trace updating.
            else
                % update only
                rr.update_smoothed_trace;
            end
        end
        
        function load_ex2(r, ex)
            % Read 'ex' structure and interpret it. Old version.
            % interpret if middle line is preffered for plot for each stim type.
            disp('This is old version. Use version1');
            
            if iscell(ex.stim)
                stim = [ex.stim{:}];
            else
                stim = ex.stim;
            end
            % name tags as cell array
            i = 1; % id for trigger events
            k = 1; % id for stim struct
            while i <= r.avg_every
                if isfield(stim(k),'cycle') && ~isempty(stim(k).cycle)
                    cycle = stim(k).cycle;
                else
                    cycle = 1;
                end
                ids = (1:cycle) + (i-1);
                r.avg_stim_tags(ids(1)) = {stim(k).tag};
                i = max(ids) + 1;
                k = k + 1; % next stim tag
            end
            if k-1 == length(stim)
                fprintf('All (k=%d) stim tags were scanned and aligned with num of stim triggers.\n', k-1);
            elseif k-1 < length(stim)
                fprintf('Stim tigger lines are more than # of stim tags.\n');
            end
        end
        
        function load_ex1(r, ex)
            % Read 'ex' structure and interpret it.
            % Loop over ex.stim.
            r.ex_stim = ex;
%             if isfield(ex, 'n_repeats') && ~isempty(ex.n_repeats) 
%                 n_repeat = ex.n_repeats;
%             end
%           
            if isempty(ex)
                return;
            end
            
            if iscell(ex.stim)
                stim = [ex.stim{:}];
            else
                stim = ex.stim;
            end

            
            i = 1; % id for trigger events
            
            for k = 1:numel(stim)
                % conditions according to tag name
                switch stim(k).tag
                    case 'blank'
                        r.avg_stim_plot(i).middleline = false;
                    case ' '
                        r.avg_stim_plot(i).middleline = false;
                    otherwise
                        r.avg_stim_plot(i).middleline = true;
                end
                % cycle
                if isfield(stim(k),'cycle') && ~isempty(stim(k).cycle)
                    cycle = stim(k).cycle;
                else
                    cycle = 1;
                end
                
                % conditions according to phase in 1st cycle.
                tag_shift = 0;
                if isfield(stim(k),'phase_1st_cycle') && ~isempty(stim(k).phase_1st_cycle) % constatnt phase over the first cycle.
                    r.avg_stim_plot(i).middleline = false;
                    if cycle > 1
                        tag_shift = 1;
                    end
                end
                % display tag     
                r.avg_stim_tags(i + tag_shift) = {stim(k).tag};
                r.avg_stim_plot(i + tag_shift).tag = stim(k).tag;
                %   
                i = i + cycle;
            end
            
            if i-1 == r.avg_every
                fprintf('All stim tags (k=%d) were scanned and aligned with num of %d stim trigger times (registered by PD).\n', k-1, r.avg_every);
            elseif i-1 < r.avg_every
                fprintf('Stim tigger lines are more than # of stim tags. Make sure how many triggers are supposed to be in one stim repeat. Please load ex again. \n');
            elseif i-1 > r.avg_every
                fprintf('Stim tigger lines are less than # of stim tags. Make sure how many triggers are supposed to be in one stim repeat. Please load ex again. \n');
            end
        end
        
        function load_h5(r, dirpath)
        % load stim data from 'stimulus.h5' in current directory    
            %h5info('stimulus.h5')
            %h5disp('stimulus.h5')
            if nargin < 2
                disp('Looking for h5 file in ..');
                dirpath2 = '/Users/peterfish/Documents/1__Retina_Study/Docs_Code_Stim/Mystim';
                dirpath3 = 'C:\Users\scanimage\Documents\MATLAB\visual_stimulus\logs\18-06-22';
                disp(['1. Current dir = ', pwd]);
                disp(['2. ', dirpath2]);
                disp(['3. ', dirpath3]);
                n = input('Which dir do you want to search stimulus.h5? [1]: ');
                if isempty(n)
                    n = 1;
                end
                switch n
                    case 1
                        dirpath = pwd;
                    case 2
                        dirpath = dirpath2;
                    case 3
                        dirpath = dirpath3;
                    otherwise
                end
            end
            
            fname = [dirpath, '/stimulus.h5']; 
            if ~exist(fname, 'file')
                disp('no file for /stimulus.h5.');
                return;
            end
            
            % stim id for whitenoise?
            h5disp(fname);
            a = h5info(fname);
            
            % Assuption: Group /expt1 is a whitenoise stimulus.
            disp('Assumption: group /expt1/ (among several) is a whitenoise stimulus. Load /expt1/.'); % new function for /expt2 is needed.
            stim = h5read([dirpath, '/stimulus.h5'], '/expt1/stim');
            times = h5read([dirpath, '/stimulus.h5'], '/expt1/timestamps');
            
            % /Datasets (Name: /disp) 
            if contains(a.Datasets.Attributes.Name, 'aperturesize_whitenoise_mm')
                whitenoise_size = h5readatt([dirpath, '/stimulus.h5'], '/disp', 'aperturesize_whitenoise_mm');
            else
                whitenoise_size = NaN;
            end
            if contains(a.Datasets.Attributes.Name, 'aperturesize_mm')
                aperture_size = h5readatt([dirpath, '/stimulus.h5'], '/disp', 'aperturesize_mm');
            else
                aperture_size = NaN;
            end
            fprintf('Aperture size [mm]: %.3f, Whitenoise aperture size [mm]: %.3f\n', aperture_size, whitenoise_size);
            
            %
            r.get_stimulus(stim, times, whitenoise_size);
            disp('Whitenoise stimulus info has been loaded.');
            
            % select_data ?
        end
        
        function save(r)
            % struct for save
            % roi info
            s.cc = r.roi_cc;
            % avg plot info
            %s.avg_stim_tags = r.avg_stim_tags;
            s.avg_stim_plot  = r.avg_stim_plot;
            s.avg_stim_times = r.avg_stim_times;
            % cluster info
            s.c = r.c;
            s.c_note = r.c_note;
            s.roi_review = r.roi_review;
            % stim ex
            s.ex_stim = r.ex_stim;
            save([r.ex_name,'_roiData_save'], '-struct', 's');
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
                % c_mean (avg trace) update
                for i = 1;r.totClusterNum
                    y = r.avg_trace(:, r.c==i);
                    y = normc(y);               % Norm by col
                    y = mean(y, 2);
                    % Mean substraction and normalization might be needed.
                    r.c_mean(:,i) = y;
                end
                % pca update
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
            imvol(r.image, 'title', r.ex_name, 'roi', r.roi_cc, 'edit', true, 'scanZoom', r.header.scanZoomFactor); % can be different depending on threhsold 
        end
        
        function get_stimulus(r, stims_whitenoise, fliptimes, aperture_size)
            if nargin > 3
                r.stim_size = aperture_size;
                if isempty(r.stim_size)
                    disdp('Stim_size is still empty.');
                end
            end
            % for whithenoise stim
            r.stim_movie = stims_whitenoise;
            r.stim_fliptimes = fliptimes;
        end
        
        function set.smoothing_size(r, t)
            r.smoothing_size = t;
            r.update_smoothed_trace;
        end
        
        function set.w_filter_low_pass(r, w)
            r.w_filter_low_pass = w;
            r.update_smoothed_trace;
        end
        
        function set.w_filter_low_stop(r, w)
            r.w_filter_low_stop = w;
            r.update_smoothed_trace;
        end
        
                
        % constructor
        function r = roiData(vol, cc, ex_str, ifi, stim_trigger_times, stim_movie, stim_fliptimes)
            % ifi: inter-frame interval or log-frames-period
            if nargin > 0 % in order to create an array with no input arguments.
                disp('roiData..');
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
                %
                if nargin < 5 
                    stim_trigger_times = 0;
                end
                %
                if nargin < 4
                    ifi = 1;
                end
                %
                if nargin < 3
                    ex_str = [];
                end
                %
                r.ex_name = ex_str;
                r.ifi = ifi;
                r.f_times = ((1:r.numFrames)-0.5)*ifi; % frame times. in the middle of the frame
                r.stim_end = r.f_times(end); % used also for stat.
                
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
                end
                disp('ROI traces were extracted..');
                
                % stim_triger_times can be a cell array
                % {1} : events1 - Major events. ~ sess_trigger_times
                % {2} : events2 - Finer evetns. ~ stim_trigger_times
                % {3} : ...
                if iscell(stim_trigger_times)
                    switch numel(stim_trigger_times)
                        case 2
                            r.stim_trigger_times = stim_trigger_times{2}; % minor trigger events
                            r.sess_trigger_times = stim_trigger_times{1}; % major trigger events
                            %
                            numStimTriggers = numel(r.stim_trigger_times);
                            numSessTriggers = numel(r.sess_trigger_times);
                            fprintf('Stim triggers: %d, Session (major) triggers: %d are given.\n', numStimTriggers, numSessTriggers);
                            
                            % Num of stim triggers within one session
                            n = floor(numStimTriggers/numSessTriggers);
                            if rem(numStimTriggers, numSessTriggers) ~= 0
                                fprintf('Not divisible, You would want to check the alignmennt between them.\n');
                                % average setting afterwards?
                            else
                                % Divisible. 
                                % Assign stim trigger IDs to session triggers.
                                % (Assumption: num of stim triggers inside one
                                % session would be same over multiple sessions.)
                                ids = 1:numel(r.stim_trigger_times);
                                whereis_sess = mod(ids, n) == 1; % logical array
                                r.sess_trigger_ids = ids(whereis_sess);
                                if n == 1 % exception
                                    r.sess_trigger_ids = ids;
                                end
                                
                                % Session as repeated stimulus?
                                fprintf('%d stim triggers in one session.\n', n);
                                str_input = sprintf('\nAre they repeated by %d times (every %d triggers) [Y]?\n(or enter how many stim triggers were in one repeat. Enter 0 if it is not repeated.)\n', numSessTriggers, n);
                                n_new = input(str_input);
                                if isempty(n_new)
                                    n_new = n; % case default number
                                end
                                r.avg_every = n_new; % set method
                            end
                            
                        otherwise
                            r.stim_trigger_times = stim_trigger_times{1};
                            r.sess_trigger_times = stim_trigger_times{1};
                    end
                    
                else
                    % not cell array.
                    r.stim_trigger_times = stim_trigger_times;
                    r.sess_trigger_times = stim_trigger_times;
                end
                    
                % load ex struct?
                
                % Avg trace settings: only needed when major triggers are
                % not divisible..
                if r.avg_FLAG==false && ~isempty(r.stim_trigger_times) && numel(r.stim_trigger_times) > 1
                        %
                        avg_every = 1;
                        
                        % special cases
                        if strfind(r.ex_name, 'typing')
                            avg_every = 23;
                            % copy the trace in (-) times.
                            r.n_cycle =2;
                            r.s_phase =1; % shfit one full cycle
                            r.t_range =[-0.9, 100];
                        elseif strfind(r.ex_name, 'flash')
                            r.n_cycle = 2;
                            r.s_phase = 0.25;
                            r.t_range =[-100, 100];
                        elseif strfind(r.ex_name, 'movingbar')
                            avg_every = 8;
                        elseif strfind(r.ex_name, 'jitter')
                            avg_every = 2;
                        end
                        
                        % User input
                        str_input = sprintf('PD trigger events num: %d.\nRepeated stimulus over every N triggers? [Default N = %d (%s). 0 for no average analysis]',...
                            length(r.stim_trigger_times), avg_every, r.ex_name);
                        n = input(str_input);
                        if isempty(n)
                            n = avg_every; % case default number
                        end
                        
                        if n == 0
                            r.avg_FLAG = false;
                        else 
                            % set avg_every (excute set.avg_every)
                            r.avg_every = n;
                        end     
                end
                
                % cluster mean initialization (100 clusters max)
                r.c_mean = zeros(length(r.avg_times), r.totClusterNum);
                  
                % default smoothing or smoothed traces
                %r.smoothing_method = 'movmean';
                r.smoothing_size = r.smoothing_size_init;
                    
                % whitenoise stim?
                if nargin > 5
                    r.stim_movie = stim_movie;
                    r.stim_fliptimes = stim_fliptimes;
                elseif strfind(r.ex_name, 'whitenoise')
                    r.load_h5;
                    % stim size?
                    if isempty(r.stim_size) || (r.stim_size == 0)
                        r.stim_size = input('Stim size for whitenoise stim? [mm]: ');
                    end
                end

                % cluster parameters
                r.c = zeros(1, r.numRoi);
                r.c_note = cell(1, 100);
                r.c_hfig = [];
                r.roi_review = [];
                
                % stat
                r.stat.mean_f = mean( r.roi_trace(r.f_times > r.stim_trigger_times(1) & r.f_times < r.stim_end, :), 1);
                
                % Plot several (avg) traces
                numCell = min(21, r.numRoi);
                if r.avg_every > 0
                    % ROIs exhibiting hiested correlations between traces
                    % under repeated stimulus
                    [corr, good_cells] = sort(r.p_corr.smoothed_norm, 'descend');
                    r.roi_good = good_cells;
                    % summary
                    for ss = 1:numCell
                        fprintf('ROI%3d: corr between trials %5.2f\n', good_cells(ss), corr(ss));
                    end
                    % plot
                    r.plot_repeat;
                    print([r.ex_name, '_plot_repeats'], '-dpng', '-r300');
                    make_im_figure;
                    r.plot_roi(good_cells(1:numCell));
                else
                    % single trial case 
                    [mean_f, good_cells] = sort(r.stat.mean_f, 'descend');
                    % summary
                    for ss = 1:numCell
                        fprintf('ROI %d: mean fluorescence level %5.2f\n',good_cells(ss), mean_f(ss));
                    end
                    % plot
                    r.roi_good = good_cells;
                    r.plot(r.roi_good);
                    print([r.ex_name, '_plot'], '-dpng', '-r300');
                end

            end
        end
        
        function set.avg_every(r, n_every)
                
                if n_every == 0
                    r.avg_FLAG = false;
                    r.avg_every = 0;
                    disp('Average analysis OFF..');
                    return;
                end
                    
                %
                r.avg_FLAG  = true;
                r.avg_every = n_every;
                disp('Average analysis ON..');
                
                % avg trigger times: automatically invokes
                % update_smoothed_trace
                if r.avg_every > 1 
                    id_trigger = mod(1:numel(r.stim_trigger_times), r.avg_every) == 1; % logical array
                    r.avg_trigger_times = r.stim_trigger_times(id_trigger);
                else
                    r.avg_trigger_times = r.stim_trigger_times;
                end
  
                % Given avg_trigger_times and avg_trigger_interval, update
                % traces. p_corr is computed.
                % in set method of avg_trigger_times.
                %r.update_smoothed_trace;
                
                % stim events within one avg
                r.avg_stim_times = r.stim_trigger_times(1:r.avg_every) - r.stim_trigger_times(1);
                
                % times for avg traces
                n = floor(r.avg_trigger_interval*(1./r.ifi)); % same as qx in align_rows_to_events function
                r.avg_times = ((1:n)-0.5)*r.ifi;
                
                % times (x-axis) setting for avg plot: shifted and
                % repeated.
                r.a_times = r.timesForAvgPlot; % New version will be 'timesAvgPlot'
                
                % cell array for tags
                r.avg_stim_tags = cell(1, n_every);
                % struct for the plot properties of each stim trigger time
                r.avg_stim_plot = struct('tag', [], 'middleline',[], 'shade', []);
                r.avg_stim_plot(n_every) = r.avg_stim_plot; % struct array
                    [r.avg_stim_plot(:).middleline] = deal(true);
                    [r.avg_stim_plot(:).shade]      = deal(false);
        end
        
        function set.avg_trigger_times(r, new_times)
            % Assign new times
            r.avg_trigger_times = new_times;
            
            % Avg trigger interval & stim end
            if numel(r.avg_trigger_times) > 1
                r.avg_trigger_interval = r.avg_trigger_times(2) - r.avg_trigger_times(1);
                disp(['Avg trigger interval: ', num2str(r.avg_trigger_interval), ' secs.']);

                numAvgTrigger = numel(r.avg_trigger_times);

                if r.f_times(end) < (r.avg_trigger_times(end) + r.avg_trigger_interval)
                    r.stim_end = r.f_times(end);
                    numRepeat = numAvgTrigger - 1;
                else
                    r.stim_end = r.avg_trigger_times(end) + r.avg_trigger_interval;
                    numRepeat = numAvgTrigger;
                end
            else
                disp('Single trial response. Default time interval between trigger is set to 10 secs.');
                r.avg_trigger_interval = 10;
                numRepeat = 1;
            end
            fprintf('Num of Avg triggers: %d.\n', numAvgTrigger);
            fprintf('Num of full repeats: %d.\n', numRepeat);
            
            % update traces
            r.update_smoothed_trace;
        end
        
        % Function for phase shift and multiply for vector
        function yy = traceForAvgPlot(obj, y)
            % initial & old version.
            [row, col] = size(y);
            if row == 1
                yy = circshift(y, round( obj.s_phase * col ) );
                yy = repmat(yy, [1, obj.n_cycle]);
%             elseif col == 1 
%                 yy = circshift(y, round( obj.s_phase * row ) );
%                 yy = repmat(yy, [obj.n_cycle, 1]);
            else
                % assume Dim1 is time series.
                yy = circshift(y, round( obj.s_phase * row ) );
                yy = repmat(yy, [obj.n_cycle, 1]);
            end
            
        end
 
        function tt = timesForAvgPlot(obj, ev_times)
            % Event times for average plot
            % if event times are not given, output (tt) is times (x-axis) for avg plot. 
            if nargin < 2
                ev_times = obj.avg_times;
            end
            N = length(ev_times);
            % extend times
            tt = repmat(ev_times, [1, obj.n_cycle]);
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
        
        function set.avg_trigger_interval(obj, value)
            obj.avg_trigger_interval = value;
            obj.stim_trigger_interval = value; % no more use due to irregular trigger interval
            obj.stim_duration = value; % old name for stim_trigger_interval
        end
        
%         function set.stim_trigger_interval(obj, value)
%             obj.stim_trigger_interval = value;           
%         end
%         
        function value = get.stim_whitenoise(obj)
            value = obj.stim_movie;
        end
    end
    
end % classdef

function aa = vec(a)
    aa = a(:);
end

