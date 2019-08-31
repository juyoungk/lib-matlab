%% PCA analysis note for 0223 flash data using roiData
r = g.rr;

%% Just PCA for first look on data
%r.smoothing_size = 5;
I = find(r.p_corr.smoothed_norm > 0.3);
[coeff, score, latent, ts, explained] = r.pca(I); % Score other cells w/ the PCA basis learned now. 
%
% plot explained percentage as PC order.
figure('Position', [450 400 560 420]);
semilogy(latent, '-o', 'LineWidth', 1.5, 'MarkerSize', 10)

% Scatter plot for all cells up to dim 3
I = find(r.p_corr.smoothed_norm > 0.3);
score  = r.avg_pca_score(I, 1:3); % [id, scores]
mycluscatter(score);

% Plot PCA basis trace?

%% (For clustered result) See how clustered data is scattered in PCA space.
I = find(r.p_corr.smoothed_norm > 0.1);
[coeff, score, latent, ts, explained] = r.pca(I); % Score other cells w/ the PCA basis learned now. 
mycluscatter(score, 'Cluster', r.c(I));

%% Clustering ON - OFF w/ previous PCA basis
num_cluster = 4;
PCA_dim = 4;

% Select ROIs.
I = find(r.p_corr.smoothed_norm > 0.4);
score = r.avg_pca_score(I, 1:PCA_dim); % [id, scores]
% K-means Clustering: distance can be 'correlation' 
% 'cosine': angle matters. 
[c_idx, cent, sumdist] = mykmeans(score, num_cluster, 'Distance', 'cosine');

figure('Position', [230, 550, 250*num_cluster, 620]);
for c = 1:num_cluster
    ids = I(c_idx==c);
    X = r.avg_trace_smooth_norm(:, ids);
    X = normc(X);
    subplot(2, num_cluster, c);
    plot(X);
    subplot(2, num_cluster, c+num_cluster);
    r.plot_roi(ids);
end
%
c2 = c_idx;

%% Clustering within ON (or OFF) clusters - New PCA and cluster
I_group1 = I(c2 == 1);            % I is a set of ROI numbers.
[coeff, score] = r.pca(I_group1); % Do PCA
% data for cluster
PCA_dim = 5;
score  = r.avg_pca_score(I_group1, 1:PCA_dim); % [id, scores]

%
num_cluster = 6;
sum_within_cluster = zeros(num_cluster, 1);
          silh_avg = zeros(num_cluster, 1);

for k = 2:num_cluster
        
    fprintf('K-means analysis for Num of CLusters: %d\n', k);

    [c_idx, cent, sumdist, silh_avg(k)] = mykmeans(score, k);
    sum_within_cluster(k) = sum(sumdist);

end
        
figure; plot(sum_within_cluster, '-o', 'Linewidth', 2, 'MarkerSize', 10); title('Sum of within-cluster dist to centroids of clusters');
figure; plot(silh_avg,  '-o', 'Linewidth', 2, 'MarkerSize', 10);          title('Average Silhouette Value');


%% k = 5
num_cluster = 4;
[c_idx, cent, sumdist, silh_avg(k)] = mykmeans(score, num_cluster);
X = r.avg_trace_smooth_norm(:, I_group1);
X = normc(X);


