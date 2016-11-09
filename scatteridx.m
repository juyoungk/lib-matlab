function mycluscatter(X, idx)

[n, p] = size(X); % n observations, p variables
maxidx = max(idx);
color = jet(maxidx);  

figure('position', [600, 400, 1000, 1000]);
for i = 1:p
    for j = 1:p
        subplot(p,p,(i-1)*p+j);
        if i==j
            %histogram(X(i)); 
            continue;
        end
        for c = 1:maxidx
            scatter(X(idx==c,j),X(idx==c,i),9,color(c,:));
            %plot(X(idx==c,j),X(idx==c,i),'o.','Color',color(c,:),'MarkerSize',9);
            %plot(X(idx==c,j),X(idx==c,i),'o.');
            hold on;
        end
    end
end
%get(0,'DefaultAxesColorOrder');
%plot(C(:,1),C(:,2),'kx', 'MarkerSize',15,'LineWidth',3)
%legend('Cluster 1','Cluster 2','Centroids','Location','NW')
%title 'Cluster Assignments and Centroids'
hold off

end
