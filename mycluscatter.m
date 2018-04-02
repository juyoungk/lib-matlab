function mycluscatter(X, varargin)
% X should be n-by-p matrix. 
% 1st input in varargin should be cluster (group) index.
% If X is image matrix, X should be "reshaped" before use.
% mycluscatter(X): scatter plot with histogram (called by pcaimg)
%
% mycluscatter(X, idx, center): idx is n-by-1 matrix, a result of
% clustering

p=ParseInput(varargin{:});
    idx = p.Results.Cluster;
c_label = p.Results.Label;
      C = p.Results.Center;

nVarargs = length(varargin);
[n, p] = size(X); % p variables      
      
if isempty(idx)
    idx = ones(n, 1);
end

if isempty(c_label)
    c_label = cell(1, p);
end

%
c_list = unique(idx); 
c_list_num = numel(c_list);
color = jet(c_list_num);
c_0 = [0.4 0.4 0.4];
%color = jet(maxidx); % color [r g b] value by color(c, :)

figure('position', [1200, 400, 900, 800]);
for i = 1:p
    for j = 1:p
        if p>1
            subplot(p,p,(i-1)*p+j);
        end
        for c = c_list % # of clustering (# of colors)
            if i==j
                range = linspace(min(X(idx==c,i)),max(X(idx==c,i)), 8);
                if range(1) == range(end) % only one data in cluster
                    range = range(1);
                    freq = 1;
                else    
                    freq = histc(X(idx==c,i),range);
                end
                if c == 0
                    %bar(range(:),freq,'FaceColor', c_0); 
                else    
                    bar(range(:),freq,'FaceColor', color(c_list == c, :)); 
                end
                % xlabel only
                if isempty(c_label{j})
                    xlabel(['dim ',num2str(j)]);
                else
                    xlabel(c_label{j});
                end

                hold on
                continue;
            end
            
            if c == 0
                scatter(X(idx==c,j),X(idx==c,i), 12, c_0);
            else
                scatter(X(idx==c,j),X(idx==c,i), 18, color(c_list == c, :), 'filled');
            end
            ax = gca;
            ax.Color = 'k'; % background color
            
            
            if isempty(c_label{j})
                xlabel(['dim ',num2str(j)]);
            else
                xlabel(c_label{j});
            end
            
            if isempty(c_label{i})
                ylabel(['dim ',num2str(i)]);
            else
                ylabel(c_label{i});
            end
            
            grid on
            %plot(X(idx==c,j),X(idx==c,i),'o.','Color',color(c,:),'MarkerSize',9);
            %plot(X(idx==c,j),X(idx==c,i),'o.');
            hold on;    
        end
        
        % center location
        if ~isempty(C) && i~=j
                if nargin > 3
                    %
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

function p =  ParseInput(varargin)
    
    p  = inputParser;   % Create an instance of the inputParser class.
    
    p.addParameter('Label', {}, @(x) iscell(x));
    p.addParameter('Center', [], @(x) ismatrix(x));
    p.addParameter('Cluster', [], @(x) isvector(x));
      
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
    
end