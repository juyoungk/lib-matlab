function h5FileOpenForStimTrigger(g, h5_filename)
% g.ex_name should be defined in advance
    
    if nargin < 2
        h5_filename = g.h5_filename;
    end
    
    if isempty(h5_filename)
        disp('No h5 file.');
        return;
    end

    % h5 file: PD
    % PD recording filename: {i}
    if isempty(h5_filename)
        disp(['No corresponding h5 (e.g. photodiode) file for ', tif_filename]);
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
        g.h5_pd_raw = pd;
        
        % detect events in the trace
        g.pd_events_detect(pd, times);

        % Stimulus cluster for multiple events (using only events1)
        g.stims = cell(1,10);
        g.stims_ids = cell(1,10);

        % Num of stimulus (Assumed to be 1) 
        g.numStimulus = 1; 

        % plot pd trace and trigger events
        g.plot_pd;

    end   % if h5 file exists.

end