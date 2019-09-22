%% 





%% Trace compare
figure;

rois = 2:10;

r.plot_avg(rois, 'PlotType', 'all', 'NOrmByCol', false, 'Label', false, 'Smooth', 3);

ff;

figure;

r.plot_avg(rois, 'PlotType', 'all', 'NOrmByCol', true, 'Label', false, 'Smooth', 3);

ff;
%%