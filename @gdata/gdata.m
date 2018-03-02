classdef gdata < handle
    % class for single experiment session.
    % single TIF file or multiple TIFs if there are logged into mutiple
    % files. Confine the filenames using long string.
    % Assumptions for AI channels:
    %                   channel number - 4
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
            header
            metadata % raw header file
            
            % Recording (pd & e-phys) data [h5 wavesurfer]
            h5_header
            h5_srate
            h5_AI
            h5_times
            
            % pd events info
            pd_AI_name = 'photodiode';
            pd_threshold = 0.8;
            min_interval_secs = 0.5;
            pd_trace
            pd_events
            
            % stimulus events
            stim_fliptimes  % trigger events or fliptimes. up to 10 differnet cell arrays
            stim_whitenoise        % whitenoise stim pattern
            stims      % stim event times 
            intervals  % if it's not empty, the stim was repeated. Probably good to average.
            
            % roi response data per stimulus
            numStimulus % and initialize roiDATA objects. Should be initialized at least 1.
            rr
            cc          % ROI connectivity structure
            roi_channel
    end   

    methods
            function show(g, ch)
                if nargin > 1
                    imvol(g.AI_mean{ch});
                else
                    for ch=1:obj.header.channelSave
                        imvol(g.AI_mean{ch});
                    end
                end
            end
        
            function set.numStimulus(obj, n)
                if n <1
                    error('numStimulus should be 1 or larger');
                end
                % (re)-initialize array of roiDATA
                r(1, n) = roiData;
                obj.rr = r;
                obj.numStimulus = n;
            end

            function set.cc(obj, cc)
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
                % compute roiData objects
                if ~isempty(cc)
                    for i=1:obj.numStimulus
                        obj.rr(i) = roiData(obj.AI{ch}, cc, [obj.ex_name,'_ch',num2str(ch)], obj.header.logFramePeriod, obj.stims{i});
                    end
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
                    end
                    name_tif = strsplit(tif_filename, '/');
                    g.tif_filename = name_tif{end};
                    
                    % import h5 file
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
                    g.AI            = cell(g.n_channels, 1);
                    g.AI_mean       = cell(g.n_channels, 1);
                    %g.AI_mean_slice = cell(g.n_channels, 1);

                    % channel de-interleave and save sanpshots
                    n     = h.n_channelSave;
                    id_ch = mod((1:h.n_frames)-1, n)+1;

                    % loop over channels
                    for j=1:n
                        % de-interleave
                        ch = vol(:,:,id_ch==j); % de-interleave frames
                        g.AI{h.channelSave(j)} = ch;

                        % mean of first 1000 frames
                        [~, ~, ch_frames] = size(ch);
                        n_snapshot = min(ch_frames, 1000);
                        ch_mean = mean(ch(:,:,1:n_snapshot), 3);
                        g.AI_mean{h.channelSave(j)} = ch_mean;

                        % title name
                        t_filename = strrep(g.tif_filename, '_', '  ');
                        s_title = sprintf('%s  (AI ch:%d, ScanZoom:%.1f)', t_filename, h.channelSave(j), h.scanZoomFactor);

                        % plot mean images
                        hf = figure; 
                            %set(hf, 'Position', pos+[pos(3)*(j-1), -pos(4)*(1-1), 0, 0]);
                            imvol(ch_mean, 'hfig', hf, 'title', s_title, 'png', true);
                            %saveas(gcf, [str,'_ex',num2str(i),'_ch', num2str(h.channelSave(j)),'.png']);
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
                            pd = A(:,PD_CH);
                        end 
                        %
                        pd = scaled(pd);
                        g.pd_trace = pd;

                        %
                        pos_plot = [pos(1)+pos(3)*n, pos(2), pos(3), pos(3)*2./3.];
                        figure; set(gcf, 'Position', pos_plot);
                            plot(times,pd); hold on; % it is good to plot pd siganl together
                            % event timestamps
                            ev_idx = th_crossing(pd, g.pd_threshold, g.min_interval_secs * header.srate);
                            ev = times(ev_idx);
                            plot(ev, pd(ev_idx),'bo');
                                legend(['Num of events: ', num2str(length(ev_idx))],'Location','southeast');
                            hold off
                        g.pd_events = ev;
                        n_events = numel(ev);

                        % stimulus cluster for multiple events 
                        g.stims = cell(1,10);
                            % count # of odd events

                        if n_events <= 1
                            % one stimulus
                            g.stims{1} = ev;
                            g.numStimulus = 1;
                        elseif n_events < 5
                            % Regard all different stimulus
                            for k=1:n_events
                                g.stims{k} = ev(k);
                            end
                            g.numStimulus = n_events;
                        else
                            % n_events >= 5
                            % detect last event of the stimulus:
                            % increase in interval by 20 %
                            ev_interval = ev(2:end) - ev(1:end-1); % indicates the last event for stimulus
                            i_ev = 1;   % current   ev id
                               k = 0;   % current stim id
                            while i_ev < n_events
                                % new stim id
                                %i_ev;
                                k = k + 1;
                                % identify the next odd event
                                % relative index for next odd event
                                odd_events = find(ev_interval(i_ev:end) > ev_interval(i_ev)*1.2);

                                if isempty(odd_events)
                                    g.stims{k} = ev(i_ev:end);
                                    g.intervals{k} = ev_interval(i_ev);
                                    break;
                                end
                                t_ev = i_ev + odd_events(1) - 1;
                                g.stims{k} = ev(i_ev:t_ev);
                                g.intervals{k} = ev_interval(i_ev);
                                i_ev = t_ev + 1;
                            end
                            g.numStimulus = k;
                        end
                    end   % if h5 file exists.

                    end
                end

                % function: callbacks
                % function: roi
        end
        
    methods(Static)
        function pos_new = figure_setting()
            iptsetpref('ImshowInitialMagnification','fit');
            pos     = get(0, 'DefaultFigurePosition');
            width = 745;
            %pos_new = [10 950 width width*1.05];
            pos_new = [210 600 width width*1.05];
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
    s_filename = strrep(tif_filename, '_', '  ');    
    s_filename = strrep(s_filename, '00', '');
    loc_name = strfind(s_filename, '.');
    str_ex_name = s_filename(1:loc_name-1);
end
