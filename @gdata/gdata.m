classdef gdata < handle
%GDATA Data class for single experiment session.
% Open single (or multiple) TIF file(s). Interpret ScanImage and WaveSurfer
% header files.
% Assumptions for AI channels:
%                   Num of channels - 4
    properties
            % File info
            ex_name
            dirpath
            tif_filename
             h5_filename
            header
            metadata % raw header file
            
            % Imaging data [Scanimage TIF]
            n_channels = 4 % max channel number
            AI_chSave
            AI       % raw data
            AI_mean  % mean over snaps. 
            AI_snaps % snaps over first and last xxx frames (not aligned with triggers).
            AI_trace % Averaged trace over the first pixel of all lines in each frame.
                     % CH 2 is often regarded as PD signal. Can be
                     % upsampled than frame rate.
            AI_trigger_ch = 2 % Channel for direct recording of PD triggers.
                              % If emptty, default trigger will be from
                              % WaveSurfer h5.
            vol_smoothed % Smoothed image frames (only for roi channel)
            %vol_smooth_size = 11
            nframes  % per channel (e.g. PMT)
            ifi
            f_times % frame times
            t_times % trace times. Used for multi-sampling of PD from a single frame. 
            size     % size of frame [pixels, lines]
            numSlices % stack is more than 1 numSlices.

            % Recording (pd & e-phys) data [WaveSurfer H5]
            h5_header
            h5_srate
            h5_AI
            h5_times
            h5_pd_raw % raw pd trace from WaveSurfer h5
            pd_AI_name = 'photodiode';
            
            % pd events (can be recorded by WaveSurfer or by Scanimage CH2)
            pd_trace
            pd_times
            pd_threshold1 = 0.5 % Major events
            pd_threshold2 = 0.08 % Minnor events
            min_interval_secs = 0.8
            ignore_secs = 2 % Skip some initial times for threshold detection.
            
            % stimulus events
            pd_events1  % trigger times
            pd_events2  % trigger times
            stims      % 1~10 stimulus. Times [sec] for stim trigger events.
            stims_ids  % clustered pd event ids up to 10 groups.
            intervals  % if it's not empty, the stim was repeated. Probably good to average.
            stim_fliptimes  % trigger events or fliptimes. up to 10 differnet cell arrays
            stim_whitenoise        % whitenoise stim pattern
            
            % bg noise analysis
            bg_trace     % unnormalized raw trace for 'bg' pixels.
            bg_events    % times
            bg_events_id % frame ids
            
            % average analysis
            avg_trigger_times
            avg_vol
            avg_duration
            
            % roi response data
            numStimulus % and initialize roiDATA objects. Should be initialized at least 1.
            rr          % roiData object
            cc          % ROI connectivity structure
            roi_channel
    end   

    methods
            function s = getFigTitle(g, ch)
                % for figure title
                if nargin < 2
                    if ~isempty(g.roi_channel)
                        ch = g.roi_channel;
                    else
                        ch = g.header.channelSave(1); % first available channel
                    end
                end
                 % title name
                 t_filename = strrep(g.tif_filename, '_', '  ');
                 s = sprintf('%s  (ch:%d)', t_filename, ch);
            end
            
            function filename = getFigFileName(g, ch)
                s = getFigTitle(g,ch);
                filename = strrep(s, ' ', '_');
                filename = strrep(filename, '(', '_');
                filename = strrep(filename, ')', '_');
                filename = strrep(filename, ':', '');
                filename = strrep(filename, '__', '_');
                filename = strrep(filename, '00', '');
            end
            
            function snaps = imdrift(g, ch, nframes)
                % imshowpair and save.
                % See if the cells were drift over imaging session
                % Output vol: 3 frames. Before, After and of their mean.
                % Channel should be specified.
                if nargin < 3
                    row = g.size(1);
                    col = g.size(2);
                    nframes = min(g.nframes, round(512*512*1000/row/col));
                end
                
                if nargin > 1
                    n = min(nframes, g.nframes);
                    fprintf('Total frame numbers; %d. imdrift(): %d frames were compared. (Green-Magenta false color)\n', g.nframes, n);
 
                    AI_mean_early = mean(g.AI{ch}(:,:,(1:n)), 3);    
                    AI_mean_late  = mean(g.AI{ch}(:,:,(end-n+1:end)), 3);
                    %
                    g.figure;
                    imshowpair(myshow(AI_mean_early, 0.2), myshow(AI_mean_late, 0.2)); % contrast adjust by myshow()
                    title('Is it drifted? (Green-Magenta)', 'FontSize', 18, 'Color', 'w');
                    print([g.getFigFileName(ch),'_drift.png'], '-dpng', '-r300'); %high res
                    snaps = cat(3, AI_mean_early, AI_mean_late);
                    snaps = cat(3, AI_mean_early, AI_mean_late, mean(snaps, 3));
                else
                    for PMT_ch=g.header.channelSave
                        if PMT_ch==4; continue; end;
                        snaps = imdrift(g, PMT_ch);
                    end
                end
            end
            
            function J = imvol(g, ch, varargin)
                % You can specify title if you specify channel #. 
                if nargin < 2
                    ch = g.header.channelSave;
                end
                
                for i = ch
                    if i ~= g.AI_trigger_ch
                        s_title = sprintf('%s  (CH:%d, ScanZoom:%.1f)', g.ex_name, i, g.header.scanZoomFactor);
                        if numel(varargin) > 0
                            if ischar(varargin{1})
                                s_title = varargin{1};
                            end
                        end

                        if contains(g.ex_name, 'stack') || g.numSlices > 1
                            J = imvol(g.AI{i}, 'title', s_title, 'scanZoom', g.header.scanZoomFactor, 'z_step_um', g.header.stackZStepSize);
                        else
                            if isempty(g.cc)
                                J = imvol(g.AI_snaps{i}, 'title', s_title, 'scanZoom', g.header.scanZoomFactor, 'globalContrast', true);
                            else
                                disp('''cc'' was given to imvol().');
                                J = imvol(g.AI_snaps{i}, 'title', s_title, 'scanZoom', g.header.scanZoomFactor, 'roi', g.cc, 'edit', true, 'globalContrast', true);
                            end
                        end
                    end
                end
            end
            
            function hf = figure(g)
                % create figure with appropriate size.
                %pos = get(0, 'DefaultFigurePosition');
                if g.size(1) == g.size(2)
                    hf = figure('Position',[2 50 850 893]);
                else
                    hf = figure('Position',[2 50 850 1200]);
                end
                hf.Color = 'none';
                hf.PaperPositionMode = 'auto';
                hf.InvertHardcopy = 'off';
                axes('Position', [0  0  1  0.9524], 'Visible', 'off'); % space for title
            end
            
            function setting_pd_event_params(g)
%                 if contains(g.ex_name, 'flash')
%                     g.pd_threshold1 = 0.8;
%                     g.min_interval_secs = 0.8;
%                 elseif contains(g.ex_name, 'movingbar')
%                     g.pd_threshold1 = 0.4;
%                     g.min_interval_secs = 1.2;
%                 elseif contains(g.ex_name, 'jitter')
%                     g.pd_threshold1 = 0.4;
%                     g.min_interval_secs = 1;
%                 elseif contains(g.ex_name, 'whitenoise')
%                     g.pd_threshold1 = 0.4;
%                     g.min_interval_secs = 0.25;
%                 end
            end
            
            function ch = get.roi_channel(g)
                if ~isempty(g.roi_channel)
                    ch = g.roi_channel;
                    return;
                end
                % 
                available_channels = g.AI_chSave(g.AI_chSave ~= g.AI_trigger_ch);
                
                if length(available_channels) == 1
                    ch = available_channels;
                else
                    commandwindow
                    ch = input([g.ex_name, ': PMT channel # for main recording (Available: ', num2str(available_channels),') ? ']);
                end
                disp(['ROI analysis CH: ',num2str(ch),' is selected.']);
                g.roi_channel = ch;
            end
                
            function set.min_interval_secs(g, value)
                % print value
                disp(['Min time interval between stim triggers [secs]: ', num2str(value)]);
                g.min_interval_secs = value;
            end
                
            function set.numStimulus(obj, n)
                if n < 1
                    error('numStimulus should be 1 or larger');
                elseif n > 10
                    error('>10 stimulus in one recording session? Too many numStimulus.');
                end
                % (re)-initialize array of roiDATA
                %r(1, n) = roiData;
                %obj.rr = r;
                obj.numStimulus = n;
            end

            function set.cc(obj, cc)
            % will create roiData structure for only one channel. 
                
%                 % ROI channel should be assigned.
%                 if ~isempty(obj.roi_channel)
%                     ch = obj.roi_channel;
%                 elseif obj.header.n_channelSave == 1
%                     ch = obj.header.channelSave(1);
%                     disp(['ROI analysis ch: ',num2str(ch),' is selected.']);
%                 else
%                     commandwindow
%                     ch = input([obj.ex_name, ': PMT channel # for maing recording (Available: ', num2str(obj.header.channelSave),') ? ']);
%                 end
%                 obj.roi_channel = ch;
                ch = obj.roi_channel;
                disp(['Create roiData object for Ch#', num2str(ch), '...']); % it calls
                obj.cc = cc;

                % create roiData object (as many as numStimulus? No. roiData will handle it.)
                % 1. extract roi traces, 2. split into numStimulus
                if ~isempty(cc)
                    r = roiData(obj.AI{ch}, cc, [obj.ex_name,' [ch',num2str(ch),']'], obj.ifi, {obj.pd_events1, obj.pd_events2}); %{ avg triggers, stim triggers }
                    r.header = obj.header;
                    obj.rr = r;
                else
                    disp('The given cc structure is empty. No roiDATA object was assigned.');
                end
            end
            
            function set.roi_channel(obj, ch)
                if any(obj.AI_chSave == ch)
                    obj.roi_channel = ch;
                else
                    error('Not available channel number for roi analysis.');
                end
            end
            
            function id = frameid(g, time)
                % first id after the given time
                ids = find(g.f_times >= time);
                id = ids(1);
            end

            function g = gdata(tif_filename, h5_filename)
            % Construct input type1: single tif and single h5 (including path)
            % Construct input type2: single str input as filter in current directory
                pos = gdata.figure_setting();
                % cell array for AI channels.
                g.AI            = cell(g.n_channels, 1); % n_channels is defined at gdata properties.
                g.AI_mean       = cell(g.n_channels, 1);
                g.AI_snaps      = cell(g.n_channels, 1);
                g.AI_trace      = cell(g.n_channels, 1);

                if nargin > 0     
                    % single string input: string filter in current directory.
                    if nargin == 1 
                            dirpath = pwd;
                            ex_str = tif_filename;
                            [tif_filenames, h5_filenames] = tif_h5_filenames(dirpath, ex_str)

                            % TIF data import (single or multiple files) 
                            if numel(tif_filenames) > 1
                                reply = input('Are they all for single experiment session? Y/N [N]:','s');
                                if isempty(reply)
                                    reply = 'N';
                                end
                            else
                                % single file case
                                reply = 'N';
                            end

                            if strcmp(reply, 'N') || strcmp(reply, 'n')
                                % open single TIF file
                                disp('Select the first file.. Import SI data..');
                                i = 1;
                                tif_filename = [dirpath,'/',tif_filenames{i}]; 

                                if ~isempty(h5_filenames)
                                    % h5 file exists
                                    h5_filename = [dirpath,'/',h5_filenames{i}];
                                else
                                    h5_filename = [];
                                end

                            else
                                % open multiple data files
                                for i = 1:numel(tif_filenames)
                                    disp('Multiple Tif files logging. Under construction..Sorry.');
                                end
                            end
                    else
                        % direct filename input (probably called by fdata)
                        ex_str = tif_filename; 
                    end
                    name_tif = strsplit(tif_filename, '/');
                    g.tif_filename = name_tif{end};
                    g.ex_name = get_ex_name(g.tif_filename);
                    
                    % Open h5 file. Get pd events from h5.
                    g.h5FileOpenForStimTrigger(h5_filename);
                    
                    % Import Tif file
                    SI_data = ScanImageTiffReader(tif_filename);
                    g.metadata = SI_data.metadata;
                    
                    %
                    vol = SI_data.data; 
                    size_vol = size(vol);

                    % Header file
                    h   = interpret_SI_header_from_TiffReader(g.metadata, size_vol);
                    g.header = h;
                    g.ifi = g.header.logFramePeriod;
                    g.size = [g.header.pixelsPerLine, g.header.linesPerFrame];
                    g.numSlices = g.header.numSlices;
                    g.nframes = h.n_frames_ch;
                    
                    % frame times (~ ch frame times)
                    g.f_times = ((1:g.nframes)-0.5)*g.ifi;
                    
                    % channel initialization
                    for i = 1:g.n_channels
                        g.AI_mean{i} = zeros(size_vol(1), size_vol(2));
                    end

                    % AI channel info
                    g.AI_chSave = h.channelSave;
                                        
                    % Channel de-interleave and save sanpshots
                    n     = h.n_channelSave;
                    id_ch = mod((1:h.n_frames)-1, n)+1;
                    for j=1:n
                        % de-interleave
                        vol_ch = vol(:,:,id_ch==j); % vol for single ch: de-interleave frames
                        ch = h.channelSave(j);      % ch number
                        
                        % AI vol data
                        g.AI{ch} = vol_ch;
                        
                        % AI trace: averaged over 1st pixel of all lines in
                        % frame
                        col1_trace = g.AI{ch}(1, :, :);
                        % 2 (or multiple) samplings by dividing lines.
                        nlines = g.size(2);
                        nlines_half = round(nlines/2.);
                        a1 = mean(col1_trace(1, 1:nlines_half, :), 2); 
                        a2 = mean(col1_trace(1, nlines_half+1:end, :), 2);
                        a1=a1(:);
                        a2=a2(:);
                        aa = [a1.'; a2.'];
                        g.AI_trace{ch} = aa(:);
                    end
                    
                    n_sampling_per_frame = 2.;
                    g.t_times = ((1:n_sampling_per_frame*g.nframes)-0.75)*(g.ifi/n_sampling_per_frame);
                    
                    % PD trace recording via Scanimage AI Ch2.
                    if isempty(g.AI{g.AI_trigger_ch})
                        fprintf('AI trigger channel %d is empty. No direct pd signal was given to ScanImage.\n', g.AI_trigger_ch);
                        
                        % Check if acq was sync with triggers.
                        disp(['SI.extTrigEnable = ', h.extTrigEnable]);
                        if contains(h.extTrigEnable, 'false') || contains(h.extTrigEnable, '0')
                            disp('!!! Be aware that Scanimage was not triggered by stimulus trigger (e.g. WaveSurfer). !!!');
                        end
                        
                        % pd events were already detected if h5 file
                        % exists. 
                    else 
                        % event detect (+ plot)
                        g.pd_trace = g.AI_trace{g.AI_trigger_ch};
                        g.pd_times = g.t_times;
                        g.pd_events_detect;
                        title('Scanimage direct recording of photodiode signal');
                        fprintf('CH %d was used as stimulus trigger signal, and trigger events were detected.\n', g.AI_trigger_ch);
                        
                        % Was there any cross-talk between AI channels due
                        % to the direct PD recording? Usually, not really.
%                         figure;
%                         for ch = g.AI_chSave
%                             plot(g.AI_trace{ch}); hold on
%                         end
%                         title('1st pixel trace for all saved channels.');
%                         hold off
                    end
                    
                    % Make snaps for major trigger times.
                    for j=1:n % over channels
                        ch = h.channelSave(j);      % ch number
                        if ch ~= g.AI_trigger_ch
                            % mean image: first and last 1000 frames (for 512x512 pixels)
                            snaps = g.imdrift(ch);
                            snaps_times = [];
                            g.AI_snaps{ch} = snaps;
                            g.AI_mean{ch} = mean(snaps, 3);
                            
                            % title name
                            t_filename = strrep(g.tif_filename, '_', '  ');
                            s_title = sprintf('%s  (ch:%d)', t_filename, h.channelSave(j));
                            
                            % Update snaps if there are pd_events1
                            % triggers.
                            if ~isempty(g.pd_events1)
                                [snaps, snaps_times] = utils.mean_images_after_triggers(g.AI{ch}, g.f_times, g.pd_events1, 15); % mean of 15s duration at times of..
                                s_title = sprintf('%s snaps at pd_events1 (ch:%d)', t_filename, h.channelSave(j));
                                g.AI_snaps{ch} = snaps;
                            end
                            
                            % plot mean images
                            hf = g.figure;
                            %set(hf, 'Position', pos+[pos(3)*(j-1), -pos(4)*(1-1), 0, 0]);
                            imvol(snaps, 'hfig', hf, 'title', s_title, 'png', true, 'filename', g.ex_name, 'scanZoom', g.header.scanZoomFactor, 'timestamp', snaps_times, 'globalContrast', true);
                        end
                    end
                    
                    % BG crosstalk analysis.
                    ch = g.roi_channel;
                    g.plot_bg_pixels(ch); % detect bg (cross-talk) events. Bg pixels are selected from snap images.
                    
                    % Averaged frame
                    disp(' ');
                    g.avg_frames_by_triggers_in_session;
                    
                    % Load cc struct if exist
                    cc_filenames = getfilenames(pwd, ['/*',ex_str,'*save*.mat']);
                    if ~isempty(cc_filenames)
                        commandwindow
                        mat_file = cc_filenames{1};
                        reply = input(['Do you want to load ''',mat_file,''' in workplace to continue the ROI analysis? Y/N [Y]: '],'s');
                        if isempty(reply); reply = 'Y'; end
                        if reply == 'Y'
                            S = load(mat_file);
                            assignin('base', 'cc', S.cc);
                            %g.load_roiData_save(cc_filenames{1});
                        else
                            g.cc = [];
                        end
                    else
                        disp(['No .mat file for ''', ex_str, ''' (e.g. ''cc'' structure for ROI segmentation)']);
                        %g.cc = []; % initialize cc struct. No need to
                        %call set method.
                    end

                end
            end
            
        end
        
    methods(Static) % do not require an object of the class
        function pos_new = figure_setting()
            iptsetpref('ImshowInitialMagnification','fit');
            pos     = get(0, 'DefaultFigurePosition');
            width = 745;
            %pos_new = [10 950 width width*1.05];
            pos_new = [160 500 width width*1.05];
            set(0, 'DefaultFigurePosition', pos_new);
        end
    end
end

function [tif_filenames, h5_filenames] = tif_h5_filenames(dirpath, str)
    str_condition = ['/*',str,'*'];
    %
    tif_filenames = getfilenames(dirpath, [str_condition,'.tif']);
     h5_filenames = getfilenames(dirpath, [str_condition,'.h5']);
    %
    if isempty(tif_filenames)
        error('There are no tif files');
    end
end

function str_ex_name = get_ex_name(tif_filename)
    %s_filename = tif_filename;
    s_filename = strrep(tif_filename, '__', '_');    
    s_filename = strrep(tif_filename, '00', '');
    loc_space = strfind(s_filename, '.');
    
    % Get rid of '.tif' or '.h5'
    if isempty(loc_space)
        str_ex_name = s_filename;
    else
        str_ex_name = s_filename(1:(loc_space(end)-1));
    end
    
    % Ignore last file number
    %str_by_space = strsplit(str_ex_name, ' ');
    %str_ex_name = sprintf('%s ', str_by_space{1:end-1});
end

