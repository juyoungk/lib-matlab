%%
r = roiData;

%% filenames from directory
dirpath = '';
filenames = dir([dirpath,'*analyzed*.h5']);
filenames = {filenames.name};

%%
numfiles = numel(filenames);
%
spectra = cell(1, numfiles);
counts = cell(1, numfiles);
freqs = cell(1, numfiles);
max_numtimes = 1;
disp(' ');
for i=1:numfiles
    filename = [dirpath, filenames{i}];
    data = h5read(filename, '/CountRate');
    filename = strrep(filename, '_', '-');

    count = data.payload.count;
    count = double(count); % convert uint64 to double for fft
    counts{i} = count;

    timestamp = data.header.timestamp;
    timestamp = timestamp - timestamp(1); % ns precision
    timestamp = double(timestamp) * 1e-9; % sec
    numtimes = length(timestamp);
    max_numtimes = max(numtimes, max_numtimes);

    figure('Position', [852 1099 1170 450]);
    subplot(121);
    plot(timestamp, count);
    grid on
    xlabel('sec')
    ylabel('Counts');
    ff;

    % fft plot
    int_time = timestamp(2) - timestamp(1); % sec
    fprintf('%s \n- sampling interval %.1e sec\n', filename, int_time);

    count = count - mean(count);

    subplot(122);
    [freqs{i}, spectra{i}] = plot_fft(count, int_time);
    ax_title = title(filename, 'HorizontalAlignment', 'right');
    ax_title.Position(1) = 1/int_time*0.5;
    grid on
    %ax = gca;
    %ax.XTick = [];

    % save
    print(['CR_FFT_',filename,'.png'], '-dpng', '-r300');
    disp(' ');
end

%% FFT in one plot
figure;
for i=1:numfiles
    
    freq = freqs{i};
    power = spectra{i};
    
    % normalization
    power = power(freq>0);
    freq = freq(freq>0);
    power = log10(power);
    power = power/norm(power);
    
    plot(freq, power);
    hold on
end
hold off
grid on
xlabel('Hz');
ylabel('FFT power (log)'); 
ax = gca;
ax.XLim(1) = 0;
ax.YTickLabel = [];
ff;
print(['FFT_all_normalized_log.png'], '-dpng', '-r300');

%% 2D matrix for all data --> roiData
% All measurements were made with same stimulus sequence.
traces = zeros(max_numtimes, numfiles);

for i=1:numfiles
    
    y = counts{i};
    
    traces(1:length(y), i) = y;
end

r.ex_name = '1014 Emily Kite0.0';
r.ifi = int_time; % last file
r.roi_trace = traces(1:end-1, :); % exclude the final sample data.
r.numFrames = max_numtimes-1;
r.f_times = ((1:r.numFrames)-0.5)*r.ifi;
r.numRoi = numfiles;
r.c = zeros(1,r.numRoi);
%% exp name
ex_names = cell(1, numfiles);
for k=1:numfiles
    ex_names{k} = sprintf('delay %.1f ns', (k-1)*0.5);
end
ex_names{5} = 'null exp';
    
%% stimulus cues > baseline > smoothing
duration_start_screen = 20;
duration_session = 23;
n_cycle = 15;
% session start times
r.sess_trigger_times = duration_start_screen + (0:duration_session:duration_session*(n_cycle-1));
%r.stim_trigger_times = r.sess_trigger_times;
r.stim_trigger_times = [r.sess_trigger_times, r.sess_trigger_times+11];
r.stim_trigger_times = sort(r.stim_trigger_times);

r.s_phase = 0;
r.n_cycle = 1.5;
r.avg_stim_times = [0 11];
r.avg_stim_plot(1).tag = '{\it}Rest';
r.avg_stim_plot(2).tag = '{\it}Tapping';
[r.avg_stim_plot(:).middleline] = deal(false);
r.baseline;
r.smoothing_size = 7;

%% average analysis
r.avg_trigger_times = r.sess_trigger_times;
r.avg_duration = duration_session;
r.avg_FLAG = 1;
r.average_analysis;
%%
r.plot_counts;

