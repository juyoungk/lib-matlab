%% Routine for SI Tif (imaging) and WS H5 (pd) data
% python env
    setenv('PATH', '/Users/peterfish/Modules/miniconda2/bin:/Users/peterfish/Modules/miniconda2/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/git/bin');
%% 'g' struct initialization
    g = [];
    
%% Run section by section!
    dirpath = pwd;
    tif_filenames = getfilenames(dirpath, '/*.tif'); tif_filenames{:};
     h5_filenames = getfilenames(dirpath, '/*.h5'); h5_filenames{:};
%% PLot & Figure setting
    iptsetpref('ImshowInitialMagnification','fit');
    pos     = get(0, 'DefaultFigurePosition');
    width = 545;
    %pos_new = [10 950 width width*1.05];
    pos_new = [210 600 width width*1.05];
    set(0, 'DefaultFigurePosition', pos_new);
%% Load ScanImage Tif files 
    ex_str = 'Loc2_flash_center'; % must start with characters
    g = exp_struct_for_data_files(pwd, ex_str, 'Exp', g);
    % save ROI 'cc'?
%% Open h5 WaveSurfer recording files
    dirpath = pwd;
    pos_new = [0 950 1200 900]; set(0, 'DefaultFigurePosition', pos_new);
    ex_str = 'cell3'; %
    g = exp_struct_for_h5_files(dirpath, ex_str, 'Exp', g);
%% convert cc to bwmask
    %average over roi? Use roi_trace with input 'cc' 
%% (Optional) Events: multiple experiments?
    % check the trigger events of each stimulus during the recording.
    i_experiment = 1;
    ev = g.(ex_str)(i_experiment).stimulus.events;
    % How many stimulus did you have in the given file (i)?
    numStimulus = 1;
    s1_triggers = ev(1:10);
    s2_triggers = [];
    %s2_triggers = ev(11:16);
    %
        g.(ex_str)(i_experiment).stimulus.numStimulus = numStimulus;
        g.(ex_str)(i_experiment).stimulus.stim_triggers = cell(1, numStimulus);
        g.(ex_str)(i_experiment).stimulus.stim_triggers{1} = s1_triggers;
        g.(ex_str)(i_experiment).stimulus.stim_triggers{2} = s2_triggers;       
%% ROI selection
    i_file_for_ROI = 1;
    ch_save = 1;
    %
    img_for_ROI = g.(ex_str)(i_file_for_ROI).AI_mean{ch_save};
       %h = g.(ex_str)(i_file_for_ROI).header;
    %
    figure; hfig = gcf;
    hfig.Color = 'none';
    hfig.PaperPositionMode = 'auto';
    hfig.InvertHardcopy = 'off';
    axes('Position', [0  0  1  0.9524], 'Visible', 'off');
    %
    roi_array = multiRoi(img_for_ROI);
    s_title = [,'ROI selection : ', strrep(ex_str,'_','  '),' exp',num2str(i_file_for_ROI),' ch',num2str(ch_save)];
    title(s_title, 'FontSize', 17, 'Color', 'w');
    % Save ROI in 'g' structure
    n_experiments = numel(g.(ex_str));
    for i = 1:n_experiments
        g.(ex_str)(i).roi = roi_array;
    end
    %
    saveas(gcf, [ex_str,'_exp',num2str(i_file_for_ROI),'_Ch',num2str(ch_save),'_roi.png']);
    save([ex_str,'_exp',num2str(i_file_for_ROI),'_Ch',num2str(ch_save),'_roi'], 'roi_array');
%% (Optional) Specity ex info for ROI analysis
    ex_str = 'Loc1_moving';
    ch_save =3; % or array such as [1, 3]
    i_ex = 1;
    img_for_ROI = g.(ex_str)(i_ex).AI_mean{ch_save};
    %imvol(img_for_ROI);
%% (Optioanl) Load ROI array from 'g' or from saved file
    % ex_str = ;
    roi_array = g.(ex_str)(i_file_for_ROI).roi;

%% (Optional) Add more ROIs?
    roi_array = multiRoi(img_for_ROI, roi_array);
    
%% (Optioanl) Check whether correct roi array was imported. 
    roi_tot = sum(roi_array, 3) > 0; % total roi? sum over dim 3 
    C = merge(img_for_ROI, roi_tot);
    figure; imshow(C);
%% (Optional) Reset figure location
    pos_new = pos_new + [100 -pos_new(4) 0 0];
    set(0, 'DefaultFigurePosition', pos_new); 
