figure;

% under test
% input: (N X 1) "cell" array
i_exp = 640 -4;
s = spikes_session{8}(i_exp:i_exp+160-1);


t_window = [0.2 0.6];

n_exp = numel(s);

% psth of each row
psth = zeros(n_exp, 1);
firstspike = zeros(n_exp, 1);
% all the experiment
for i = 1:n_exp
    % logical array for time stamps: is it within the time window?
    idx1 = s{i} > t_window(1);
    idx2 = s{i} < t_window(2);
    idx = idx1 & idx2;
    psth(i) = sum(idx); % PSTH of the i-th row (or repeat)
    
    spikes_in_window = s{i}(idx); % can be an array or an empty
    if isempty(spikes_in_window)
        firstspike(i) = NaN;     % cannot be averaged..
    else 
        firstspike(i) = spikes_in_window(1); 
    end
end
% bar graph horizontally
subplot(1, 3, 1);
barh(psth); ylabel('trials');
set(gca,'Ydir','reverse')

%% average every m repeats
n_repeat = 4;
n_jitter = 4;
%
psth_avg = stat_every(psth, n_repeat);
psth_speed = stat_every(psth_avg, n_jitter);
firstspike_j = stat_every(firstspike, n_repeat);
firstspike_s = stat_every(firstspike_j, n_jitter);
%
subplot(1, 3, 2); barh(psth_avg);   set(gca,'Ydir','reverse'); title('PSTH avg.');
subplot(1, 3, 3); barh(psth_speed); set(gca,'Ydir','reverse'); title('PSTH vs Speed');


%% Analysis with Firing Rate
figure;
% firing rate (basically, binning & smoothing)
bin_size = 0.02;
smoothing = 3;
rate = ts_rate_cell(s, t_window, bin_size, smoothing); % rate is an array

%% average & std over identical repeats
[avg_r, std_r] = stat_every(rate, n_repeat);
% psth 
sum(avg_r, 2);
% peak of smoothed rate & its latency
[peak_r, id_r] = max(avg_r, [], 2);

%% average & std over certain conditions (e.g. same speed)
[avg_s, std_s] = stat_every(avg_r, n_jitter);
[peak_s, id_s] = max(avg_s, [], 2);

% final variable of the condition (e.g. speed)
x_condition = 0:100:900;

% display
subplot(1,3,1); imagesc(avg_s); title('FR avg over jitters'); ylabel('Speed');
%subplot(1,3,2); barh(peak_s); set(gca,'Ydir','reverse')
subplot(1,3,2); 
plot(peak_s, x_condition, 'o-'); hold on; % Peak FR
plot(sum(avg_s, 2), x_condition, 'o-');   % psth
set(gca,'Ydir','reverse'); xlabel('FR');

subplot(1,3,3); 
%subplot(1,3,3); barh(id_s*bin_size); set(gca,'Ydir','reverse')
plot(firstspike_s, x_condition, 'o-');     hold on;       % latency of the 1st spike
plot((id_s-0.5)*bin_size, x_condition, 'o-'); hold on; % latency of the peak FR

set(gca,'Ydir','reverse'); xlabel('Latency [s]'); 







