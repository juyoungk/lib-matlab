%% Routine for SI Tif (imaging) and WS H5 (pd) data
%
% Run section by section!
%
    dirpath = pwd
    tif_filenames = getfilenames(dirpath, '/*.tif');
    % list of files    
    tif_filenames{:}

%% Load recording files 
    dirpath = pwd;    
    % loc 1? ND2 filter. Noisy
    % loc 2
    ex_str = 'Loc6_stack_pulse';
    g =  exp_struct_for_SI_tif(dirpath, ex_str);
    
%% implay for non-empty channel.
%implay_AutoColorMap(

%% ROI selection
    i_file_for_ROI = 2;
    ch_save = 3;

    img_for_ROI = g.(ex_str)(i_file_for_ROI).AI_mean{ch_save};
    h = g.(ex_str)(i_file_for_ROI).header;
           n_ch = h.n_channelSave;
    %
    figure;
    roi_array = multiRoi(img_for_ROI);
    %
    saveas(gcf, [ex_str,'_',num2str(1),'_roi.png']);
    %save([ex_str,'_',num2str(1),'_roi'], 'roi_array');

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

