%% Juliet file open
data_path= '/Users/juyoungkim/Documents/Data/2019_1125_Kite2_noise_level_LCLV';
s_filter= 'bias';
data_path= pwd; % 1206 anlaysis
s_filter= 'B=';
d = dir(fullfile(data_path, ['*',s_filter,'*.h5']))
fn = d(1).name;
m = mdata(fn)
%% HydraHarp ASCII file open
m = mdata;
data_path= '/Users/juyoungkim/Documents/Data/2019_1120_Kite2_Silicone_inhomo'; s_filter = 'ch';
data_path=pwd;

% open multiple files with the s_filter
m.import_ascii(fullfile(data_path, ['*',s_filter,'*.dat']));
s_filter = [s_filter, ' mm silicone'];

% DTOF binning
bin_time = 250; % ps. 100 ps ~ 50 points
[dtof_binned, tau_binned] = m.dtof_binning(bin_time);
s_filter = [s_filter, sprintf('\nbinning %.0f ps\n', bin_time)];

% ASE subtracted DTOF and contrast
dtof = dtof_binned;
tau = tau_binned;

% Baseline of the first 3 ns
baseline = mean(dtof((tau < 3), :, :), 1);
b_std = std(dtof((tau < 3), :, :));

% ASE subtracted
%
%dtof = dtof - baseline; s_filter = [s_filter, '(- baseline)']; 
%

% Check the baseline substracted DTOF
% channel = 1;
% figure
% semilogy(tau, dtof(:,:,channel)) % channel 1
% xlabel('ns');
% ylabel('counts');
% title(s_filter);
% grid on
% ff(0.8);

%% Contrast plot
numCh_plot = 4;
ref_channel = 1;
%colors = colororder;
% Total count contrast (CW)
tot_counts = sum(dtof, 1);
tot_counts = squeeze(tot_counts);

% if counts < cutoff --> replace with NaN to limit the plot
cutoff = 950; dtof(dtof<cutoff) = NaN;

%figure
savename = sprintf('%s cutoff_%d', s_filter, cutoff);
savename = strrep(savename, newline, '_');
figure('Position', [1 1100 2560 373], 'Name', savename);

% 1. contrast
% 2. SNR

for c = 1:numCh_plot
    
    subplot(1, numCh_plot, c);
    
    dtof_ch = dtof(:,:,c);
    dtof_ref = dtof(:,ref_channel,c);
    dtof_cont = (dtof_ref - dtof(:,:,c))./dtof_ref;
    dtof_diff_to_shotN = (dtof_ref - dtof(:,:,c))./sqrt(dtof_ref);

    plot(tau, dtof_cont); 
    ylabel(['{\Delta Count / Count_{No bias}}']); 
    
    % SNR vs arrival time (std N = sqrt(N))
    %plot(tau, dtof_diff_to_shotN);
    ylabel(['{\Delta Count / shot noise }']);
    
    xlim([10 19.5]);
    %ylim([-0.1 0.8]);
    
    xlabel('ns');
    
    % CW contrast
    hold on
    ax = gca;
    ax.ColorOrderIndex = 1;
    cw_ref = tot_counts(ref_channel, c);
    cw_cont = (cw_ref - tot_counts(:, c))./cw_ref;
    cw_snr = (cw_ref - tot_counts(:, c))./sqrt(cw_ref);
    
    plot(ax.XLim, [cw_cont cw_cont], '--'); ylim([-0.02 0.6]);
    %plot(ax.XLim, [cw_snr cw_snr], '--');
    hold off
    
    % dtof plot
    yyaxis right
    ax = gca;
    ax.ColorOrderIndex = 1;
    plot(tau, dtof_ch, 'o-')
    ax.YAxis(2).Scale = 'log';
    ax.YAxis(2).Color = ax.ColorOrder;
    grid on
    %ylabel('Counts');
    ff
    text(ax.XLim(2), ax.YLim(2), s_filter, 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', 'FontSize', 18);
    title([sprintf('SD=%.0fmm', c*11)]);
end

print(['', savename], '-dpng', '-r300');


%% DTOF statistics
figure('Position', [1 1100 2560 373], 'Name', savename);

bin_time = 200; % ps. 100 ps ~ 50 points
[dtof, tau] = m.dtof_binning(bin_time);
[numBin, numExp, numChannel] = size(dtof);

for c = 1:numCh_plot

    subplot(1, numCh_plot, c);
    
    % mean delay, or average weighted tau
    dtof_ch = dtof(:,:,c);
    tot_counts = sum(dtof_ch, 1);
    
    tau_center = (tau * dtof_ch) ./ tot_counts;
    
    plot(tau_center-tau_center(1), 'o-'); % over exp conditions
    ylabel('{\Delta} Average delay (ns)');
    xlabel('bais conditions');
    grid on
    ff
    
    % variance of weighted tau
    tau0 = repmat(tau.', [1 numExp]) - tau_center;
    tau0_sq = (tau0 .* tau0);
    
    tau_var = zeros(1, numExp);
    for t = 1:numExp
        tau_var(t) = dot(tau0_sq(:, t), dtof_ch(:, t))/tot_counts(t);
    end
    yyaxis right
    plot(tau_var, 'o-');
    ylabel('Variance (ns)');
    ff
    ax = gca;
    ax.YLabel.Color = ax.YAxis(2).Color;
    
    title([sprintf('SD=%.0fmm', c*11)]);
    
    % max of the dtof
    [M, I] = max(dtof_ch);
    
end

%% stat function develope
% binning?
dtof = m.dtof;
tau = m.tau;

[numHist, numExp, numChan] = size(dtof);

tot_counts = sum(dtof, 1);
tot_counts = squeeze(tot_counts);

% tof_mean = # of measurements (e.g. timestamps) x # channels 
tof_mean = einsum(tau, dtof, 'ri,ijk->rjk'); % tau is 1xbins
tof_mean = squeeze(tof_mean);
tof_mean = tof_mean ./ tot_counts;
    
%     plot(tof_mean-tof_mean(1), 'o-'); % over exp conditions
%     ylabel('{\Delta} Average delay (ns)');
%     xlabel('bais conditions');
%     grid on
%     ff

%%
tau_diff = zeros(numHist, numExp, numChan);

for c = 1:numChan
%for c = 1
    tau_diff(:,:,c) = repmat(tau(:), [1 numExp]) - tof_mean(:,c).'; % (-) row vector for each exp case.
end
tau_sq = tau_diff .* tau_diff;
tof_var = tau_sq .* dtof;

% normalized by the total count
for t = 1:numExp
for c = 1:numChan
    tof_var(:,t,c) = tof_var(:,t,c) / tot_counts(t,c);
end
end



%% Variance of weighted tau
tau0 = repmat(tau(:), [1 numExp numChan]) - tof_mean;
tau0_sq = (tau0 .* tau0);

tau_var = zeros(1, numExp);
for t = 1:numExp
    tau_var(t) = dot(tau0_sq(:, t), dtof_ch(:, t))/tot_counts(t);
end
yyaxis right
plot(tau_var, 'o-');
ylabel('Variance (ns)');
ff
ax = gca;
ax.YLabel.Color = ax.YAxis(2).Color;

title([sprintf('SD=%.0fmm', c*11)]);


m.dtof_stat.tof_mean = tof_mean;

s.tof_mean = tof_mean;
%s.tof_var = tof_var;





