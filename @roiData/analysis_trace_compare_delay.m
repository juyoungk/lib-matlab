%% Compare average traces 
% 0921 see if there is any appreciable delay between soma and processes.
% 0928 add legend

% r = g.rr;

%% Trace compare
rois = 2:11;

% Filter ROIs
reliability_threshold = 0.15;
rois = rois(r.p_corr.smoothed_norm(rois) > reliability_threshold)
S = sprintf('ROI %d*', rois);
D = regexp(S, '*', 'split');

% Normalized dF/F
figure;
traces = r.plot_avg(rois, 'PlotType', 'all', 'NOrmByCol', true, 'Label', false, 'Smooth', 3); ff;
ax = gca;
ax.YTick = [];
%yticklabels([]);
ylabel('Normalized dF/F');
ax.XTick = [0, r.avg_duration/2, r.avg_duration];
xtickformat('%.1f');
xlabel('sec');
% legend
legend(D(1:(end-1)), 'FontSize', 13);

% Plot as it is
figure;
traces = r.plot_avg(rois, 'PlotType', 'all', 'NOrmByCol', false, 'Label', false, 'Smooth', 3); ff;
ax = gca;
ax.YTick = [];
%yticklabels([]);
ylabel('dF/F');
ax.XTick = [0, r.avg_duration/2, r.avg_duration];
xtickformat('%.1f');
xlabel('sec');
% legend
legend(D(1:(end-1)), 'FontSize', 13);


%%

