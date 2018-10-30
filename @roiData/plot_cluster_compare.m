function plot_cluster_compare(r, c_list)
% Compare (avg) repsonse traces for two or more clusters. Not ROI locations. 
% Default PlotType? 

    for c = c_list % cluster id list
        
        roi_clustered = find(r.c==c);
        
        % mean trace. No drawing.
        y = r.plot_avg(roi_clustered, 'PlotType', 'mean', 'NormByCol', true, 'DrawPlot', false);
        
        % zero mean & unit norm for cluster mean projection in r.plot2
        y = y - mean(y);
        y = y/norm(y);
        %y = r.traceForAvgPlot(y);
        [y, t] = r.traceAvgPlot(y);
        
        % Draw plot         
        plot(t, y, 'LineWidth', 1.5);
        hold on        

    end
    
    r.plot_style(gca, 'avg', 'FontSize', 15);
    
    ylabel('a.u.');
    yticklabels([]);
    
    hold off


end