function h5export(r, ids, PlotType)
% Export upsample or dowmsampled stim & resampled data to h5 file
% Note: you should first choose right filter and smoothing size. 
% stim:  [ch x frames] (vs [frames x ch] ?)
% rdata: [times x rois] - confusing..

if nargin < 3
    PlotType = 'Smoothed';
end

if nargin < 2
    ids = 1:r.numRoi;
    error('You probably wouldn''t want to export all the data. Please specify ROI IDs.');
end


% parameters for export
dpath = '/Users/peterfish/Modules/';
fname = [dpath, 'data_',r.ex_name, '_exported_', datestr(now, 'HH_MM_SS'),'.h5'];
group = '/exp1';  % default group name
upsampling = 5;

if exist(fname, 'file')==2
  delete(fname);
end

% Which trace? 
%y = r.roi_smoothed_norm(:, ids);
%t = r.f_times;

% y = r.roi_smoothed_detrend(:, ids);
% disp('Smoothed_detrend (trend substracted, but not normalized) was used for data.');

%y = r.roi_filtered(:, ids); 
% --> usually unwanted correlation with a certain pixel.
%disp('filtered trace (not normalizeed) was used for data.'); 

% y = r.roi_smoothed_norm(:, ids);
% disp('Smoothed normalized trace was used for data.');

y = r.roi_filtered_norm(:, ids);
disp('Filtered normalized trace was used for data.');
disp('For smoothed_norm? use f_times instead of f_times_norm');

t = r.f_times_norm; % only for detrend normalized or filtered trace. 
t = t - r.stim_trigger_times(1); % Align t with respect to the 1st trigger time [-xx, .. , 0, xx, .. ]

% First, upsample stim movie
[sstim, fliptimes] = upsample_stim(r.stim_movie, r.stim_fliptimes, upsampling);

% Resample stim movie at recording times
    % 1. select rdata only within fliptimes.
    t = t(t>fliptimes(1));
    y = y(t>fliptimes(1), :);

    % 2. Stim resampled at frame times. 
    % Time dimension should be 1. sstim should be reshaped and transposed.
    stim_rtime = reshape(sstim, [], length(fliptimes));
    stim_rtime = double(stim_rtime);
    stim_rtime = interp1(fliptimes, stim_rtime.', t); % [N (times), D1, D2, ..] for V (sstim)
    stim_rtime = stim_rtime.';

    % Exclude NaN values 
    stim_rtime = stim_rtime(:, ~isnan(stim_rtime(1,:))); % exclude NaN elements
    
    % Get the same length of rdata
    [~, N_flips] = size(stim_rtime);   % Frame num
    y = y(1:N_flips, :);
    t = t(1:N_flips);

    % Center the stim data
    stim_rtime = scaled(stim_rtime) - 0.5;
    
    % Alignment Check (only for one cell)
    cell_id = 2;
    rf = revcorr(stim_rtime, y(:, cell_id), 35);
    figure; plot_rf_map(r, rf); title('Rev correlation (w/ resampeld stim at frame times)');

    % Save resampled stim movie
    h5create(fname, [group '/stim_rtime'], size(stim_rtime));
    h5write(fname, [group '/stim_rtime'], stim_rtime);
    h5create(fname, [group '/rdata'], size(y));
    h5write(fname, [group '/rdata'], y);
    h5create(fname, [group '/rtime'], size(t));
    h5write(fname, [group '/rtime'], t);

    % Resample rdata at upsampled stim movie
    sstim_res = reshape(sstim, [], length(fliptimes));
    
    % 1. select stim only within recording times
    fliptimes = fliptimes(fliptimes>t(1));
    sstim_res     = sstim_res(:, fliptimes>t(1));
    
    % Resample rdata at upsampled stim rate
    y_fliptimes = interp1(t, y, fliptimes);
    
    % Exclude NaN values
    y_fliptimes = y_fliptimes(~isnan(y_fliptimes(:,1)), :);
    
    % Get the same length of stim
    [numFrames, ~] = size(y_fliptimes);
    fliptimes = fliptimes(1:numFrames);
    sstim_res = sstim_res(:, 1:numFrames);
    
    % Alignment Check for upsampled stim
    rf = revcorr(sstim_res, y_fliptimes(:, cell_id), 100);
    figure; plot_rf_map(r, rf); title('Rev correlation (w/ upsampled stim)');
    %stim_upsampled_rate = 20 * upsampling;
    ax = gca; ax.DataAspectRatio = [1 0.4 1];

    % Save upsampled stim (reshaped). (20 Hz x 5 ~ 100 Hz)
    h5create(fname, [group '/stim_res'], size(sstim_res), 'Datatype', 'uint8');
    h5write(fname, [group '/stim_res'], sstim_res);
    h5create(fname, [group '/fliptimes'], size(fliptimes));
    h5write(fname, [group '/fliptimes'], fliptimes);
    %
    h5create(fname, [group '/rdata_fliptimes'], size(y_fliptimes));
    h5write(fname, [group '/rdata_fliptimes'], y_fliptimes);
    % IDs
    h5create(fname, [group '/roi_ids'], size(ids));
    h5write(fname, [group '/roi_ids'], ids);

% Attributes
h5writeatt(fname, group, 'Name', r.ex_name);
h5writeatt(fname, group, 'roi', ids);
h5writeatt(fname, group, 'ifi', r.ifi);
h5writeatt(fname, group, 'Smooth_size', r.smoothing_size);
        %disp(['Smoothing size : ', num2str(r.smoothing_size)]);
        
end


function [sstim, times] = upsample_stim(stim, fliptimes, upsampling)
% reshape stim into [ch, flips], then upsample by 1, 2, or 5.
% inlclude 0 fliptimes.

% make fliptimes row vector [1 col] for easy upsampling
if ~isrow(fliptimes)
    fliptimes = fliptimes.';
end

f_ifi = fliptimes(2)-fliptimes(1);

% Upsampling of stim fliptimes
if upsampling == 1
    times = fliptimes + 0.5*f_ifi;
elseif upsampling == 2
    times = [fliptimes; fliptimes+0.50*f_ifi] + 0.25*f_ifi;
    %fliptimes = [fliptimes+0.25*f_ifi; fliptimes+0.75*f_ifi];
elseif upsampling == 5
    times = [fliptimes; fliptimes+0.2*f_ifi; fliptimes+0.4*f_ifi; fliptimes+0.6*f_ifi; fliptimes+0.8*f_ifi] + 0.1*f_ifi;
else
    error('Possible Upsampling factor is 1, 2 and 5 currently');
end
times = reshape(times, [], 1); % col vector (row only)

% Reshape and Upsample stim frames
sstim = reshape(stim, [], length(fliptimes));       % reshaped stim. [t1 t2 t3 ..] coulmn vector as time goes.
sstim = expandTile(sstim, 1, upsampling);

% reshape into original?

end