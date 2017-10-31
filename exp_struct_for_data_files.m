function g = exp_struct_for_data_files(dirpath, str, varargin) 
    
    p = ParseInput(varargin{:});
    g = p.Results.Exp;
    pos = get(0, 'DefaultFigurePosition');
    
    str_condition = ['/*',str,'*'];
    %
    tif_filenames = getfilenames(dirpath, [str_condition,'.tif'])
     h5_filenames = getfilenames(dirpath, [str_condition,'.h5'])
    % 
    if isempty(tif_filenames)
        error('There is no tif files');
    end
    %
    
    for i=1:numel(tif_filenames)
        g.(str)(i).tif_filename = tif_filenames{i};
        if isempty(h5_filenames)
            g.(str)(i).PD_h5_filename = [];
        else
            g.(str)(i).PD_h5_filename = [dirpath,'/',h5_filenames{i}]; 
        end
        
        % Tif imaging data loading
        SI_data = ScanImageTiffReader([dirpath,'/',g.(str)(i).tif_filename]);
        h = SI_data.metadata;
        h = interpret_SI_header_from_TiffReader(h);
        vol = SI_data.data;      
        
        % channel info
        [rows, cols, n_frames] = size(vol);
        n = h.n_channelSave;
        h.n_frames = n_frames;
        h.n_frames_ch = n_frames/n;
        id_ch = mod((1:n_frames)-1, n)+1;
        
        g.(str)(i).header = h;
        % analog inputs (Assume max 4 channels)
        n_channels = 4;
        g.(str)(i).AI_chSave = h.channelSave;
        g.(str)(i).AI      = cell(n_channels, 1);
        g.(str)(i).AI_mean = cell(n_channels, 1);
        
        for j=1:n
            % de-interleave into channels
            ch = vol(:,:,id_ch==j); % de-interleave frames
            ch_mean = mean(ch, 3);
            g.(str)(i).AI{h.channelSave(j)} = ch;
            g.(str)(i).AI_mean{h.channelSave(j)} = ch_mean;
            % plot mean images
            hf = figure; set(hf, 'Position', pos+[pos(3)*(j-1), -pos(4)*(i-1), 0, 0]);
            myshow(ch_mean, 0.05);
            t_filename = strrep(tif_filenames{i}, '_', '  ');
            s_title = sprintf('%s (Ch: %d)', t_filename, h.channelSave(j));
            title(s_title);
            makeFigBlack(hf);
            saveas(gcf, [str,'_ex',num2str(i),'_ch', num2str(h.channelSave(j)),'.png']);
        end
        
        % Merge if there are multiple channels.
%         switch n
%             case 2
%                 C = merge(g.(str)(i).AI_mean{h.channelSave(1)}, g.(str)(i).AI_mean{h.channelSave(2)});
%                 figure; imshow(C); title([tif_filenames{i},': 2 CH Merged']);
%             otherwise
%         end
        
        % PD data loading
        if ~isempty(g.(str)(i).PD_h5_filename)
            [pd, times, header] = load_analogscan_WaveSufer_h5(g.(str)(i).PD_h5_filename);
            srate = header.Acquisition.SampleRate;
            pd = scaled(pd);
            %
            g.(str)(i).pd = pd;
            g.(str)(i).pd_times = times;
            g.(str)(i).pd_header = header;
            g.(str)(i).pd_srate = srate;
            %
            figure; set(gcf, 'Position', pos+[pos(3)*n, -pos(4)*(i-1), 0, 0]);
                plot(times,pd); hold on; % it is good to plot pd siganl together
                % event timestamps
                pd_threshold = 0.9;
                min_ev_interval_secs = 2.5;
                ev_idx = th_crossing(pd, pd_threshold, min_ev_interval_secs*srate);

                plot(times(ev_idx),pd(ev_idx),'bo');
                    legend(['Num of events: ', num2str(length(ev_idx))],'Location','southeast');
                hold off
            %    
            ev = times(ev_idx);

            % events info & stimulus info
            g.(str)(i).stimulus.events = ev;
            g.(str)(i).stimulus.n_events = numel(ev);
            g.(str)(i).stimulus.inter_events = ev(2)-ev(1) %secs
            g.(str)(i).stimulus.numStimulus = 1;
            g.(str)(i).stimulus.stim_triggers = cell(1,1);
            g.(str)(i).stimulus.stim_triggers{1} = ev;
        end
        
    end
    
end

function p =  ParseInput(varargin)
    
    p  = inputParser;   % Create an instance of the inputParser class.
    
    addParamValue(p,'Exp', []);
    
%     addParamValue(p,'barWidth', 100, @(x)x>=0);
%     addParamValue(p,'barSpeed', 1.4, @(x)x>=0);
%     addParamValue(p,'barColor', 'dark', @(x) strcmp(x,'dark') || ...
%         strcmp(x,'white'));
%      
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end