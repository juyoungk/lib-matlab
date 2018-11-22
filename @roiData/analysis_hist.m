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



%% Response histogram over all ROIs + RF ?


for i = 1:r.numRoi
    
end

