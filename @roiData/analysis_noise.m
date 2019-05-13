%% histrogram analysis for understanding noise
id = 14;

%%
num_bin = 25;
% raw trace
x = r.roi_trace(:, id);
plot_hist(x, num_bin);
title(['Raw trace. ROI ', num2str(id),''], 'FontSize', 18);

%% smoothed trace
figure;
num_bin = 25;
x = r.roi_smoothed(:, id);
plot_hist(x, num_bin);
title(['Smoothed trace. ROI ', num2str(id),''], 'FontSize', 18);

%% Norm trace
x = r.roi_smoothed_norm(:, id);
plot_hist(x, num_bin);

title(['Smoothed Normed trace. ROI ', num2str(id)], 'FontSize', 18);



%% noise

%% var vs mean for each cell: var is Poisson-like? 
ids = r.roi_good(1:10);
Fontsize = 16;

%ids = find(r.stat.mean_stim > 250 & r.p_corr.smoothed_norm > 0.5);
figure;
for id = ids

    % smoothed trace
    x = r.avg_trace(:, id);
    y = r.stat.smoothed.var(:, id);
    

    scatter(x, y);
    
    hold on
end

hold off

xlabel('Mean (a.u.)');
ylabel('Variance');
ax = gca;
ax.XAxis.FontSize = Fontsize;
ax.YAxis.FontSize = Fontsize;


%% Normed trace
figure;
for id = ids

    x = r.avg_trace_smooth_norm(:, id);
    y = r.stat.smoothed_norm.var(:, id);
    
    scatter(x, y);
    
    hold on
end

hold off

xlabel('Mean dF/F (%)');
ylabel('Variance');
ax = gca;
ax.XAxis.FontSize = Fontsize;
ax.YAxis.FontSize = Fontsize;
