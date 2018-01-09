function g = exp_struct_for_data_files(dirpath, str, varargin) 
    
    p = ParseInput(varargin{:});
    g = p.Results.Exp;
    pos = get(0, 'DefaultFigurePosition');
    
    str_condition = ['/*',str,'*'];
    %
    tif_filenames = getfilenames(dirpath, [str_condition,'.tif'])
     h5_filenames = getfilenames(dirpath, [str_condition,'.h5']);
    %
    if isempty(tif_filenames)
        error('There is no tif files');
    end
    % valid field name
    str = strrep(str, '-', '_');
    
    % routine for tif imaging data
    for i=1:numel(tif_filenames)
        g.(str)(i).tif_filename = tif_filenames{i};
        
        % PD recording filename
        if isempty(h5_filenames)
        %if isempty(h5_filenames{i})
            g.(str)(i).PD_h5_filename = [];
            disp([tif_filenames{i},': No corresponding h5 (e.g. photodiode) file']);
        elseif isempty(h5_filenames{i})
            g.(str)(i).PD_h5_filename = [];
            disp([tif_filenames{i},': No corresponding h5 (e.g. photodiode) file']);
            %disp('No corresponding h5 (e.g. photodiode) file');
        else
            g.(str)(i).PD_h5_filename = [dirpath,'/',h5_filenames{i}]; 
        end

        % Tif data loading
        SI_data = ScanImageTiffReader([dirpath,'/',g.(str)(i).tif_filename]);
        h = SI_data.metadata;
        g.(str)(i).metadata = h;
        
        %
        h   = interpret_SI_header_from_TiffReader(h);
        vol = SI_data.data;      
        
        % AI channel info
        [rows, cols, n_frames] = size(vol);
        n = h.n_channelSave;
%         if n == 0
%             n = 1; % default channel number is 1
%         end
        h.n_frames = n_frames;
        h.n_frames_ch = n_frames/n;
%         if isempty(h.numSlices) 
%             h.numSlices = 1;
%         elseif h.numSlices < 1 
%             h.numSlices = 1;
%         end
        h.n_frames_ch_slice = h.n_frames_ch/h.numSlices;    
        id_ch = mod((1:n_frames)-1, n)+1;
    
        % analog inputs (Assume max 4 channels)
        n_channels = 4;
        g.(str)(i).AI_chSave = h.channelSave;
        g.(str)(i).AI      = cell(n_channels, 1);
        g.(str)(i).AI_mean = cell(n_channels, 1);
        g.(str)(i).AI_mean_slice = cell(n_channels, 1);
        g.(str)(i).header = h;
        
        % de-interleave and plot mean images
        for j=1:n
            ch = vol(:,:,id_ch==j); % de-interleave frames
            ch_mean = mean(ch, 3);
            g.(str)(i).AI{h.channelSave(j)} = ch;
            g.(str)(i).AI_mean{h.channelSave(j)} = ch_mean;
            % title name
            t_filename = strrep(tif_filenames{i}, '_', '  ');
            s_title = sprintf('%s  (PMT Ch:%d, ScanZoom:%.1f)', t_filename, h.channelSave(j), h.scanZoomFactor);
            % plot mean images
            hf = figure; 
                set(hf, 'Position', pos+[pos(3)*(j-1), -pos(4)*(i-1), 0, 0]);
                imvol(ch_mean, 'hfig', hf, 'title', s_title, 'png', true);
                %saveas(gcf, [str,'_ex',num2str(i),'_ch', num2str(h.channelSave(j)),'.png']);
                
            %if contains(str, 'stack')
            if h.numSlices > 1
                fprintf('numSlice: %d\n', h.numSlices); % print number of slices 
                % open the whole stack after averaging frames for a given slice.
                hf = figure; 
                set(hf, 'Position', pos+[pos(3)*(j-1 +3), -pos(4)*(i-1), 0, 0]); % shift by 3
                % resize into 4D for averaging over slices.
                ch_slice_4d = reshape(ch, rows, cols, h.n_frames_ch_slice, h.numSlices);
                ch_slice_avg = mean(ch_slice_4d, 3);
                ch_slice_avg = squeeze(ch_slice_avg);
                g.(str)(i).AI_mean_slice{h.channelSave(j)} = ch_slice_avg;
                % stack images
                if h.channelSave(j) == 4
                    % skip channel 4 since it is an IR scattering image.
                    disp('Imshow for Ch 4 stack was skipped. Please inspect separately if you are interested'); 
                else
                    imvol(ch_slice_avg, 'hfig', hf, 'title', ['STACK: ',s_title]);
                end
            end
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
            pos_plot = [pos(1)+pos(3)*n, pos(2)-pos(4)*(i-1), pos(3), pos(3)*2./3.];
            figure; set(gcf, 'Position', pos_plot);
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
            if numel(ev) >2
                g.(str)(i).stimulus.inter_events = ev(2)-ev(1); %secs
            else
                g.(str)(i).stimulus.inter_events = [];
            end
            g.(str)(i).stimulus.numStimulus = 1; % Default assumption
            g.(str)(i).stimulus.stim_triggers = cell(1,1);
            g.(str)(i).stimulus.stim_triggers{1} = ev;
        end
        figure(hf); % Give focus back to one of the image figure.
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