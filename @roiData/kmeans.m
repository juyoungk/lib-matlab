function [ids_sorted, cluster_idx] = kmeans(r, num_cluster, num_PCA_dim, ids)
% K-emans clustering on rois of reliability > threshold in PCA space
% 1. roi selection (or given)
% 2. PCA
% 3. clustering
% 4. sorting
% 5. correlation map

if nargin < 4
    % no ids were given.
    reliability_threshold = 0.2;
    % Select ROIs.
    ids = find(r.p_corr.smoothed_norm > reliability_threshold);
    fprintf('kmeans clustering - %d rois selected by reliability threshold: %.2f\n', length(ids), reliability_threshold);
else
    fprintf('kmeans clustering - %d rois are given.\n', length(ids))
end

if length(ids) < 4
    disp('Too few (<4) ROIs were selected. Clustering analysis is aborted.');
    ids_sorted = [];
    cluster_idx = [];
    return;
end

if nargin < 3
    num_PCA_dim = 5;
end

if nargin < 2
    num_cluster = 5;
end

num_PCA_dim = min(num_PCA_dim, length(ids)-1);
num_cluster = min(num_cluster, length(ids)-1);

fprintf('kmeans clustering - num of PCA dimension: %d\n', num_PCA_dim);
fprintf('kmeans clustering - num of clusters: %d\n', num_cluster);
disp(' ');

% raw traces
trace = r.avg_trace_smooth_norm(:, ids);
trace = trace.'; % transpose so that ids is in 1st dim.

% PCA over selected ids.
r.pca(ids);
score = r.avg_pca_score(ids, 1:num_PCA_dim); % [id, scores]

% K-means Clustering: distance can be 'correlation' 
% 'cosine': distance by measuring angle of two vectors.
% Data matrix X is N-by-P. Rows of X corresponds to points.
% Roi index should be the 1st dim.
% Num of cluster is arbitrary. It does not reflect any kind of structures
% in the data.
%[c_idx, cent, sumdist] = mykmeans(score, num_cluster, 'Distance', 'cosine');
[c_idx, cent, sumdist] = mykmeans(trace, num_cluster, 'Distance', 'correlation');

% Save the cluster result as a draft
% It was to do analyses without replacing a precious clustering result.
% Currently, no meaning for draft cluster.
r.cluster_draft = zeros(1, r.numRoi);
r.cluster_draft(ids) = c_idx; % doesn't need to be ordered.

% Save as a new cluster result for various plots.
% (Previous clustering result will be deleted and updated.)
r.c = r.cluster_draft;

% Plot avg traces and locations of each cluster.
r.plot_cluster_result;

% Plot color-coded clustered rois
r.plot_cluster_roi_labeled;
print([r.avg_name, '_kmeans_clustered_',num2str(num_cluster),'_roi_color'], '-dpng', '-r300')


% Sorting
[cluster_idx, index_order] = sort(c_idx);
ids_sorted = ids(index_order);

% Correlation map
% over repeats
t1 = r.avg_trigger_times(1);
t2 = r.avg_trigger_times(end) + r.avg_trigger_interval;
frame_ids = r.f_times > t1 & r.f_times < t2;

X = r.roi_smoothed_norm(frame_ids, ids_sorted);
A = corrcoef(X);

figure('Position', [1270, 435, 745, 782]);
ax = axes('Position', [0.03 0 0.96 0.98]);
imagesc(A);
title('correlation');
colorbar
% YTick
ax.TickLength = [0 0];
% Print cluster ids
% hold on
% for i=1:max(c)
%     x = c_info(i).row_i-0.5;
%     y = x;
%     w = c_info(i).num;
%     h = w;
%     label = num2str(i);
%     rectangle('Position', [x, y, w, h], 'LineWidth', 1.5)
%     text(x+w/2., y, label, 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
% end

disp(' ');

end