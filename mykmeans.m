function [idx, cent, sumdist, silh_avg] = mykmeans(X, k, varargin)
% dist measure for silhouette: 'cosine'
% X can be n-by-p matrix or image(2D-by-p). P is # of observations (variables).
% k : k-means cluster
% cent? k-by-P matrix
    d = size(X);
    Dim = ndims(X);

    if d(end) ==1 
        disp('[mykeans] Data X has only 1 observation (or variable); p =1');
        disp('[mykeans] No need for clustering.');
        return
    end

    Xre = reshape(X,[],size(X,ndims(X)));
    
    % Clustering
    % distance: 'cosine', 'correlation', ..
    [idx, cent, sumdist] = kmeans(Xre, k, 'Display','final','Replicates', 10, varargin{:});

    figure('Name',['Cluster Numbers: ', num2str(k)], 'NumberTitle','off', ...
        'position', [1945, 770, 560, 420]);

    % silhouette plot
    [silh, ~] = silhouette(Xre, idx, 'cosine');

        h = gca;
        h.Children.EdgeColor = [.8 .8 1];
        xtext = ['Silhouette Value (k = ', num2str(k),')'];
        xlabel(xtext,'FontSize',14);
        ylabel 'Cluster';

    %plottext = ['Avg. Silhouette Value: ', num2str(mean(silh))];
    silh_avg = mean(silh);
    
    plottext = sprintf('Avg. Silhouette Value: %.2f', silh_avg);
    plottext2 = ['Sum of within-cluster sum distances: ', num2str(sum(sumdist))];
    text(0.50, round(0.94*length(idx)), plottext, 'FontSize',12);
    text(0.50, round(0.99*length(idx)), plottext2,'FontSize',12);

    % average silhouette values to see if there is any improvement.
    
    disp(['Average Silhouette Value: ', num2str(silh_avg)]);
    
    
    %% scatter plot of color-coded clusters
    if ndims(X) > 1 && d(end) > 1 % p should be more than one.
        mycluscatter(Xre, 'Cluster', idx);
    end

    %%
    % if X was a stack of 2-D image, show the index image.
    if Dim == 3
        imgclu(idx, d(1), d(2));
    end

end