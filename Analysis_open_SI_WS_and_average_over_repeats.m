%% Routine for SI Tif (imaging) and WS H5 (pd) data
%
% Run section by section!
    dirpath = pwd;
    tif_filenames = getfilenames(dirpath, '/*.tif');
     h5_filenames = getfilenames(dirpath, '/*.h5');
    % list of files    
    tif_filenames{:}
    h5_filenames{:}
%% setting
    iptsetpref('ImshowInitialMagnification','fit');
    pos     = get(0, 'DefaultFigurePosition');
    pos_new = [0 950 800 800];
    set(0, 'DefaultFigurePosition', pos_new); 
%% Load recording files 
    dirpath = pwd;    
    % loc 1? ND2 filter. Noisy
    % loc 2
    ex_str = 'Loc5_1070'; % must start with numbers
    g = exp_struct_for_data_files(dirpath, ex_str, 'Exp', g);

%% (Optional) Stimulus trigger is correct?
    % check the trigger events of each stimulus during the recording.
    i_experiment = 1;
    ev = g.(ex_str)(i_experiment).stimulus.events;
    
    % How many stimulus did you have in the given file (i)?
    numStimulus = 2;
    s1_triggers = ev(1:10);
    s2_triggers = ev(11:14);
    %
        g.(ex_str)(i_experiment).stimulus.numStimulus = numStimulus;
        g.(ex_str)(i_experiment).stimulus.stim_triggers = cell(1, numStimulus);
        g.(ex_str)(i_experiment).stimulus.stim_triggers{1} = s1_triggers;
        g.(ex_str)(i_experiment).stimulus.stim_triggers{2} = s2_triggers;       
%% ROI selection
    i_file_for_ROI = 1;
    ch_save = 3;
    
    img_for_ROI = g.(ex_str)(i_file_for_ROI).AI_mean{ch_save};
    h = g.(ex_str)(i_file_for_ROI).header;
           n_ch = h.n_channelSave;
    %
    figure;
    roi_array = multiRoi(img_for_ROI);
    %
    saveas(gcf, [ex_str,'_',num2str(1),'_roi.png']);
    save([ex_str,'_',num2str(1),'_roi'], 'roi_array');

%% Given the ROIs, intensity over time for all sessions
    % CH selection for ROI trace plot
    % ch_save =1;
     smoothing_size = 6;
    % default position for figures
    pos_new = pos_new + [100 -pos_new(4) 0 0];
    set(0, 'DefaultFigurePosition', pos_new); 
     
    % Select a fraction of ROI ?
    roi_selected = roi_array(:,:,1:end);
    [~, ~, n_roi] = size(roi_selected);
    
    n_experiments = numel(g.(ex_str));
    
    for i_ex = 1:n_experiments
        % Experiment (or recording) parameters
            h = g.(ex_str)(i_ex).header;
            n_ch = numel(g.(ex_str)(i_ex).AI);
            ifi = h.scanFramePeriod;
            f_times = (1:h.n_frames_ch)*ifi; % frame times
            ev = g.(ex_str)(i_ex).stimulus.events;
            interval = g.(ex_str)(i_ex).stimulus.inter_events;

        % Mean value over ROI
        roi_mean = roi_avg_output(g.(ex_str)(i_ex).AI, roi_selected);

        % Smoothing over time for all channels.
        roi_smoothed = cell(1, n_ch);
        for ch = 1:n_ch
            roi_smoothed{ch} = zeros(n_roi, h.n_frames_ch);
            for i = 1:n_roi        
                if ~isempty(roi_mean{i,ch})
                    %roi_smoothed{ch}(i,:) = smoothdata(roi_mean{i,ch}, 'sgolay', smoothing_size);
                    roi_smoothed{ch}(i,:) = smoothdata(roi_mean{i,ch}, 'movmean', smoothing_size);
                end
            end
        end

        % plot
            figure;
            for ch = ch_save            
                    plot(f_times, roi_smoothed{ch}); hold on
                    xlabel('sec'); ylabel('fluorescence (a.u.)');
                        ax = gca; Fontsize = 18;
                        ax.XAxis.FontSize = Fontsize;
                        ax.YAxis.FontSize = Fontsize;
                        ax.XLim = [0 f_times(end)];
            end
            % event timestamps
            for i=1:length(ev)
                plot([ev(i) ev(i)], ax.YLim, '-', 'LineWidth', 1.0, 'Color',0.6*[1 1 1]);
                plot([ev(i)+interval/2, ev(i)+interval/2], ax.YLim, '--', 'LineWidth', 1.0, 'Color',0.4*[1 1 1]);
            end
            hold off
            saveas(gcf, [ex_str,'_',num2str(i_ex),'_ROI.png']);

        % Average over repeats (only for ch_save)
        numStimulus = g.(ex_str)(i_ex).stimulus.numStimulus;
        for k=1:numStimulus
            ev = g.(ex_str)(i_ex).stimulus.stim_triggers{k};
            [roi_aligned, s_times] = align_analog_signal_to_events(roi_smoothed{ch_save}, f_times, ev, interval);
            %
            figure;
            avg_response = mean(roi_aligned, 3);
            plot(s_times, avg_response.'); 
            hold on;
                    xlabel('sec'); ylabel('fluorescence (a.u.)');
                    ax = gca; Fontsize = 18;
                    ax.XAxis.FontSize = Fontsize;
                    ax.YAxis.FontSize = Fontsize;
                    ax.XLim = [0 interval];
                    title('Mean responses of ROIs','FontSize',18);   
                    % legend
                    S = sprintf('ROI %d*', 1:n_roi); C = regexp(S, '*', 'split'); % C is cell array.
                    %ax_legend = legend(C{1:(end-1)}); ax_legend.FontSize = 12;
                    %
            plot([interval/2 interval/2], ax.YLim, '--', 'LineWidth', 1.0, 'Color',0.6*[1 1 1]);
            annotation('textbox',[.8,.8,.3,.3],'String',g.(ex_str)(i_ex).tif_filename,'FitBoxToText','on');
            hold off;
            %
            saveas(gcf, [ex_str,'_',num2str(i_ex),'_stim_',num2str(k),'_ROI_mean__smoothging',num2str(smoothing_size),'.png']);
        end
    end


%% (optional) Smooth the movie
    ch_save = 1;
    % smooth the multiframe data?
    % reshape and smooth and then reshape back
    vol = g.(ex_str)(i_experiment).AI{ch_save};
    [rows, cols, n_frames_ch] = size(vol);
    %
    revol = reshape(vol, [], n_frames_ch);
    % smooth along the dimention 2
    revol_smoothed = smoothdata(revol, 2, 'sgolay',12);
      revol_scaled = scaled(revol_smoothed);

    % calculate contrast range in reshaed data after normalization.
    MinMax = stretchlim(revol_scaled, 0.03); 
    vol_smoothed_scaled = reshape(revol_scaled, rows, cols, n_frames_ch);
    implay_MinMax(vol_smoothed_scaled, MinMax)