%% avg trace with baseline normalization for each repeat.
h = figure('Position', [404 1142 346*numfiles 242]);
    x0 = 0.015;
    y0 = 0.0;
    x_spacing = (1-x0)/numfiles;
    y_spacing = (1-y0);

r.s_phase = 0;
r.n_cycle = 1.5;
r.avg_stim_plot(1).tag = '{\it}Rest';
r.avg_stim_plot(2).tag = '{\it}Tapping';

% smoothed or de-trend one
[y_aligned, x] = r.align_trace_to_avg_triggers('smoothed');

axlist = [];

for k=1:numfiles
    %subplot(1, numfiles, k);
    ax = axes('Parent', h, 'OuterPosition', [x0+(k-1)*x_spacing y0 x_spacing y_spacing]); % 'Visible', 'off'
    axlist = [axlist, ax];
    
    str_name = sprintf(' delay %.1f ns', (k-1)*0.5);
    if k == 5
        str_name = ' null exp';
    end
    
    % Individual traces for single cell or ROI id.
    y = y_aligned(:,k,:);
    y = squeeze(y);
    % y = times x repeats (single cell)
    
    % baseline
    duration_baseline = 5; % sec
    ti = max(r.avg_stim_times(2) - duration_baseline, 0); % ti should be larger than time 0
    i_baseline = find(r.a_times > ti, 1);
    f_baseline = i_baseline + round(duration_baseline/r.ifi);
    
    % normalization by baseline between i and f
    %y = normc_baseline(y, i_baseline, f_baseline);
    
    
    % zscore: once zscored, additional normalization by baseline is not
    % appropriate. De-mean is fine.
    
    % de-mean
    %[y, baseline] = demean_baseline(y, i_baseline, f_baseline);
    
    % median trace
    
    % error bar or 25%/75% region
    
    
%     
%     % 1. Mean of baseline normalized traces with Std box.
     r.plot_avg(k, 'traceType', 'smoothed_norm_repeat', 'Name', ' ', 'Std', true, 'Corr', false, 'label', false);
     ax = gca;
     ax.YLim = [-1, 1];
     r.plot_avg_style;
%     p_corr = r.p_corr.smoothed_norm_repeat;
%     
    % 2. Baseline normalized individual lines.
%     plot(x, y, 'Color', 0.60*[1 1 1], 'LineWidth', 0.8);
%     r.plot_avg_style;
% 
%     % 3. zscore and baseline demean 
%     y = zscore(y, 0, 1);
%     y = demean_baseline(y, i_baselin, f_baselin);
%     plot(x, y, 'Color', 0.60*[1 1 1], 'LineWidth', 0.8);
%     r.plot_avg_style;
    
    % error bar for skewed distribution
   
    title('Avg response', 'FontSize', 16);
    title(str_name, 'FontSize', 16);
    ylabel('{\it \Delta}C/C_{base} [%]');
    xlabel('sec')
    ax = gca;
    ax.YAxis.Exponent = 0;
    
%     % correlation between responses
%     str = sprintf('%.2f ', p_corr(k));
%     text(ax.XLim(end), ax.YLim(2), ['{\it r} = ',str], 'FontSize', 15, 'Color', 'k', ...
%                 'VerticalAlignment', 'top', 'HorizontalAlignment','right');

%     axes('Parent', h, 'OuterPosition', [x0+(k-1)*x_spacing y0+y_spacing x_spacing y_spacing]); % 'Visible', 'off'
%     r.plot_avg(k, 'traceType', 'smoothed_detrend_norm_repeat', 'Name', str_name, 'Std', true, 'Corr', false);
end

% Make it in same scale, then put text?


%% save plot_counts figures
for k=1:numfiles
    r.plot_counts(k);
    print(['traces_',ex_names{k},'.png'], '-dpng', '-r300');
end

%%
r.plot_repeat(1:numfiles, 'PlotType', 'overlaid', ...
                        'TraceType', 'smoothed', ...
                        'Norm', 'repeat_baseline', ...
                        'MeanPlot', false);
%%                    
                    
                    
