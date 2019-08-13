%% Correlation map, cluster and see how many distinct groups of cells are classified.

% r % roiData
r = g.rr;

%% Filter by times
t1 = 0;
t1 = 110;
t2 = 330;
ids = r.f_times > t1 & r.f_times < t2;

%% Filter by ROIs: Top xx reliable ROIs.

rois = r.roi_good(1:40);


%% Trace type

Y = r.roi_smoothed_norm(ids, rois);

%Y = r.roi_smooth_detrend(ids, rois);

% Meaning of trend?
%1. is not the dynamic fluctuation of expression level.
%2. might be due to the drift of focusing
%3. can be due to the real physiology, but irrelevant to visual stimulus.

% often, the stimulus-irrelevant correlation is also very important feature
% to observe.


%% Correlation matrix (Pearson correlation)

A = corrcoef(Y);

% remove diagonal elements
A = A - eye(size(A));

% squareform: vector of all pair-wise distance
p = squareform(A, 'tovector');

% dissimilarity vector
dissimilarity = 1 - p;


%% 
% Perform linkage clustering
% 'complete' method - measures the farthest distance
%
% Z = (obj1, obj2, dist). Ordered by distance.
% Z = (objects-1) X 3 matrix.
% method can be 'complete'
Z = linkage(dissimilarity, 'complete');
leafOrder = optimalleaforder(Z, dissimilarity);

% group the data into clusters
cutoff = 0.25;
c = cluster(Z,'cutoff',cutoff,'criterion','distance')

% Plot the tree
% P = 0 means all leaf nodes.
H = dendrogram(Z, 0, 'colorthreshold', cutoff, 'reorder', leafOrder);
set(H, 'LineWidth', 2);

% Clustering by Gaussian Mixture Model?


%% reorder Y by cluster groups
Y_ordered = zeros(size(Y));

% cluster info
clear c_info
c_info(1).row_i = 1;
%idx = zeros(1, size(Y,2));
idx = [];

for i=1:max(c)
    
    c_ids = find(c == i);
    
    % New index array according to the cluster ids. 
    idx = cat(1, idx, c_ids);
    
    c_info(i).ids = c_ids;
    c_info(i).num = length(c_ids);
    c_info(i).row_e = c_info(i).row_i + c_info(i).num - 1;
    
    Y_ordered(:, c_info(i).row_i:c_info(i).row_e) = Y(:, c_ids);
    
    if i ~= max(c)
        c_info(i+1).row_i = c_info(i).row_e + 1;
    end
    
end

figure;
ax = axes('Position', [0.03 0 1 0.93]);
imagesc(A(idx, idx) + eye(size(A)));
colorbar

% Correlation matrix after ordering
A_ordered = corrcoef(Y_ordered);

figure;
ax = axes('Position', [0.03 0 1 0.98]);
imagesc(A_ordered);
colorbar

% Print cluster ids
hold on
for i=1:max(c)
    x = c_info(i).row_i-0.5;
    y = x;
    w = c_info(i).num;
    h = w;
    label = num2str(i);
    rectangle('Position', [x, y, w, h], 'LineWidth', 1.5)
    text(x+w/2., y, label, 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
end

% YTick
ax.TickLength = [0 0];


%% Plot clustered response + ROI spatial locations

i_cluster = 20;
rois = c_info(i_cluster).ids;

% plot ROIs for distinct clusters with color coding
figure;
r.plot_roi(rois, "imageType", "bw", "label", false);

% Trace of clustered ROIs
figure('Position', [906 976 1420 305]);
plot(Y(:, rois))
ff


%% distribution of the corrleation 
utils.myhistplot(r(:))




