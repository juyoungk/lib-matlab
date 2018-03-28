function [idx, cent, sumdist] = mykmeans(X, k, varargin)
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

[idx, cent, sumdist] = kmeans(Xre, k, 'Display','final','Replicates',5, varargin{:});

figure('Name',['Cluster Numbers: ', num2str(k)], 'NumberTitle','off', ...
    'position', [1385, 685, 560, 420]);

% silhouette plot
[silh, ~] = silhouette(Xre,idx, 'cosine');

    h = gca;
    h.Children.EdgeColor = [.8 .8 1];
    xtext = ['Silhouette Value (k = ', num2str(k),')'];
    xlabel(xtext,'FontSize',14);
    ylabel 'Cluster';

%plottext = ['Avg. Silhouette Value: ', num2str(mean(silh))];
plottext = sprintf('Avg. Silhouette Value: %.2f', mean(silh));
plottext2 = ['Sum distances: ', num2str(sum(sumdist))];
text(0.50, round(0.93*length(idx)), plottext, 'FontSize',13);
text(0.50, round(0.98*length(idx)), plottext2,'FontSize',13);

% average silhouette values to see if there is any improvement.
disp(['Average Silhouette Value: ', num2str(mean(silh))]);

% scatter plot and image display (should be optional)
if ndims(X) > 1 && d(end) > 1 % p should be more than one.
    mycluscatter(Xre, idx, cent);
end

% if X was a stack of 2-D image, show the index image.
if Dim == 3
    imgclu(idx, d(1), d(2));
end

end