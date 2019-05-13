%% what is the best trace filtering or smoothing for RF estimation and modeling? 
% raw vs smoothed vs filtered traces
id_selected = [9, 10, 14, 20, 21];

% roiData object 
id = 9
% plot properties
linewidth = 2;
x_range = [50 60];
%
h = figure;
h.Position(3) = 1500;
h.Position(4) = 300;
%
r.plot_trace_raw(id); 
ax = gca;
ax.Children(end).LineWidth = linewidth;
hold on
%
%plot(r.f_times_fil, r.roi_filtered(:, id), 'LineWidth', linewidth);
plot(r.f_times, r.roi_smoothed(:, id), 'LineWidth', linewidth);
ax.XLim = x_range;
ax.Children(1).Color = [0.7 0 0];
plot(r.f_times_fil, r.roi_filtered(:, id), 'LineWidth', linewidth);
ax.Children(1).Color = [0 0.6 0];

% yyaxis right
% %r.plot_trace_norm(id); 
% ax = gca;
% ax.XLim = [50, 60];
% ax.Children(end).LineWidth = linewidth;
% ax.Children(end).Color = [0.7 0 0];


%% RF : Filtered trace
id = 9;
h = figure('Name', 'filtered');
h.Position(3) = 750;
h.Position(4) = 190;
%
s_filtered = r.plot_rf2(id, 'filtered');

%% RF : Smoothed trace
h = figure('Name', 'smoothed');
h.Position(3) = 750;
h.Position(4) = 190;
%
s_smoothed = r.plot_rf2(id, 'smoothed');

%% RF for ROIs
id = [4, 9, 10, 14, 17, 20, 21];
s_filtered = r.plot_rf2(id, 'filtered');


%% 2018 1021 corr vs smoothing_size
r.smoothing_size = 5;  
[~, ids] = sort(r.p_corr.smoothed_norm, 'descend');
ids = ids(1:20);

figure;
linewidth = 2;
%plot(r.p_corr.smoothed_norm(ids), 'LineWidth', linewidth); hold on

for i = [3, 5, 7, 9]
    r.smoothing_size = i;  
    plot(r.p_corr.smoothed_norm(ids), '-s', 'LineWidth', linewidth, 'MarkerSize', 12); hold on
end
hold off
xlabel('ROI');
ylabel('Correlation');
legend({'15 ms', '25 ms', '35 ms', '45 ms'}, 'FontSize', 18);
grid on
%ylim([0.25 0.85]);

%% 2018 1021 Traces vs smoothing_size
ids = 9;
h = figure; h.Position = [300 1445 1500 350];
linewidth = 1.5;

for i = [1, 7]
     r.smoothing_size = i;
     if i == 1
         plot(r.f_times_fil, r.roi_smoothed_norm(:,ids), 'Color', [0.7 0.7 0.7], 'LineWidth', 1.2*linewidth); hold on
     else
        plot(r.f_times_fil, r.roi_smoothed_norm(:,ids), 'LineWidth', linewidth); hold on
     end
end
% xlim([r.sess_trigger_times(1), r.sess_trigger_times(2)]); 
xlim([100, 120]);
xlabel('Time (s)');
ylabel('dF/F');

hold off
%grid on

%% 2018 1021 Total bleaching or Drift? 
% Normalize the whole trace in [0 1] and then compare
r.smoothing_size = 5;  
%[~, ids] = sort(r.p_corr.smoothed_norm, 'descend');
[~, ids] = sort(r.stat.mean_stim, 'descend');
ids = ids(1:20);
%
h = figure;
h.Position(3) = 1500;
h.Position(4) = 350;
%
linewidth = 0.8;
%
for i = ids
    y = r.roi_smoothed(:,i);
    y = y- min(y);
    y = y / max(y);
    plot(r.f_times, y, 'LineWidth', linewidth); hold on
end
xlim([r.sess_trigger_times(1), r.f_times(end)]); 
xlabel('Time (s)');
ylabel('');
hold off

