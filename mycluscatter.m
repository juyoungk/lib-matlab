function mycluscatter(X, varargin)
% X should be n-by-p matrix. 
% If X is image matrix, X should be "reshaped" before use.
% mycluscatter(X): scatter plot with histogram (called by pcaimg)
% mycluscatter(X, idx, center): idx is n-by-1 matrix, a result of
% clustering

nVarargs = length(varargin);
[n, p] = size(X); % p variables
if nVarargs>=1
    idx = varargin{1};
    maxidx = max(idx);
    color = jet(maxidx); % color [r g b] value by color(c, :)
else % only one cluster (e.g. called by pcaimg)
    idx = ones(n, 1);
    maxidx = max(idx);
    color = [0 0 1];
end

figure('position', [0, 400, 900, 800]);
for i = 1:p
    for j = 1:p
        if p>1
            subplot(p,p,(i-1)*p+j);
        end
        for c = 1:maxidx % # of clustering (# of colors)
            if i==j
                range = linspace(min(X(idx==c,i)),max(X(idx==c,i)),20);
                freq = histc(X(idx==c,i),range);
                bar(range,freq,'FaceColor',color(c,:)); hold on;
                continue;
            end
            scatter(X(idx==c,j),X(idx==c,i),4,color(c,:));
            %plot(X(idx==c,j),X(idx==c,i),'o.','Color',color(c,:),'MarkerSize',9);
            %plot(X(idx==c,j),X(idx==c,i),'o.');
            hold on;    
        end
        % center location
        if nVarargs == 2 && i~=j
                C = varargin{2};
                plot(C(:,j),C(:,i),'kd','MarkerSize',13,'LineWidth',2)
                % scatter(C(:,j),C(:,i), 15, color,'x','LineWidth',4);
                %legend('Cluster 1','Cluster 2','Centroids','Location','NW')
                %title 'Cluster Assignments and Centroids'
        end
        hold off
    end
end

%plot(C(:,1),C(:,2),'kx', 'MarkerSize',15,'LineWidth',3)
%legend('Cluster 1','Cluster 2','Centroids','Location','NW')
%title 'Cluster Assignments and Centroids'
hold off

end
