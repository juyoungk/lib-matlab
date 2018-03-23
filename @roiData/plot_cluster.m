function plot_cluster(r, n_trace, i_cluster)
% smoothed trace
% n_trace - # of individual traces
%   i_row - update plots for specified i_row.   
    
    if nargin <3
        i_cluster = 1:r.numCluster;
    end
    
    if nargin < 2
        n_trace = 4;
    end
    
    % get focus or create new function if it is not empty
    if ishandle(r.c_hfig)
        figure(r.c_hfig);
    elseif ~min(cellfun('isempty', r.c))
        r.c_hfig = figure('Position', [1400 250 1000 1300]);
    else
        return;
    end
    h = r.c_hfig;
    
    %
    n_row = r.numCluster;
    n_col = n_trace + 2;
    x_width = 1/n_col;
    y_width = 1/n_row;
    
    % Delete axes handles for updated clusters
    numAxes = numel(h.Children);
    clu = zeros(1, numAxes);
    for ii = 1:numAxes
        pos = h.Children(ii).OuterPosition;
        clu(ii) = round((1 - pos(2))/y_width);
    end
    in = false(1, numAxes);
    for ii = i_cluster
       in = in | (clu == ii); 
    end
    delete(h.Children(in));
        
  
    for i=i_cluster % row number
        
        if isempty(r.c{i})
            continue;
        end
        
        % avg over clustered ROIs
        j = 1; % col number
        axes('Parent', h, 'OuterPosition', [(j-1)*x_width 1-i*y_width x_width y_width]);
        %subplot(n_row, n_col, (i-1)*n_col + j);
        r.plot_avg(r.c{i}, 'PlotType', 'mean', 'NormByCol', true, 'LineWidth', 1.2);
        title(['c',num2str(i),': mean']);
        
        % all traces (normalized?)
        j = 2;
        axes('Parent', h, 'OuterPosition', [(j-1)*x_width 1-i*y_width x_width y_width]);
        %subplot(n_row, n_col, (i-1)*n_col + j);
        r.plot_avg(r.c{i}, 'PlotType', 'all', 'NormByCol', true, 'LineWidth', 0.7);
        title(['c',num2str(i),': all']);
        
        % individual traces up to 4
        n_members = numel(r.c{i});
        n_traces = min(n_members, n_col - 2);
        
        for k=1:n_traces
            j = k + 2;
            axes('Parent', h, 'OuterPosition', [(j-1)*x_width 1-i*y_width x_width y_width]);
            %subplot(n_row, n_col, (i-1)*n_col + j);
            r.plot_avg(r.c{i}(k), 'LineWidth', 1.2);
        end

        
    end


end