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
            
            % Imaging data [Scanimage TIF]
            n_channels = 4; % max channel #
            AI_chSave
            AI
            AI_mean  % mean up to 1000 frames
            ifi
            nframes  % per channel (e.g. PMT)
            header
            metadata % raw header file
            
            % Recording (pd & e-phys) data [WaveSurfer H5]
            h5_header
            h5_srate
            h5_AI
            h5_times
            
            % pd events info
            pd_AI_name = 'photodiode';
            pd_threshold1 = 0.85 % Major events
            pd_threshold2 = 0.60 % Minnor events
            min_interval_secs = 0.8
            ignore_secs = 2 % Skip some initial times for threshold detection.
            pd_trace
            
            % stimulus events
            pd_events1  % trigger times
            pd_events2  % trigger times
            stims      % 1~10 stimulus. Times [sec] for stim trigger events.
            stims_ids  % clustered pd event ids up to 10 groups.
            intervals  % if it's not empty, the stim was repeated. Probably good to average.
            stim_fliptimes  % trigger events or fliptimes. up to 10 differnet cell arrays
            stim_whitenoise        % whitenoise stim pattern
            
            % roi response data per stimulus
            numStimulus % and initialize roiDATA objects. Should be initialized at least 1.
            rr
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
                 s = sprintf('%s  (AI ch:%d, ScanZoom:%.1f)', t_filename, ch, g.header.scanZoomFactor);
            end
            
            function filename = getFigFileName(g, ch)
                s = getFigTitle(g,ch);
                filename = strrep(s, ' ', '_');
                filename = strrep(filename, '(', '_');
                filename = strrep(filename, ':', '');
            end
            
            function vol = imdrift(g, ch)
                % See if the cells were drift over imaging session
                % 1000 frames more case
                % Output vol: 2 frames. Before and After. Last available
                % channel.
                if nargin > 1
                    snapframes = 1000;
                    n = min(snapframes, g.nframes);
                    fprintf('Total frame numbers; %d. imdrift(): %d frames were compared. (Green-Magenta false color)\n', g.nframes, n);
 
                    AI_mean_early = mean(g.AI{ch}(:,:,(1:n)), 3);    
                    AI_mean_late  = mean(g.AI{ch}(:,:,(end-n+1:end)), 3);
                    %
                    figure('Color', 'none');
                    ax = axes('Position', [0  0  1  0.9524], 'Visible', 'off');
                    
                    imshowpair(myshow(AI_mean_early, 0.2), myshow(AI_mean_late, 0.2)); % contrast adjust by myshow()
                    title(ax, 'Is it drifted? (Green-Magenta)', 'FontSize', 15, 'Color', 'w');
                    print([g.getFigFileName(ch),'.png'], '-dpng', '-r300'); %high res
                    vol = cat(3, AI_mean_early, AI_mean_late);
                else
                    for PMT_ch=g.header.channelSave
                        if PMT_ch==4; continue; end;
                        vol = imdrift(g, PMT_ch);
                    end
                end
            end
            
            function img = imfuse(g, ch)
                % Create composite image
                % c_fraction: contrast saturation [%]
                A = g.AI_mean{4}; % background to gray
                B = g.AI_mean{1}; % red channel
                C = g.AI_mean{3}; % green channel
                %
                c_fraction = 2;
                Tol = [c_fraction*0.01 1-c_fraction*0.01];
                
                if nargin < 2
                    ch = g.roi_channel;
                end
                %
                if isempty(A)
                    img = []; 
                    return
                else
                    A = scaled(A);
                    MinMax = stretchlim(A, [0.001, 0.999]);
                    A = imadjust(A, MinMax);
                end
                
                % 
                if isempty(B)
                    B = zeros(size(A));
                else
                    B = scaled(B);
                    MinMax = stretchlim(B,Tol);
                    B = imadjust(B, MinMax);
                end
                %
                if isempty(C)
                    C = zeros(size(A));
                else
                    C = scaled(C);
                    MinMax = stretchlim(C, Tol);
                    C = imadjust(C, MinMax);
                end
                %
                if ch == 1
                    img = cat(3, max(A, B), A, A);
                elseif ch == 3
                    img = cat(3, A, max(A, C), A);
                else
                    img = cat(3, max(A, B), max(A, C), A);
                end
                imshow(img);
            end
            
            function myshow(g, ch)
                if nargin > 1
                    myshow(g.AI_mean{ch});
                else
                    for ch=g.header.channelSave
                        myshow(g.AI_mean{ch});
                    end
                end
            end
            
            function J = imvol(g, ch)
                if nargin < 2
                    ch = g.header.channelSave;
                end
                
                for i = ch
                    s_title = sprintf('%s  (AI Ch:%d, ScanZoom:%.1f)', g.ex_name, i, g.header.scanZoomFactor);
                    
                    if strfind(g.ex_name, 'stack')
                        J = imvol(g.AI{i}, 'title', s_title, 'scanZoom', g.header.scanZoomFactor, 'z_step_um', g.header.stackZStepSize);
                    else
                        if isempty(g.cc)
                            J = imvol(g.AI_mean{i}, 'title', s_title, 'scanZoom', g.header.scanZoomFactor);
                        else
                            disp('''cc'' was given to imvol().');
                            J = imvol(g.AI_mean{i}, 'title', s_title, 'scanZoom', g.header.scanZoomFactor, 'roi', g.cc, 'edit', true);
                        end
                    end
                end
            end
            
            function setting_pd_event_params(g)
                
                if strfind(g.ex_name, 'flash')
                    g.pd_threshold1 = 0.8;
                    g.min_interval_secs = 0.8;
                elseif strfind(g.ex_name, 'movingbar')
                    g.pd_threshold1 = 0.4;
                    g.min_interval_secs = 1.2;
                elseif strfind(g.ex_name, 'jitter')
                    g.pd_threshold1 = 0.4;
                    g.min_interval_secs = 1;
                elseif strfind(g.ex_name, 'whitenoise')
                    g.pd_threshold1 = 0.4;
                    g.min_interval_secs = 0.25;
                end
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
                % channel select
                if ~isempty(obj.roi_channel)
                    ch = obj.roi_channel;
                elseif obj.header.n_channelSave == 1
                    ch = obj.header.channelSave(1);
                    disp(['Ch# ',num2str(ch),' is selected for roi analysis']);
                else    
                    ch = input(['Imaging PMT channel # (Available: ', num2str(obj.header.channelSave),') ? ']);
                end
                obj.roi_channel = ch;
                obj.cc = cc;
                
                % create roiData object (as many as numStimulus? No. roiData will handle it.)
                % 1. extract roi traces, 2. split into numStimulus
                if ~isempty(cc)
                    disp(['Create roiData object for Ch#',num2str(obj.roi_channel),'...']);
                    r = roiData(obj.AI{ch}, cc, [obj.ex_name,' [ch',num2str(ch),']'], obj.ifi, {obj.pd_events1, obj.pd_events2}); %{ avg triggers, stim triggers }
                    r.header = obj.header;
                    obj.rr = r;
%                     if obj.numStimulus == 1
%                         obj.rr = r;
%                     elseif obj.numStimulus >1
%                         for i=1:obj.numStimulus
%                             % select the part of the roi traces using event
%                             % ids.
%                             obj.rr(i) = r.select_data( obj.stims_ids{i} );
% 
%                             %obj.rr(i) = roiData(obj.AI{ch}, cc, [obj.ex_name,' [ch',num2str(ch),']'], obj.ifi, obj.stims{i});
%                             %obj.rr(i).header = obj.header;
% 
%                             % ex specific executions 
%                             if strfind(obj.ex_name, 'whitenoise')
%                                 % update stim repo    
%                                 % import stimulus.h5
%                                     %load(filename,'-mat',variables) 
%                             else
% 
%                             end
%                         end
%                     end
                    
                else
                    disp('The given cc structure is empty. No roiDATA object was assigned.');
                end
            end
            
            function set.roi_channel(obj, ch)
                if ch >0 && ch <=obj.n_channels
                    obj.roi_channel = ch;
                else
                    error('Not available channel number for roi analysis');
                end
                % how to recalculate rr for new channel? reassign cc to
                % obj.cc
            end

            function g = gdata(tif_filename, h5_filename)
            % Construct input type1: single tif and single h5 (including path)
            % Construct input type2: single str input as filter in current directory
                pos = gdata.figure_setting();
                % cell array for AI channels.
                g.AI            = cell(g.n_channels, 1); % n_channels is defined at gdata properties.
                g.AI_mean       = cell(g.n_channels, 1);
                %g.AI_mean_slice = cell(g.n_channels, 1);

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
                    
                    % import Tif file
                    SI_data = ScanImageTiffReader(tif_filename);
                    g.metadata = SI_data.metadata;
                    g.ex_name = get_ex_name(g.tif_filename);
                    %
                    vol = SI_data.data; 

                    % Header file
                    h   = interpret_SI_header_from_TiffReader(g.metadata, size(vol));
                    g.header = h;
                    g.ifi = g.header.logFramePeriod;

                    % AI channel info
                    g.AI_chSave = h.channelSave;

                    % channel de-interleave and save sanpshots
                    n     = h.n_channelSave;
                    id_ch = mod((1:h.n_frames)-1, n)+1;

                    % loop over channels
                    for j=1:n
                        % de-interleave
                        ch = vol(:,:,id_ch==j); % de-interleave frames
                        g.AI{h.channelSave(j)} = ch;

                        % mean of first 1000 frames (for 512x512 pixels)
                        [row, col, ch_frames] = size(ch);
                        g.nframes = ch_frames;
                        n_frames_snap = min(ch_frames, round(512*512*1000/row/col));
                        ch_mean = mean(ch(:,:,1:n_frames_snap), 3);
                        g.AI_mean{h.channelSave(j)} = ch_mean;

                        % title name
                        t_filename = strrep(g.tif_filename, '_', '  ');
                        s_title = sprintf('%s  (AI ch:%d, ScanZoom:%.1f)', t_filename, h.channelSave(j), h.scanZoomFactor);

                        % plot mean images
                        hf = figure; 
                            %set(hf, 'Position', pos+[pos(3)*(j-1), -pos(4)*(1-1), 0, 0]);
                            imvol(ch_mean, 'hfig', hf, 'title', s_title, 'png', true, 'scanZoom', g.header.scanZoomFactor);
                    end

                    % h5 file: PD
                    % PD recording filename: {i}
                    if isempty(h5_filename)
                        disp([tif_filename,': No corresponding h5 (e.g. photodiode) file']);
                        g.numStimulus = 1; % default value for numStimulus.
                    else
                        % import data from h5 
                        [A, times, header] = load_analogscan_WaveSufer_h5(h5_filename);
                        g.h5_AI = A;
                        g.h5_times  = times;
                        g.h5_header = header;
                        g.h5_srate  = header.srate;
                        name_h5 = strsplit(h5_filename, '/');
                        g.h5_filename = name_h5{end};

                        % Infer 'photodiode' channel
                        numAI_Ch = numel(header.AIChannelNames);
                        if numAI_Ch == 1
                            pd = A;
                        else
                            PD_CH = find(strcmp(header.AIChannelNames, g.pd_AI_name));
                            if numel(PD_CH) > 1
                                disp(['More than 2 AI channels names ', g.pd_AI_name, '. First CH is selected for PD.']);
                                PD_CH = PD_CH(1);
                            end
                            pd = A(:,PD_CH); % raw pd trace including any unwanted events.
                        end
                        
                        %
                        pd = scaled(pd);
                        g.pd_trace = pd;

                        % event timestamps from pd
                        g.setting_pd_event_params();
                        i_start = g.ignore_secs * header.srate + 1; % First pd data point index for thresholding.
                        trace_for_events = pd(i_start:end);         % after skipping the first few seconds.
                        ev_idx = th_crossing(trace_for_events, g.pd_threshold1, g.min_interval_secs * header.srate);
                        ev_idx = ev_idx + i_start - 1;
                        ev = times(ev_idx);
                        g.pd_events1 = ev;
                        n_pd_events1 = numel(ev);
                        
                        % minnor events
                        ev_idx = th_crossing(trace_for_events, g.pd_threshold2, g.min_interval_secs * header.srate);
                        ev_idx = ev_idx + i_start - 1;
                        ev = times(ev_idx);
                        g.pd_events2 = ev;
                        n_pd_events2 = numel(ev);
                        
                        % Stimulus cluster for multiple events (using only events1)
                        g.stims = cell(1,10);
                        g.stims_ids = cell(1,10);
                            % count # of odd events

                        if n_pd_events1 <= 1
                            % one trigger time
                            g.stims{1} = ev;
                            g.numStimulus = 1;
                        elseif n_pd_events1 < 4
                            % Regard all different stimulus
                            for k=1:n_pd_events1
                                g.stims{k}     = ev(k);
                                g.stims_ids{k} = k;
                            end
                            g.numStimulus = n_pd_events1;
                        else
                            % n_events >= 4
                            % detect last event of the stimulus:
                            % increase in interval by 20 %
                            ev_interval = ev(2:end) - ev(1:end-1); % indicates the last event for stimulus
                            i_ev = 1;   % current   ev id
                               k = 0;   % current stim id
                            while i_ev < n_pd_events1
                                % new stim id
                                %i_ev;
                                k = k + 1;
                                % identify the next odd event
                                % relative index for next odd event
                                odd_events = find(ev_interval(i_ev:end) > ev_interval(i_ev)*1.2);

                                if isempty(odd_events)
                                    g.stims{k} = ev(i_ev:end);
                                    g.stims_ids{k} = i_ev:n_pd_events1;
                                    g.intervals{k} = ev_interval(i_ev);
                                    break;
                                end
                                t_ev = i_ev + odd_events(1) - 1;
                                g.stims{k} = ev(i_ev:t_ev);
                                g.stims_ids{k} = i_ev:t_ev;
                                g.intervals{k} = ev_interval(i_ev);
                                i_ev = t_ev + 1;
                            end
                            g.numStimulus = k;
                        end
                        
                        % plot pd trace and trigger events
                        g.pd_plot;
                        
                    end   % if h5 file exists.

                        % load cc struct if exist
                        cc_filenames = getfilenames(pwd, ['/*',ex_str,'*.mat']);
                        if ~isempty(cc_filenames)
                            commandwindow
                            reply = input(['Do you want to load ''',cc_filenames{1},''' for ROI analysis? Y/N [Y]: '],'s');
                            if isempty(reply); reply = 'Y'; end
                            if reply == 'Y'
                                S = load(cc_filenames{1});
                                % S should have a field name 'cc', 'c',
                                % 'c_note', 'roi_review'
                                if isfield(S, 'cc')
                                    g.cc = S.cc;
                                    disp('gData: ROI (cc) was defined. [roiDATA g.rr].');
                                end
                                if isfield(S, 'c')
                                    g.rr.load_c(S.c, S.c_note, S.roi_review);
                                    disp('gData: Cluster data was loaded for g.rr roiDATA.');
                                end
                            else
                                g.cc = [];
                            end
                        else
                            disp(['No .mat file for ''', ex_str, ''' (e.g. ''cc'' structure for ROI segmentation)']);
                            g.cc = []; % initialize cc struct
                        end

                        % drift?
                        before_after = g.imdrift;
                        % combined image for ROI segmentation.
                        imvol(mean(before_after, 3), 'title', 'first and last 2000 frames', 'scanZoom', g.header.scanZoomFactor);
                    end
                end

                function pd_plot(g)
                    pos = gdata.figure_setting();
                    n   = g.header.n_channelSave;
                    i_start = g.ignore_secs * g.h5_header.srate + 1; % first pd data point index for thresholding.
                    % plot pd % event stamps
                    pos_plot = [pos(1)+pos(3)*n, pos(2), pos(3), pos(3)*2./3.];
                    figure; set(gcf, 'Position', pos_plot);
                    plot(g.h5_times(i_start:end), g.pd_trace(i_start:end)); hold on; % PD trace
                    % PD trigger events 1
                    for ii = 1:g.numStimulus % color coding for clustered PD events.    
                        plot( g.pd_events1(g.stims_ids{ii}), g.pd_threshold1, 'o'); %g.pd_trace( ev_idx(g.stims_ids{ii})
                    end
                    % PD trigger events 2
                    for ii = 1:g.numStimulus % color coding for clustered PD events.    
                        plot( g.pd_events2, g.pd_threshold2, 'o'); %g.pd_trace( ev_idx(g.stims_ids{ii})
                    end
                    text = sprintf('Trigger Event 1: %d\nTrigger Event 2: %d', length(g.pd_events1), length(g.pd_events2));
                    legend(text, 'Location', 'southeast');
                    hold off
                    disp(text);
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
    %s_filename = strrep(tif_filename, '_', '  ');    
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