%% Given the ROIs, avg response over repeats for all sessions
    ch_save = 3; % or array (e.g. [1, 3])    
    % 'cc': created whenever ROI is assigned in currnet figure. 
    n_roi = cc.NumObjects;
    n_ex = numel(g.(ex_str));
    i_ex_repeats = 1:n_ex; % choose ex id for repeat analysis
    % roi_array = conn_to_bwmask(cc);
    smoothing_size = 2;
    smoothing_method = 'movmean'; % or 'sgolay'
    n_col_subplot = 3; % raw trace plot
    
    for i_ex = i_ex_repeats
        % Experiment (or recording) parameters
        s_filename = strrep(g.(ex_str)(i_ex).tif_filename, '_', '  ');    
        s_filename = strrep(s_filename, '00', '');
        loc_name = strfind(s_filename, '.');
        s_ex_name = s_filename(1:loc_name-1);
        S = sprintf('ROI %d*', 1:n_roi); C = regexp(S, '*', 'split'); % C is cell array.
        h = g.(ex_str)(i_ex).header;
            n_ch = numel(g.(ex_str)(i_ex).AI);
            ifi = h.scanFramePeriod;
            f_times = (1:h.n_frames_ch)*ifi; % frame times
            ev = g.(ex_str)(i_ex).stimulus.events;
            interval = g.(ex_str)(i_ex).stimulus.inter_events;
            
        % exp info str    
        frate = g.(ex_str)(i_ex).header.scanFramePeriod;
        str_smooth_info = sprintf('smooth size %d (~%.0f ms bin)', smoothing_size, frate*smoothing_size*1000);
        str_events_info = sprintf('ev interval: %.1fs', interval); 
        str_info = sprintf('%s\n%s', str_events_info, str_smooth_info);

        % Mean value over ROI
        %roi_mean = roi_avg_output(g.(ex_str)(i_ex).AI, roi_selected); % 2-D cell array: {roi#, ch#}
        roi_mean = roi_trace(g.(ex_str)(i_ex).AI, cc); % 2-D cell array: {roi#, ch#}

        % Smoothing (or Model-based inferring..)
        roi_smoothed = cell(1, n_ch);
        for ch = 1:n_ch
            roi_smoothed{ch} = zeros(n_roi, h.n_frames_ch);
            for i = 1:n_roi        
                if ~isempty(roi_mean{i,ch})
                    roi_smoothed{ch}(i,:) = smoothdata(roi_mean{i, ch}, smoothing_method, smoothing_size);
                end
            end
        end
          
        % Plot individual traces
        for ch = ch_save
            figure('Position', [pos_new(1), 100, pos_new(3)*2.4, pos_new(4)*2]);
            axes('Position', [0  0  1  0.9524], 'Visible', 'off');
            title(s_filename);
            y = roi_smoothed{ch};

            n_row = ceil(n_roi/n_col_subplot); % 2 columns
            for rr = 1:n_roi % loop over rois
                [ii, jj] = ind2sub([n_row, n_col_subplot], rr);
                id_subplot = sub2ind([n_col_subplot, n_row], jj, ii);

                subplot(n_row, ceil(n_roi/n_row), id_subplot);

                plot(f_times, y(rr,:), 'LineWidth', 1.5); hold on
                ylabel('a.u.');
                axis auto;
                ax = gca; Fontsize = 10;
                ax.XAxis.FontSize = Fontsize;
                ax.YAxis.FontSize = Fontsize;
                ax.XLim = [0 f_times(end)];
                %ax.XLim = [0 ev(10)];
                %ax.XTickLabel = []; 
                text(ax.XLim(end), ax.YLim(end), C{rr}, 'FontSize', 8, 'Color', 'k', ...
                        'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
                for i=1:length(ev)
                    plot([ev(i) ev(i)], ax.YLim, '-', 'LineWidth', 1.1, 'Color',0.6*[1 1 1]);
                    plot([ev(i)+interval/2, ev(i)+interval/2], ax.YLim, ':', 'LineWidth', 1.0, 'Color',0.5*[1 1 1]);
                end   
                hold off

                % bottom-most subplot: x label
                if any([rem(rr,n_row)==0, rr == n_roi])
                    ax.XTickLabel = linspace(ax.XTick(1),ax.XTick(end),numel(ax.XTick));
                    xlabel('sec');
                end

            end
            % Text comment on final subplot
            subplot(n_row, n_col_subplot, n_row*n_col_subplot);
            ax = gca; axis off;
            text(ax.XLim(end), ax.YLim(1), str_smooth_info, 'FontSize', 11, 'Color', 'k', ...
                        'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
            text(ax.XLim(end), ax.YLim(1), ['exp: ',s_ex_name], 'FontSize', 11, 'Color', 'k', ...
                        'VerticalAlignment', 'top', 'HorizontalAlignment','right');
            %makeFigBlack;
            saveas(gcf, [ex_str,'_ex',num2str(i_ex),'_stims_ROI_traces.png']);
        end

        % Average over stim repeats (only for ch_save)
        numStimulus = g.(ex_str)(i_ex).stimulus.numStimulus;
        for k=1:numStimulus
            ev = g.(ex_str)(i_ex).stimulus.stim_triggers{k};
            % Align roi-avg data relative to ev timestamps
            [roi_aligned, s_times] = align_analog_signal_to_events(roi_smoothed{ch_save}, f_times, ev, interval);
            s_ex_stim_name = [s_ex_name, ' stim', num2str(k)];
            % Avg over repeats (dim 3)
            avg_response = mean(roi_aligned, 3); 
            avg_response = avg_response.';
            x_text = mean(s_times);
              
            % Tiled Figure
            figure('Position', [pos_new(1)+50, 150, pos_new(3)*2, pos_new(4)*1.5]);
            title(s_filename);
            % double times in case for drawing 2 periods
            s_times = [s_times, s_times + interval];
            for rr = 1:n_roi % loop over ROIs
                n_row = 4;
                n_col = ceil(n_roi/n_row);
                subplot(n_row, n_col, rr);
               
                % 0. non-smoothed raw data plot
                    y = roi_mean{rr, ch};
                    [y, x_times] = align_analog_signal_to_events(y, f_times, ev, interval);
                    y = squeeze(y);
                    y = mean(y, 2);
                    % variance between raw data?
                    %
                    %%plot(x_times, y,'LineWidth', 0.2, 'Color', 0.1*[1 1 1]); hold on
                % 1. smoothed data
                    y = avg_response(:,rr);
                    y = [y; y];
                    t_shift = 0.5;
                    
                    plot(s_times, y, 'LineWidth', 1.5, 'Color', [0 0.4470 0.7410]); hold on % default color
                    %xlabel('sec'); ylabel('a.u.');
                    axis on;
                    ax = gca; Fontsize = 10;
                    ax.XAxis.FontSize = Fontsize;
                    ax.YAxis.FontSize = Fontsize;
                    if strfind(g.(ex_str)(i_ex).tif_filename, 'flash')
                        ax.XLim = [0 2*interval];
                        ax.XTick = 0:(interval/2):(2*interval);
                    else % moving bar?
                        ax.XLim = [0 interval];
                        ax.XTick = [];
                    end
                    xtickformat('%.0f');     
                    text(ax.XLim(end), ax.YLim(1), C{rr}, 'FontSize', 9, 'Color', 'k', ...
                        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
                % Additional line for On-Off transition.
                plot([0 0], ax.YLim, 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
                plot([interval, interval], ax.YLim, 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
                plot([interval*0.5, interval*0.5], ax.YLim, '--', 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]);
                plot([interval*1.5, interval*1.5], ax.YLim, '--', 'LineWidth', 1.0, 'Color', 0.5*[1 1 1]); hold off
                
                % bottom-most subplot: x label
                if any([rr == n_roi])
                    xlabel('sec');
                end
                
            end
            % Text comment on final subplot
            subplot(n_row, ceil(n_roi/n_row), n_row*ceil(n_roi/n_row));
            ax = gca; axis off;
%             text(ax.XLim(end), ax.YLim(1), str_events_info, 'FontSize', 14, 'Color', 'k', ...
%                         'VerticalAlignment', 'bottom', 'HorizontalAlignment','left');
            text(ax.XLim(end), ax.YLim(1), str_info, 'FontSize', 11, 'Color', 'k', ...
                        'VerticalAlignment', 'bottom', 'HorizontalAlignment','right');
            text(ax.XLim(end), ax.YLim(1), ['exp: ',s_ex_name], 'FontSize', 11, 'Color', 'k', ...
                    'VerticalAlignment', 'top', 'HorizontalAlignment','right');
            %
            saveas(gcf, [ex_str,'_ex',num2str(i_ex),'_stim_',num2str(k),'_ROI_mean__smoothging',num2str(smoothing_size),'_tiled.png']);
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

