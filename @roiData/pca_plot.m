function pca_plot(r, i, j)
% scatter plot of i, j PCA componants of roiData average traces.

    if nargin < 2
        i = 1;
        j = 2;
    end

    if isempty(r.avg_pca_score)
        r.pca;
    end
    
    % all avg traces
    X = r.avg_pca_score; % can be empty when ..
    
    % Color setting for clusters;
    c_list = unique(r.c(r.c~=0));
    c_max = max(c_list);
    c_list_num = numel(c_list);
    color = jet(c_max); 
    % color index? color(c_list == r.c(k), :)


    if isempty(X) || size(X, 2) < 2
        % X will be empty when only one data is clustered.
        % size(X, 2) is (n-1) where n is num of data or traces.
        disp('No pca scores or only one trace.');
    else
        
        for c = c_list
            % Color scatter plot for non-zero cluster data 
            scatter(X(r.c==c, i),X(r.c==c, j), 24, color(c,:));               
                grid on
                hold on
        end
        
        % un-assigned cluster 0: gray plot
        c0_color = [0.4 0.4 0.4];
        %scatter(X(r.c==0, i),X(r.c==0, j), 12, c0_color, 'filled');
        
        % Label
        ax = gca;
        ax.Color = 'k'; % background color
        xlabel(['PCA ', num2str(i)], 'FontSize', 12);
        ylabel(['PCA ', num2str(j)], 'FontSize', 12);
        
        % display colorbar
        if c_list_num > 1
            cluster_colorbar = label2rgb(vec(c_list), jet(c_max), 'k');
            axes('Position', [0.93  0.45  0.05  0.2], 'Visible', 'off');
            imshow(cluster_colorbar);
        end
        
        
        % Where is the k-th ROI in PCA space?
%         if r.c(k)
%             % cluster 0 : cluster is not assigned or noisy data.
%             k_color = color(c_list==r.c(k), :);
%             k_color = [1 1 1];
%         else
%             k_color = c0_color;
%         end
%         
%         %scatter(X(k, i),X(k, j), 18, color(c_list==r.c(k), :), 'filled');
%         plot(X(k, i), X(k, j), 'kd', 'MarkerSize', 13, 'LineWidth', 1.8, 'Color', k_color); 
%         
%         
        
        hold off
        
    end



end