function plot_cluster(r, i_cluster, n_trace, PlotType)
% Display clustered traces. Smoothed trace will be used by default. Summary
% plot mode with n_trace =0.
%
% n_trace - # of individual traces (4 is default)
%           0 is specfial mode - Summary Plot mode. Spatial locations will be displayed
%           instead. 

    if nargin < 4
        PlotType = 'normal';
    end

    if nargin < 3
        n_trace = 4;
        disp('Summary mode if n_trace is 0. (e.g. r.plot_cluster(cluster ids, 0) )');
    end
    
    if nargin < 2
        i_cluster = 1:r.dispClusterNum;
    elseif min(i_cluster == 0) > 0
        % i_cluster = 0 case : summary mode
        i_cluster = 1:r.dispClusterNum;
        n_trace = 0;
    else
        % i_cluster as input
        i_cluster(i_cluster ==0) = []; % exclude 0 (noise) cluster
        if numel(i_cluster) > 30
            error('Too many clusters (> 30) was given to plot_cluster.');
        end
    end
    
    % array for row position for each cluster?
    
    %
    n_row = numel(i_cluster);
    n_col = max(n_trace + 2, 4);
    x0 = 0.05;
    y0 = 0.0;
    x_width = (1-x0)/n_col;
    y_width = (1-y0)/n_row;
     
    % get focus or create new function if it is not empty
    if ishandle(r.c_hfig)
        figure(r.c_hfig);
        
    elseif max(r.c) > 0
        if n_trace == 0 
            f_width = 750;
        else
            f_width = 1000;
        end
        r.c_hfig = figure('Position', [1430 50 f_width 900]);
        %r.c_hfig = figure('Position', [1430 50 1100 1500]);
        pos = r.c_hfig.Position;
        % Create button group
        bg = uibuttongroup('Visible','off',...
                  'Position',[0 0 x0 1],...
                  'SelectionChangedFcn',@bselection); % callback fun is defined in the below.
        i_row = 0;    
        for c = i_cluster
            i_row = i_row + 1;
            row_location(c) = i_row;
            uicontrol(bg,'Style', 'pushbutton',...
                  'String', num2str(c),...
                  'Position', [0 ((1-y0)-i_row*y_width)*pos(4) x0*pos(3) y_width*pos(4)],...
                  'HandleVisibility','off',...
                  'UserData', c, 'Callback', @pushbutton_callback, 'FontSize', 14);      
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
    
    % any more cases for deleting handles??
    
    % column index
    i_row = 0;
    
    for i = i_cluster % row number (~ cluster number)
        
        i_row = i_row + 1;
        
        % push button for opening a plot window for selected cluster
        % this is not axes, but uicontrol
        
        roi_clustered = find(r.c==i);
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
        axes('Parent', h, 'OuterPosition', [x0+(j-1)*x_width (1-y0)-i_row*y_width x_width y_width*0.90]);
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
            yticklabels([]);

        % All traces in one axes
        j = 2;
            %axes('Parent', h, 'OuterPosition', [(j-1)*x_width 1-i*y_width x_width y_width]);
            axes('Parent', h, 'OuterPosition', [x0+(j-1)*x_width (1-y0)-i_row*y_width x_width y_width*0.90]);
            %subplot(n_row, n_col, (i-1)*n_col + j);
            
            [~, s] = r.plot_avg(roi_clustered, 'PlotType', 'all', 'NormByCol', true, 'LineWidth', 0.7, 'Label', true);
            
            %str = sprintf('c%d: all traces (n = %d)', i, numel(roi_clustered));
            yticklabels([]);
            ax = gca;
            str = sprintf('%s', r.c_note{i});
            ht= title(ax, str, 'HorizontalAlignment', 'center', 'FontSize', 12); 
            w = ht.Extent(3);
            pos = ht.Position;
            ht.Position = [ax.XLim(1)+w/2, pos(2), pos(3)];
            
       % Summary Plot Mode
       if n_trace == 0 % means 'summary' mode
           j = 3;
               ax = axes('Parent', h, 'OuterPosition', [x0+(j-1)*x_width (1-y0)-i_row*y_width x_width y_width*0.90]);
               r.plot_cluster_roi(i, 'label', false, 'imageType', 'bw');
               xlabel('ROI locations');
               %ax = gca;
               text((ax.XLim(1)+ax.XLim(end))/2, ax.YLim(end), 'ROI locations', 'FontSize', 12, 'Color', 'k', ...
                    'VerticalAlignment', 'top', 'HorizontalAlignment','center');
                
           j = 4;
           % signal stat
           % responsiveness vs mean f
           % See if specific cluster has distinively high dF (~spiking)
                ax = axes('Parent', h, 'OuterPosition', [x0+(j-1)*x_width (1-y0)-i_row*y_width x_width y_width*0.90]);
               
                scatter(r.stat.mean_f(roi_clustered), r.stat.smoothed_norm.avg_amp(roi_clustered), 8);
                %ax.Color = 'k'; % background color
                xlabel(['mean f']);
                ylabel('dF amplitude');

           continue;
       end
            
        % individual traces up to 4
        n_members = numel(roi_clustered);
        n_plot = min(n_members, n_col - 2);
        
        for k=1:n_plot
            j = k + 2;
            %axes('Parent', h, 'OuterPosition', [(j-1)*x_width 1-i*y_width x_width y_width]);
            axes('Parent', h, 'OuterPosition', [x0+(j-1)*x_width (1-y0)-i_row*y_width x_width y_width*0.90]);
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

