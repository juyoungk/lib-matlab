function plot_cluster(r, i_cluster, n_trace)
% smoothed trace
% n_trace - # of individual traces
%   i_row - update plots for specified i_row.   
    

    if nargin < 3
        n_trace = 4;
    end
    
    if nargin < 2
        i_cluster = 1:r.dispClusterNum;
    end
    
    % exclude cluster 0
    i_cluster(i_cluster==0) = [];
    
    % get focus or create new function if it is not empty
    if ishandle(r.c_hfig)
        figure(r.c_hfig);
    elseif max(r.c) > 0
        r.c_hfig = figure('Position', [1430 250 1000 1300]);
    else
        return;
    end
    h = r.c_hfig;
    c = r.c;     % cluster id array for all rois
    %
    n_row = r.dispClusterNum;
    n_col = n_trace + 2;
    x_width = 1/n_col;
    y_width = 1/n_row;
    
    % Cluster id (or Locations) of all axes handles
    numAxes = numel(h.Children);
    clu = zeros(1, numAxes);
    for ii = 1:numAxes
        pos = h.Children(ii).OuterPosition;
        clu(ii) = round((1 - pos(2))/y_width);
    end
    % Delete any plots of updated cluster (i_cluster)
    in = false(1, numAxes);
    for ii = i_cluster
       in = in | (clu == ii); 
    end
    delete(h.Children(in));
        
  
    for i = i_cluster % row number (~ cluster number)
        
        roi_clustered = find(c==i);
        
        if isempty(roi_clustered)
            continue;
        end
        
        % avg over clustered ROIs
        j = 1; % col number
        axes('Parent', h, 'OuterPosition', [(j-1)*x_width 1-i*y_width x_width y_width]);
        %subplot(n_row, n_col, (i-1)*n_col + j);
        %r.plot_avg(r.c{i}, 'PlotType', 'mean', 'NormByCol', true, 'LineWidth', 1.2);
        y = r.plot_avg(roi_clustered, 'PlotType', 'mean', 'NormByCol', true, 'LineWidth', 1.2);
        % zero mean & unit norm 
            y = y - mean(y);
            r.c_mean(:,i) = y/norm(y);
        title(['c',num2str(i),': mean']);
        
        % all traces
        j = 2;
            axes('Parent', h, 'OuterPosition', [(j-1)*x_width 1-i*y_width x_width y_width]);
            %subplot(n_row, n_col, (i-1)*n_col + j);
            r.plot_avg(roi_clustered, 'PlotType', 'all', 'NormByCol', true, 'LineWidth', 0.7);
            str = sprintf('c%d: all traces (n = %d)', i, numel(roi_clustered));
            title(str);

        % individual traces up to 4
        n_members = numel(roi_clustered);
        n_plot = min(n_members, n_col - 2);
        
        for k=1:n_plot
            j = k + 2;
            axes('Parent', h, 'OuterPosition', [(j-1)*x_width 1-i*y_width x_width y_width]);
            %subplot(n_row, n_col, (i-1)*n_col + j);
            r.plot_avg(roi_clustered(k), 'LineWidth', 1.2);
        end

        
    end


end