function s = dtof_stat_compute(m)

% Data
dtof = m.dtof;
tau = m.tau;

% Preproocessing: binning?

%
[numHist, numExp, numChan] = size(dtof);

%% channel dependent range selector
% baseline, std, threshold, then plot

% Baseline & std from the first 3 ns
% [1 numChannel]
s.dtof_baseline    = mean( m.dtof_mean((m.tau < 3), :) );
%s.dtof_baseline_std = std( m.dtof_mean((m.tau < 3), :) ); % std across tau time of mean DTOF. 
dtof_floor_std  = std( m.dtof(m.tau < 3, 1, :)  ); % fluctuation level in the 1st timestamp.
dtof_floor_std = squeeze(dtof_floor_std);
s.dtof_floor_std = dtof_floor_std;

% Threshold for each channel
threshold = s.dtof_baseline + 5 * dtof_floor_std;
fprintf('Threshold for dtof range = %.1f \n', threshold);

% Best range for each channel
% create dtof_range matrix.
tau_ch = cell(1, numChan);
dtof_range = zeros(numHist, numExp, numChan);

% Plot the range using dtof_mean 
figure('Position', [-1971 2038 1972 420]);
for c = 1:numChan
    y = m.dtof_mean(:,c);
    range = y > threshold(c);
    tau_ch{c} = tau(range);
    dtof_range(range,:,c) = dtof(range,:,c); % update only within the threshold-above range.
    
    subplot(1, numChan, c);
    %semilogy(tau, dtof_range(:, 1, c));
    semilogy(tau, m.dtof_mean(:, c));
    title(sprintf('ch %d dtof mean', c));
    xlabel('ns')
    xs = tau(range);
    xlim([xs(1) xs(end)]);
    grid on
    ff
end

%% total count over the range
m.dtof_tot = sum(dtof_range, 1);
m.dtof_tot = squeeze(m.dtof_tot);

%% Average TOF and Var
% tot counts (= m.count?)
tot_counts = sum(dtof_range, 1);
tot_counts = squeeze(tot_counts);

% tof_mean = # of measurements (e.g. timestamps) x # channels 
tof_mean = einsum(tau, dtof_range, 'ri,ijk->rjk'); % tau is 1xbins
tof_mean = squeeze(tof_mean);
tof_mean = tof_mean ./ tot_counts;

s.tof_mean = tof_mean;

% plot
figure;
subplot(1, 2, 1);
plot(tof_mean, '-'); % over exp conditions
%ylabel('{\Delta} Average TOF (ns)');
ylabel('Average TOF (ns)');
xlabel('sec');
grid on
ff

%%
tau_diff = zeros(numHist, numExp, numChan);

for c = 1:numChan
%for c = 1
    tau_diff(:,:,c) = repmat(tau(:), [1 numExp]) - tof_mean(:,c).'; % (-) row vector for each exp case.
end
tau_sq = tau_diff .* tau_diff;
tof_var = tau_sq .* dtof_range;
% sum over histogram dim (1)
tof_var = sum(tof_var, 1);
tof_var = squeeze(tof_var);
% normalized by the total count
tof_var = tof_var ./ tot_counts;

% normalized by the total count
% for t = 1:numExp
% for c = 1:numChan
%     tof_var(t,c) = tof_var(t,c) / tot_counts(t,c);
% end
% end

s.tof_var = tof_var;

%%
subplot(1, 2, 2);
plot(tof_var, '-');
ylabel('Variance (ns)');
grid on
ff

m.dtof_stat = s;

end