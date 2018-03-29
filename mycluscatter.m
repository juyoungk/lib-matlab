function mycluscatter(X, varargin)
% X should be n-by-p matrix. 
% If X is image matrix, X should be "reshaped" before use.
% mycluscatter(X): scatter plot with histogram (called by pcaimg)
%
% mycluscatter(X, idx, center): idx is n-by-1 matrix, a result of
% clustering

nVarargs = length(varargin);
[n, p] = size(X); % p variables

if nVarargs>=1
    idx = varargin{1};
    
    c_list = unique(idx(idx~=0)); 
    c_list_num = numel(c_list);
    color = jet(c_list_num); 
    %color = jet(maxidx); % color [r g b] value by color(c, :)
    
    
else % only one cluster (e.g. called by pcaimg)
    idx = ones(n, 1);
    color = [0 0 1];
end

figure('position', [1200, 400, 900, 800]);
for i = 1:p
    for j = 1:p
        if p>1
            subplot(p,p,(i-1)*p+j);
        end
        for c = c_list % # of clustering (# of colors)
            if i==j
                range = linspace(min(X(idx==c,i)),max(X(idx==c,i)), 20);
                if range(1) == range(end) % only one data in cluster
                    range = range(1);
                    freq = 1;
                else    
                    freq = histc(X(idx==c,i),range);
                end
                bar(range(:),freq,'FaceColor', color(c_list == c, :)); 
                hold on
                continue;
            end
            scatter(X(idx==c,j),X(idx==c,i), 18, color(c_list == c, :), 'filled');
            ax = gca;
            ax.Color = 'k'; % background color
            xlabel(['dim ',num2str(j)]);
            ylabel(['dim ',num2str(i)]);
            grid on
            %plot(X(idx==c,j),X(idx==c,i),'o.','Color',color(c,:),'MarkerSize',9);
            %plot(X(idx==c,j),X(idx==c,i),'o.');
            hold on;    
        end
        
        % center location
        if nVarargs == 2 && i~=j
                if nargin > 3
                    C = varargin{2}; % center locations
                    for c = 1:c_list % # of clustering (# of colors)
                        plot(C(c,j), C(c,i),'kd', 'MarkerSize', 11, 'LineWidth', 1.8, 'Color', color(c_list == c, :))
                        text(C(c,j), C(c,i), sprintf('%d', c), 'Color', 'k', ...
                           'VerticalAlignment', 'middle', 'HorizontalAlignment','center', 'FontSize', 9); 
                    end
                    % scatter(C(:,j),C(:,i), 15, color,'x','LineWidth',4);
                    %legend('Cluster 1','Cluster 2','Centroids','Location','NW')
                    %title 'Cluster Assignments and Centroids'
                end
        end
        
        hold off
    end
end

%plot(C(:,1),C(:,2),'kx', 'MarkerSize',15,'LineWidth',3)
%legend('Cluster 1','Cluster 2','Centroids','Location','NW')
%title 'Cluster Assignments and Centroids'
hold off

end
