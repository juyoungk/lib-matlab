function plot_cluster(r, i_cluster, n_trace, PlotType)
% smoothed trace
% n_trace - # of individual traces
%   i_row - update plots for specified i_row.
    

    if nargin < 3
        n_trace = 5;
    end
    
    if nargin < 2
        i_cluster = 1:r.dispClusterNum;
    else
        i_cluster(i_cluster ==0) = []; % exclude 0 (noise) cluster
    end
    %i_cluster(i_cluster==0) = []; % exclude cluster 0
    c = r.c;     % cluster id array for all rois
    
    %
    n_row = r.dispClusterNum;
    n_col = n_trace + 2;
    x0 = 0.05;
    y0 = 0.0;
    x_width = (1-x0)/n_col;
    y_width = (1-y0)/n_row;
     
    % get focus or create new function if it is not empty
    if ishandle(r.c_hfig)
        figure(r.c_hfig);
        
    elseif max(r.c) > 0
        r.c_hfig = figure('Position', [1430 50 1000 900]);
        %r.c_hfig = figure('Position', [1430 50 1100 1500]);
        pos = r.c_hfig.Position;
        % Create button group
        bg = uibuttongroup('Visible','off',...
                  'Position',[0 0 x0 1],...
                  'SelectionChangedFcn',@bselection); % callback fun is defined in the below.
        for i = i_cluster
            uicontrol(bg,'Style', 'pushbutton',...
                  'String', num2str(i),...
                  'Position', [0 ((1-y0)-i*y_width)*pos(4) x0*pos(3) y_width*pos(4)],...
                  'HandleVisibility','off',...
                  'UserData', i, 'Callback', @pushbutton_callback, 'FontSize', 14);      
        end
        bg.Visible = 'on';
    else
        disp('No clusters has been assigned yet');
        return;
    end
    h = r.c_hfig;
   
    % Cluster id (or Locations) of all axes handles
    numAxes = numel(h.Children);
    clu = zeros(1, numAxes);
    for ii = 1:numAxes
        pos = h.Children(ii).OuterPosition;
        clu(ii) = round((1 - pos(2))/y_width);
        if pos(4) == 1
            % button group. Skip the deletion step
            clu(ii) = -1;
        end
    end
    % Delete any plots of updated cluster (i_cluster)
    in = false(1, numAxes);
    for ii = i_cluster
       in = in | (clu == ii); 
    end
    delete(h.Children(in));
    
    % uibutton group
                
    for i = i_cluster % row number (~ cluster number)
        
        % push button for opening a plot window for selected cluster
        % this is not axes, but uicontrol
        
        roi_clustered = find(c==i);
            % sort by mean f
            mean_f = r.stat.mean_f(roi_clustered);
            [~, i_sorted] = sort(mean_f, 'descend');
            %std_avg = r.stat.smoothed_norm.trace_std_avg_normc(roi_clustered);
            %[~, i_sorted] = sort(std_avg);
        roi_clustered = roi_clustered(i_sorted);
        
        if isempty(roi_clustered)
            r.c_mean(:,i) = 0;
            continue;
        end
        
        % avg over clustered ROIs
        j = 1; % col number
        axes('Parent', h, 'OuterPosition', [x0+(j-1)*x_width (1-y0)-i*y_width x_width y_width*0.90]);
        %subplot(n_row, n_col, (i-1)*n_col + j);
        %r.plot_avg(r.c{i}, 'PlotType', 'mean', 'NormByCol', true, 'LineWidth', 1.2);
        y = r.plot_avg(roi_clustered, 'PlotType', 'mean', 'NormByCol', true, 'LineWidth', 1.2);
        % zero mean & unit norm for cluster mean projection in r.plot2
            y = y - mean(y);
            r.c_mean(:,i) = y/norm(y);
        %title(['c',num2str(i),': mean']);
        str = sprintf('C%d   (n =%d)', i, numel(roi_clustered));
            ht = title(str, 'HorizontalAlignment', 'center', 'FontSize', 12);
            pos = ht.Position;
            ht.Position = [pos(1), pos(2), pos(3)];
        
        
        % all traces
        j = 2;
            %axes('Parent', h, 'OuterPosition', [(j-1)*x_width 1-i*y_width x_width y_width]);
            axes('Parent', h, 'OuterPosition', [x0+(j-1)*x_width (1-y0)-i*y_width x_width y_width*0.90]);
            %subplot(n_row, n_col, (i-1)*n_col + j);
            r.plot_avg(roi_clustered, 'PlotType', 'all', 'NormByCol', true, 'LineWidth', 0.7);
            %str = sprintf('c%d: all traces (n = %d)', i, numel(roi_clustered));
            ax = gca;
            str = sprintf('%s', r.c_note{i});
            ht= title(ax, str, 'HorizontalAlignment', 'center', 'FontSize', 12); 
            w = ht.Extent(3);
            pos = ht.Position;
            ht.Position = [ax.XLim(1) + w/2, pos(2), pos(3)];

        % individual traces up to 4
        n_members = numel(roi_clustered);
        n_plot = min(n_members, n_col - 2);
        
        for k=1:n_plot
            j = k + 2;
            %axes('Parent', h, 'OuterPosition', [(j-1)*x_width 1-i*y_width x_width y_width]);
            axes('Parent', h, 'OuterPosition', [x0+(j-1)*x_width (1-y0)-i*y_width x_width y_width*0.90]);
            %subplot(n_row, n_col, (i-1)*n_col + j);
            r.plot_avg(roi_clustered(k), 'LineWidth', 1.2);
           
        end

        
    end
    
    function bselection(source,event)
       %fprintf('%d\n', event.NewValue.UserData);
    end

    function pushbutton_callback(source, event)
        i = source.UserData;
        roi_clustered = find(r.c==i);
        r.plot2(roi_clustered, 'Cluster', i);
    end
        
    
end

