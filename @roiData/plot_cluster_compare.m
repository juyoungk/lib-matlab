function plot_cluster_compare(r, c_list)
% Compare (avg) repsonse traces for two or more clusters. Not ROI locations. 
% Default PlotType?

    % Fig setting
    figure;
    hfig = gcf;
        hfig.Color = 'none';
        hfig.PaperPositionMode = 'auto';
        hfig.InvertHardcopy = 'off';
        hfig.Position(4) = hfig.Position(3); % square figure size

        
    for c = c_list % cluster id list
        
        roi_clustered = find(r.c==c);
        
        ax = gca;
        
        hold on
        
        % Color order as in default
%         ax.ColorOrderIndex = c;
        
        % or you can define same color as clusters
        c_max = max(r.c);
        color = jet(c_max);
        ax.ColorOrder = color;
        ax.ColorOrderIndex = c;
        
        
        % mean trace. No drawing.
        r.plot_avg(roi_clustered, 'PlotType', 'mean', 'NormByCol', true, 'DrawPlot', true, 'Label', false); 
        
        
    end
    
    %r.plot_style(gca, 'avg', 'FontSize', 15);
    
    ylabel('a.u.');
    ax.YTick = []; 
    %yticklabels([]);
    
    ax.Color = 'k';
    
    axis off
    
    hold off
    


end