function g = exp_struct_for_data_files(dirpath, str, varargin) 
    
    str_condition = ['/*',str,'*'];
    %
    tif_filenames = getfilenames(dirpath, [str_condition,'.tif'])
     h5_filenames = getfilenames(dirpath, [str_condition,'.h5'])
    % 
    g = [];
    
    for i=1:numel(tif_filenames)
        g.(str)(i).tif_filename = tif_filenames{i}; 
        g.(str)(i).PD_h5_filename = [dirpath,'/',h5_filenames{i}]; 
        
        % Tif imaging data loading
        SI_data = ScanImageTiffReader([dirpath,'/',g.(str)(i).tif_filename]);
        h = SI_data.metadata;
        h = interpret_SI_header_from_TiffReader(h);
        vol = SI_data.data;      
        
        % de-interleave into channels
        [rows, cols, n_frames] = size(vol);
        n = h.n_channelSave;
        h.n_frames = n_frames;
        h.n_frames_ch = n_frames/n;
        id_ch = mod((1:n_frames)-1, n)+1;
        
        g.(str)(i).header = h;
        % analog inputs (Assume max 4 channels)
        n_channels = 4;
        g.(str)(i).AI      = cell(n_channels, 1);
        g.(str)(i).AI_mean = cell(n_channels, 1);
        
        for j=1:n
            ch = vol(:,:,id_ch==j); % Analog input
            ch_mean = mean(ch, 3);
            g.(str)(i).AI{h.channelSave(j)} = ch;
            g.(str)(i).AI_mean{h.channelSave(j)} = ch_mean;
            figure; 
            imshow(ch_mean);
        end

        % PD data loading
        [pd, times, header] = load_analogscan_WaveSufer_h5(g.(str)(i).PD_h5_filename);
        srate = header.Acquisition.SampleRate;
        pd = scaled(pd);
        %
        g.(str)(i).pd = pd;
        g.(str)(i).pd_times = times;
        g.(str)(i).pd_header = header;
        g.(str)(i).pd_srate = srate;
        %
        figure; 
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