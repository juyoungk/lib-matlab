function plot_cluster_compare(r, c_list)
% Compare (avg) repsonses for two or more clusters.
% Default PlotType? 

% c_mean has been computed? 


    for c = c_list % cluster id list
        
        roi_clustered = find(r.c==c);
        
        % mean trace. No drawing.
        y = r.plot_avg(roi_clustered, 'PlotType', 'mean', 'NormByCol', true, 'DrawPlot', false);
        
        % zero mean & unit norm for cluster mean projection in r.plot2
        y = y - mean(y);
        y = y/norm(y);
        y = r.traceForAvgPlot(y);
        
        % Draw plot         
        plot(r.a_times, y, 'LineWidth', 1.5);
        hold on        

    end
    
    r.plot_style(gca, 'avg', 'FontSize', 15);
    
    ylabel('a.u.');
    yticklabels([]);
    
    hold off


end