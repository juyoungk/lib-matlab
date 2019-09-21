function plot_cluster_result(r)

% Figure setting
h = figure('Position', [0, 560, 250*num_cluster, 500]);
    x0 = 0.0;
    y0 = 0.0;
    x_spacing =(1-x0)/num_cluster;
    x_width = 1.*x_spacing;
    y_spacing = (1-y0)/2.;
    y_width = 1. * y_spacing;


% Plot cluster results    
for c = 1:r.totClusterNum
    
    ids_cluster = find(r.c==c);
    
    %subplot(2, num_cluster, c);
    %axes('Parent', h, 'OuterPosition', [x0/2.+(c-1)*x_spacing y0/2.+1*y_spacing x_width y_width]); % 'Visible', 'off'
    axes('Parent', h, 'OuterPosition', [(c-1)*x_spacing y_spacing x_width y_width]); % 'Visible', 'off'
    r.plot_avg(ids_cluster, 'PlotType', 'overlaid', 'NormByCol', true, 'Label', false);
    axis off
    
    %subplot(2, num_cluster, c+num_cluster);
    %axes('Parent', h, 'OuterPosition', [x0/2.+(c-1)*x_spacing (1-y0/2.)-1*y_spacing x_width y_width]);
    axes('Parent', h, 'OuterPosition', [(c-1)*x_spacing 0 x_width y_width]);
    %r.plot_roi(ids_cluster, 'label', false); % 'imageType', 'bw'
    r.plot_cluster_roi_labeled(ids_cluster, 'background', true, 'figure', false);
    
end    
%ff; % graph enhance.


print([r.avg_name, '_kmeans_clustered_',num2str(num_cluster)],'-dpng','-r300')




end